#!/usr/bin/env bash
# merge-blueprint.sh — 合并 4A 架构蓝图临时分段文件为最终输出文件
#
# 用法：
#   bash merge-blueprint.sh [-d DIR] [-s SCENE] [-o OUTFILE] [-k]
#
# 选项：
#   -d DIR      临时文件所在目录（默认：当前目录 .）
#   -s SCENE    场景名，用于生成文件名 4a-blueprint-{SCENE}.md（默认：blueprint）
#   -o OUTFILE  直接指定完整输出路径（优先于 -d/-s）
#   -k          保留临时文件（调试用，默认删除）
#
# 示例：
#   bash merge-blueprint.sh -s cbg-crm
#   bash merge-blueprint.sh -d /home/user/docs -s ltc
#   bash merge-blueprint.sh -o /tmp/4a-final.md
#   bash merge-blueprint.sh -s cbg-crm -k

set -euo pipefail

# ── 默认值 ───────────────────────────────────────────────────────────────────
DIR="."
SCENE="blueprint"
OUTFILE=""
KEEP_TMP=false

# ── 参数解析 ─────────────────────────────────────────────────────────────────
while getopts "d:s:o:k" opt; do
  case $opt in
    d) DIR="$OPTARG" ;;
    s) SCENE="$OPTARG" ;;
    o) OUTFILE="$OPTARG" ;;
    k) KEEP_TMP=true ;;
    *) echo "用法：$0 [-d DIR] [-s SCENE] [-o OUTFILE] [-k]" >&2; exit 1 ;;
  esac
done

# ── 解析输出路径 ──────────────────────────────────────────────────────────────
DIR="$(cd "$DIR" && pwd)"

if [[ -z "$OUTFILE" ]]; then
  OUTFILE="$DIR/4a-blueprint-$SCENE.md"
fi

# ── 分段定义（顺序固定）─────────────────────────────────────────────────────
declare -a FILES=("_tmp_ba.md" "_tmp_da.md" "_tmp_aa.md" "_tmp_matrix.md" "_tmp_verify.md")
declare -a HEADINGS=(
  "## 一、BA 层次表"
  "## 二、DA 层次表"
  "## 三、AA 层次表"
  "## 四、N:1:1 映射矩阵"
  "## 五、三架构对齐验证表"
)

# ── 预检：至少有一个临时文件存在 ────────────────────────────────────────────
found=0
for f in "${FILES[@]}"; do
  [[ -f "$DIR/$f" ]] && ((found++)) || true
done

if [[ $found -eq 0 ]]; then
  echo "错误：未找到任何临时文件（_tmp_*.md）于目录：$DIR" >&2
  exit 1
fi

# ── 组装并写出 ───────────────────────────────────────────────────────────────
{
  echo "# 4A 企业架构蓝图 — $SCENE"
  echo ""
  echo "> 本文件由 merge-blueprint.sh 自动合并生成，生成时间：$(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  for i in "${!FILES[@]}"; do
    f="${FILES[$i]}"
    path="$DIR/$f"
    heading="${HEADINGS[$i]}"

    if [[ -f "$path" ]]; then
      line_count=$(wc -l < "$path")
      echo "---"
      echo ""
      echo "$heading"
      echo ""
      cat "$path"
      echo ""
      echo "  ✓ 已合并：$f（${line_count} 行）" >&2
    else
      echo "警告：临时文件不存在，已跳过：$f" >&2
    fi
  done
} > "$OUTFILE"

echo ""
echo "✓ 合并完成：$OUTFILE"

# ── 清理临时文件 ──────────────────────────────────────────────────────────────
if [[ "$KEEP_TMP" == false ]]; then
  for f in "${FILES[@]}"; do
    p="$DIR/$f"
    if [[ -f "$p" ]]; then
      rm -f "$p"
      echo "  ✓ 已删除：$f"
    fi
  done
  echo "✓ 临时文件清理完成"
else
  echo "（-k 模式：临时文件已保留）"
fi

echo ""
echo "最终蓝图文件：$OUTFILE"
