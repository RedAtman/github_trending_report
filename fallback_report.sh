#!/bin/sh
# Minimal fallback report generator (no Python, uses jq)
# Usage: fallback_report.sh <json_file> [title] [label_cn] [since_display]

JSON_FILE="$1"
TITLE="${2:-日报}"
LABEL_CN="${3:-最近 24 小时}"
SINCE_DISPLAY="${4:-}"

REPO_COUNT=$(jq '.items | length' "$JSON_FILE" 2>/dev/null || echo 0)
[ "$REPO_COUNT" -eq 0 ] && { echo "# GitHub 趋势报告\n\n⚠ 暂无数据\n"; exit 0; }

TOTAL_STARS=$(jq '[.items[].stargazers_count] | add' "$JSON_FILE" 2>/dev/null || echo 0)
AVG_STARS=$(jq '[.items[].stargazers_count] | add/length | floor' "$JSON_FILE" 2>/dev/null || echo 0)
TOTAL_FORKS=$(jq '[.items[].forks_count] | add' "$JSON_FILE" 2>/dev/null || echo 0)
TOTAL_ISSUES=$(jq '[.items[].open_issues_count] | add' "$JSON_FILE" 2>/dev/null || echo 0)
DATE_STR=$(date +%Y-%m-%d)
TIME_STR=$(date +%Y-%m-%d\ %H:%M:%S)

# ── 概览 ──
echo "# GitHub 趋势${TITLE} — ${DATE_STR}"
echo ""
echo "## 📊 概览"
echo ""
echo "| 项目 | 数据 |"
echo "|------|------|"
echo "| 统计范围 | ${SINCE_DISPLAY} |"
echo "| 热门仓库数 | ${REPO_COUNT} |"
echo "| 累计 Star | ${TOTAL_STARS} |"
echo "| 平均 Star | ${AVG_STARS} |"
echo "| 总 Fork 数 | ${TOTAL_FORKS} |"
echo "| 总 Issue 数 | ${TOTAL_ISSUES} |"
echo "| 生成时间 | ${TIME_STR} CST |"
echo ""
echo "---"
echo ""

# ── 完整榜单 ──
echo "## 🏆 Top ${REPO_COUNT} 仓库"
echo ""
echo "| # | 仓库 | ⭐ Stars | 语言 | 描述 |"
echo "|---|------|---------|------|------|"

jq -r '.items[] | [
  (.full_name),
  (.stargazers_count | tostring),
  (.language // "-"),
  (.description // "-" | gsub("[\n]"; " ") | gsub("\\|"; "/"))
] | @tsv' "$JSON_FILE" 2>/dev/null | awk -F'\t' '{
  printf("| %d | [%s](https://github.com/%s) | %s | %s | %s |\n", NR, $1, $1, $2, $3, $4)
}'

echo ""

# ── 语言分布 ──
echo "### 🔤 语言分布"
echo ""

jq -r '[.items[].language // "N/A"] | group_by(.) | map({lang: .[0], count: length}) | sort_by(-.count) | .[] | "\(.lang): \(.count)"' "$JSON_FILE" 2>/dev/null | while IFS=: read -r lang count; do
  echo "- ${lang}: ${count} 个"
done

echo ""
