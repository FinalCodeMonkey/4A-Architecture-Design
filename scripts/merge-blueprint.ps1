<#
.SYNOPSIS
    合并 4A 架构蓝图临时分段文件为最终输出文件。

.DESCRIPTION
    将 Copilot Agent 分段写入的 _tmp_ba.md / _tmp_da.md / _tmp_aa.md /
    _tmp_matrix.md / _tmp_verify.md 按顺序合并为一个完整的蓝图 Markdown 文件，
    合并完成后自动删除所有临时文件。

.PARAMETER Dir
    临时文件所在目录。默认为当前目录（.）。

.PARAMETER Scene
    业务场景名称，用于生成最终文件名：4a-blueprint-{Scene}.md。
    默认为 "blueprint"。

.PARAMETER OutFile
    指定最终输出文件的完整路径。若提供，则忽略 Dir 和 Scene 的文件名拼接逻辑。

.PARAMETER KeepTmp
    若指定此开关，合并完成后不删除临时文件（调试用）。

.EXAMPLE
    # 基本用法：合并当前目录下的临时文件，场景名为 "my-project"
    .\merge-blueprint.ps1 -Scene my-project

.EXAMPLE
    # 指定目录
    .\merge-blueprint.ps1 -Dir "C:\path\to\docs" -Scene my-project

.EXAMPLE
    # 指定完整输出路径
    .\merge-blueprint.ps1 -OutFile "D:\output\4a-final.md"

.EXAMPLE
    # 保留临时文件（调试）
    .\merge-blueprint.ps1 -Scene my-project -KeepTmp
#>

[CmdletBinding()]
param(
    [string] $Dir     = ".",
    [string] $Scene   = "blueprint",
    [string] $OutFile = "",
    [switch] $KeepTmp
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── 1. 解析输出路径 ──────────────────────────────────────────────────────────
$dir = Resolve-Path $Dir | Select-Object -ExpandProperty Path

if ($OutFile -ne "") {
    $outPath = $OutFile
} else {
    $outPath = Join-Path $dir "4a-blueprint-$Scene.md"
}

# ── 2. 定义分段顺序 ──────────────────────────────────────────────────────────
$sections = @(
    [PSCustomObject]@{ File = "_tmp_ba.md";     Heading = "## 一、BA 层次表" }
    [PSCustomObject]@{ File = "_tmp_da.md";     Heading = "## 二、DA 层次表" }
    [PSCustomObject]@{ File = "_tmp_aa.md";     Heading = "## 三、AA 层次表" }
    [PSCustomObject]@{ File = "_tmp_matrix.md"; Heading = "## 四、N:1:1 映射矩阵" }
    [PSCustomObject]@{ File = "_tmp_verify.md"; Heading = "## 五、三架构对齐验证表" }
)

# ── 3. 预检：至少有一个临时文件存在 ─────────────────────────────────────────
$found = $sections | Where-Object { Test-Path (Join-Path $dir $_.File) }
if ($found.Count -eq 0) {
    Write-Error "未找到任何临时文件（_tmp_*.md）于目录：$dir"
    exit 1
}

$missing = $sections | Where-Object { -not (Test-Path (Join-Path $dir $_.File)) }
if ($missing.Count -gt 0) {
    Write-Warning "以下临时文件缺失，对应章节将跳过："
    $missing | ForEach-Object { Write-Warning "  - $($_.File)" }
}

# ── 4. 组装内容 ──────────────────────────────────────────────────────────────
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# 4A 企业架构蓝图 — $Scene")
$lines.Add("")
$lines.Add("> 本文件由 merge-blueprint.ps1 自动合并生成，生成时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$lines.Add("")

foreach ($s in $sections) {
    $filePath = Join-Path $dir $s.File
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Encoding UTF8

        $lines.Add("---")
        $lines.Add("")
        $lines.Add($s.Heading)
        $lines.Add("")
        foreach ($line in $content) {
            $lines.Add($line)
        }
        $lines.Add("")

        Write-Host "  ✓ 已合并：$($s.File)（$($content.Count) 行）" -ForegroundColor Green
    }
}

# ── 5. 写出最终文件 ──────────────────────────────────────────────────────────
$lines | Set-Content $outPath -Encoding UTF8
Write-Host ""
Write-Host "✓ 合并完成：$outPath" -ForegroundColor Cyan

# ── 6. 清理临时文件 ──────────────────────────────────────────────────────────
if (-not $KeepTmp) {
    $sections | ForEach-Object {
        $p = Join-Path $dir $_.File
        if (Test-Path $p) {
            Remove-Item $p -Force
            Write-Host "  ✓ 已删除：$($_.File)" -ForegroundColor DarkGray
        }
    }
    Write-Host "✓ 临时文件清理完成" -ForegroundColor Cyan
} else {
    Write-Host "（-KeepTmp 模式：临时文件已保留）" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "最终蓝图文件：$outPath" -ForegroundColor White
