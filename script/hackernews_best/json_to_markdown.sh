#!/bin/bash

# HackerNews JSON to Markdown Converter
# Converts JSON output from fetch_best_posts.sh to readable Markdown format
# Usage: ./json_to_markdown.sh input.json [output.md]

INPUT_FILE="${1:-hn_best_posts.json}"
OUTPUT_FILE="${2:-${INPUT_FILE%.json}.md}"

# Validate input file
if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ Error: Input file not found: $INPUT_FILE" >&2
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "❌ Error: jq is required but not installed" >&2
  exit 1
fi

echo "🔄 Converting JSON to Markdown..." >&2
echo "   Input:  $INPUT_FILE" >&2
echo "   Output: $OUTPUT_FILE" >&2

# Create markdown file
cat > "$OUTPUT_FILE" << 'EOF'
# HackerNews Best Posts & Comments

> Generated from [HackerNews API](https://github.com/HackerNews/API)
> 
> This document contains the 20 best posts with up to 20 comments each.

---

EOF

# Process each post using jq
jq -r '.posts[] | 
  "## Post #\(.id)\n" +
  "\(.title)\n" +
  "\n" +
  "**Author:** [\(.by)](https://news.ycombinator.com/user?id=\(.by))  \n" +
  "**Score:** \(.score) | **Comments:** \(.descendants) | **URL:** " +
  (if .url then "[\(.url)](\(.url))" else "N/A" end) +
  "\n" +
  "\n---\n\n" +
  "### Comments (\(.comments | length))\n" +
  "\n" +
  (.comments | to_entries | map(
    "**Comment \(.key + 1)** by [\(.value.by)](https://news.ycombinator.com/user?id=\(.value.by))\n" +
    "Score: \(.value.score // 0) | Replies: \(.value.descendants // 0)\n" +
    "\n" +
    "> \(.value.text)\n" +
    "\n"
  ) | join("") // "No comments fetched.") +
  "\n---\n\n"' "$INPUT_FILE" >> "$OUTPUT_FILE"

echo "" >&2
echo "✅ Complete! Markdown saved to: $OUTPUT_FILE" >&2

# Display file stats
FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
LINES=$(wc -l < "$OUTPUT_FILE")
POSTS=$(jq '.posts | length' "$INPUT_FILE")
TOTAL_COMMENTS=$(jq '.posts | map(.comments | length) | add' "$INPUT_FILE")

echo "" >&2
echo "📊 Statistics:" >&2
echo "   Posts: $POSTS" >&2
echo "   Total comments: $TOTAL_COMMENTS" >&2
echo "   Avg comments per post: $((TOTAL_COMMENTS / POSTS))" >&2
echo "   File size: $FILE_SIZE" >&2
echo "   Lines: $LINES" >&2
