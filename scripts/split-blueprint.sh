#!/usr/bin/env bash
# split-blueprint.sh — 从聊天输出或合并蓝图文件中拆分出各章节临时文件
#
# 适用于非 VS Code Copilot Agent 模式的降级场景：
# 用户将 AI 分轮次输出的内容整体粘贴保存为一个 Markdown 文件后，
# 使用本脚本按章节标题拆分为五个临时文件，再由 merge-blueprint.sh 合并。
#
# 支持识别的章节标题关键词（行首须为 ## ）：
#   "BA 层次表"、"DA 层次表"、"AA 层次表"、"映射矩阵"、"三架构对齐验证表"
#
# 用法：
#   bash split-blueprint.sh -i INPUTFILE [-d DIR] [-s SCENE] [-m]
#
# 选项：
#   -i INPUTFILE  源文件（必填）
#   -d DIR        临时文件写出目录（默认：与 INPUTFILE 同目录）
#   -s SCENE      场景名，仅在 -m 时使用（默认：blueprint）
#   -m            拆分完成后自动调用 merge-blueprint.sh 合并
#
# 示例：
#   bash split-blueprint.sh -i _raw_output.md
#   bash split-blueprint.sh -i _raw_output.md -m -s {场景名}
#   bash split-blueprint.sh -i _raw_output.md -d {目标目录} -m -s {场景名}

set -euo pipefail

# ── 参数解析 ──────────────────────────────────────────────────────────────────
INPUT=""
DIR=""
SCENE="blueprint"
DO_MERGE=false

while getopts "i:d:s:m" opt; do
  case $opt in
    i) INPUT="$OPTARG" ;;
    d) DIR="$OPTARG" ;;
    s) SCENE="$OPTARG" ;;
    m) DO_MERGE=true ;;
    *) echo "用法：$0 -i INPUTFILE [-d DIR] [-s SCENE] [-m]" >&2; exit 1 ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "错误：必须通过 -i 指定输入文件" >&2
  exit 1
fi

# ── 解析路径 ──────────────────────────────────────────────────────────────────
INPUT="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"

if [[ -z "$DIR" ]]; then
  DIR="$(dirname "$INPUT")"
else
  DIR="$(cd "$DIR" && pwd)"
fi

# ── 章节定义（关键词 → 输出文件，顺序固定）──────────────────────────────────
KEYWORDS=("BA 层次表" "DA 层次表" "AA 层次表" "映射矩阵" "三架构对齐验证表")
OUTFILES=("_tmp_ba.md" "_tmp_da.md" "_tmp_aa.md" "_tmp_matrix.md" "_tmp_verify.md")

total_lines=$(wc -l < "$INPUT")

# ── 定位各章节起始行号（grep -n 找 ## 开头的标题行）──────────────────────────
declare -a STARTS=()
for kw in "${KEYWORDS[@]}"; do
  lineno=$(grep -n "^##.*${kw}" "$INPUT" | head -1 | cut -d: -f1 || true)
  STARTS+=("${lineno:-}")
done

# 检查至少找到一个章节
found=0
for s in "${STARTS[@]}"; do [[ -n "$s" ]] && ((found++)) || true; done

if [[ $found -eq 0 ]]; then
  echo "错误：未在文件中找到任何已知章节标题，请确认输入文件格式。" >&2
  exit 1
fi

# ── 提取各章节内容并写出临时文件 ─────────────────────────────────────────────
# 工具函数：去掉字符串首尾空行
trim_empty_lines() {
  # 去掉前导空行再去掉尾部空行
  echo "$1" | awk '
    /[^[:space:]]/ { found=1 }
    found { lines[NR]=$0 }
    END {
      last=0
      for (i=NR; i>=1; i--) { if (lines[i] ~ /[^[:space:]]/) { last=i; break } }
      for (i=1; i<=last; i++) print lines[i]
    }
  '
}

for i in "${!KEYWORDS[@]}"; do
  start="${STARTS[$i]}"

  if [[ -z "$start" ]]; then
    echo "警告：未找到章节「${KEYWORDS[$i]}」，已跳过" >&2
    continue
  fi

  # 结束行：下一个有效章节的前一行，或文件末尾
  end=$total_lines
  for j in $(seq $((i + 1)) $((${#KEYWORDS[@]} - 1))); do
    ns="${STARTS[$j]}"
    if [[ -n "$ns" && "$ns" -gt "$start" ]]; then
      end=$((ns - 1))
      break
    fi
  done

  # 提取：从章节标题的下一行到结束行，去除 --- 分隔线，去除首尾空行
  chunk=$(sed -n "$((start + 1)),${end}p" "$INPUT" | grep -v "^---$" || true)
  chunk=$(trim_empty_lines "$chunk")

  if [[ -z "$chunk" ]]; then
    echo "警告：章节内容为空：${KEYWORDS[$i]}，已跳过" >&2
    continue
  fi

  outpath="$DIR/${OUTFILES[$i]}"
  printf '%s\n' "$chunk" > "$outpath"
  line_count=$(wc -l < "$outpath")
  echo "  ✓ 已提取：${OUTFILES[$i]}（${line_count} 行）"
done

echo ""
echo "✓ 拆分完成，临时文件已写入：$DIR"

# ── 可选：拆分后立即合并 ──────────────────────────────────────────────────────
if [[ "$DO_MERGE" == true ]]; then
  echo ""
  echo "正在执行合并..."
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  bash "$script_dir/merge-blueprint.sh" -d "$DIR" -s "$SCENE"
fi
