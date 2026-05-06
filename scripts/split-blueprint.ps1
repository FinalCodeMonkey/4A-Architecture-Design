<#
.SYNOPSIS
    从聊天输出或合并蓝图文件中拆分出各章节临时文件。

.DESCRIPTION
    适用于非 VS Code Copilot Agent 模式的降级场景：
    用户将 AI 分轮次输出的内容整体粘贴保存为一个 Markdown 文件后，
    使用本脚本按章节标题拆分为五个临时文件，再由 merge-blueprint.ps1 合并。

    支持识别的章节标题关键词（行首须为 ## ）：
      "BA 层次表"、"DA 层次表"、"AA 层次表"、"映射矩阵"、"三架构对齐验证表"

.PARAMETER InputFile
    包含所有章节内容的源文件（必填）。

.PARAMETER Dir
    临时文件写出目录。默认与 InputFile 同目录。

.PARAMETER Scene
    场景名，仅在指定 -Merge 时使用，用于生成最终文件名（默认：blueprint）。

.PARAMETER Merge
    拆分完成后立即调用 merge-blueprint.ps1 执行合并。

.PARAMETER KeepInput
    合并完成后保留源输入文件（默认：保留；本参数仅作明确声明用）。

.EXAMPLE
    # 仅拆分
    .\scripts\split-blueprint.ps1 -InputFile _raw_output.md

.EXAMPLE
    # 拆分并立即合并
    .\scripts\split-blueprint.ps1 -InputFile _raw_output.md -Merge -Scene {场景名}

.EXAMPLE
    # 指定临时文件写出目录
    .\scripts\split-blueprint.ps1 -InputFile _raw_output.md -Dir "{目标目录}" -Merge -Scene {场景名}
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $InputFile,

    [string] $Dir   = "",
    [string] $Scene = "blueprint",
    [switch] $Merge
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── 1. 解析路径 ───────────────────────────────────────────────────────────────
$inputPath = Resolve-Path $InputFile | Select-Object -ExpandProperty Path

if ($Dir -eq "") {
    $dir = Split-Path $inputPath -Parent
} else {
    $dir = Resolve-Path $Dir | Select-Object -ExpandProperty Path
}

# ── 2. 章节定义（关键词匹配 ## 开头的标题行，容错章节号与格式差异）─────────
$sections = @(
    [PSCustomObject]@{ Keyword = "BA 层次表";        File = "_tmp_ba.md"     }
    [PSCustomObject]@{ Keyword = "DA 层次表";        File = "_tmp_da.md"     }
    [PSCustomObject]@{ Keyword = "AA 层次表";        File = "_tmp_aa.md"     }
    [PSCustomObject]@{ Keyword = "映射矩阵";          File = "_tmp_matrix.md" }
    [PSCustomObject]@{ Keyword = "三架构对齐验证表";   File = "_tmp_verify.md" }
)

# ── 3. 读取源文件 ─────────────────────────────────────────────────────────────
$lines = Get-Content $inputPath -Encoding UTF8

# ── 4. 定位各章节起始行（0-based 行号）───────────────────────────────────────
$starts = @{}   # File → lineIndex

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if (-not $line.StartsWith("##")) { continue }

    foreach ($s in $sections) {
        if ($starts.ContainsKey($s.File)) { continue }          # 已定位，跳过
        if ($line -match [regex]::Escape($s.Keyword)) {
            $starts[$s.File] = $i
        }
    }
}

if ($starts.Count -eq 0) {
    Write-Error "未在文件中找到任何已知章节标题（## BA 层次表 / ## DA 层次表 等），请确认输入文件格式。"
    exit 1
}

# ── 5. 按章节提取内容并写出临时文件 ──────────────────────────────────────────
for ($si = 0; $si -lt $sections.Count; $si++) {
    $s = $sections[$si]

    if (-not $starts.ContainsKey($s.File)) {
        Write-Warning "未找到章节「$($s.Keyword)」，已跳过"
        continue
    }

    $startLine = $starts[$s.File] + 1      # 跳过标题行本身

    # 结束行：下一个有效章节的前一行，或文件末尾
    $endLine = $lines.Count - 1
    for ($sj = $si + 1; $sj -lt $sections.Count; $sj++) {
        $nextFile = $sections[$sj].File
        if ($starts.ContainsKey($nextFile) -and $starts[$nextFile] -gt $starts[$s.File]) {
            $endLine = $starts[$nextFile] - 1
            break
        }
    }

    # 提取内容：去除 --- 分隔线
    [string[]]$chunk = $lines[$startLine..$endLine] | Where-Object { $_ -ne "---" }

    # 去除首部空行
    while ($chunk.Count -gt 0 -and $chunk[0].Trim() -eq "") {
        $chunk = $chunk[1..($chunk.Count - 1)]
    }
    # 去除尾部空行
    while ($chunk.Count -gt 0 -and $chunk[-1].Trim() -eq "") {
        $chunk = $chunk[0..($chunk.Count - 2)]
    }

    if ($chunk.Count -eq 0) {
        Write-Warning "章节内容为空：$($s.Keyword)，已跳过"
        continue
    }

    $outPath = Join-Path $dir $s.File
    $chunk | Set-Content $outPath -Encoding UTF8
    Write-Host "  ✓ 已提取：$($s.File)（$($chunk.Count) 行）" -ForegroundColor Green
}

Write-Host ""
Write-Host "✓ 拆分完成，临时文件已写入：$dir" -ForegroundColor Cyan

# ── 6. 可选：拆分后立即合并 ──────────────────────────────────────────────────
if ($Merge) {
    Write-Host ""
    Write-Host "正在执行合并..." -ForegroundColor Cyan
    $mergeScript = Join-Path $PSScriptRoot "merge-blueprint.ps1"
    & $mergeScript -Dir $dir -Scene $Scene
}
