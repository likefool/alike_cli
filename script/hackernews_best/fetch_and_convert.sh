#!/bin/bash

# HackerNews Complete Workflow
# Fetches 20 best posts and converts to Markdown in one command
# Usage: ./fetch_and_convert.sh [output_base_name]

BASE_NAME="${1:-hn_posts}"
JSON_FILE="${BASE_NAME}.json"
MD_FILE="${BASE_NAME}.md"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting HackerNews fetch and convert workflow..."
echo ""

# Step 1: Fetch posts
echo "Step 1: Fetching posts from HackerNews API..."
"$SCRIPT_DIR/fetch_best_posts.sh" "$JSON_FILE"

if [ ! -f "$JSON_FILE" ]; then
  echo "❌ Failed to create JSON file" >&2
  exit 1
fi

echo ""
echo "Step 2: Converting JSON to Markdown..."
"$SCRIPT_DIR/json_to_markdown.sh" "$JSON_FILE" "$MD_FILE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Workflow Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Output files:"
echo "  📋 JSON:      $JSON_FILE"
echo "  📄 Markdown:  $MD_FILE"
echo ""
echo "Next steps:"
echo "  View markdown:  cat $MD_FILE"
echo "  Query JSON:     jq '.posts[].title' $JSON_FILE"
echo ""
