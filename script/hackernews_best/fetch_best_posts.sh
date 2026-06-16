#!/bin/bash

# HackerNews Best Posts & Comments Fetcher
# Fetches 20 best posts from HackerNews with up to 20 comments each
# Usage: ./fetch_best_posts.sh [output_file]

API_BASE="https://hacker-news.firebaseio.com/v0"
OUTPUT_FILE="${1:-hn_best_posts.json}"

echo "🚀 Fetching 20 best posts from HackerNews API..." >&2

# Get list of best story IDs
BEST_STORIES=$(curl -s "$API_BASE/beststories.json")
STORY_IDS=$(echo "$BEST_STORIES" | jq -r '.[0:20][]')

# Initialize output JSON
echo "{\"posts\": [" > "$OUTPUT_FILE"

post_count=0
for story_id in $STORY_IDS; do
  ((post_count++))
  echo "  [$post_count/20] Fetching post ID: $story_id" >&2
  
  # Fetch story details
  STORY=$(curl -s "$API_BASE/item/$story_id.json")
  
  # Get up to 20 comment IDs
  COMMENT_IDS=$(echo "$STORY" | jq -r '.kids[0:20][]? // empty')
  
  # Build comments JSON array
  TEMP_COMMENTS=$(mktemp)
  echo "[" > "$TEMP_COMMENTS"
  
  comment_count=0
  total_comments=$(echo "$COMMENT_IDS" | wc -w)
  
  for comment_id in $COMMENT_IDS; do
    COMMENT=$(curl -s "$API_BASE/item/$comment_id.json")
    
    # Extract comment fields and strip HTML tags
    echo "$COMMENT" | jq '{
      id: .id,
      by: .by,
      score: .score,
      time: .time,
      descendants: (.descendants // 0),
      text: ((.text // "") | gsub("<[^>]*>"; "") | .[0:150])
    }' >> "$TEMP_COMMENTS"
    
    ((comment_count++))
    if [ $comment_count -lt $total_comments ]; then
      echo "," >> "$TEMP_COMMENTS"
    fi
  done
  
  echo "]" >> "$TEMP_COMMENTS"
  
  # Merge comments into post object
  COMMENTS_JSON=$(cat "$TEMP_COMMENTS" | jq -c '.')
  rm "$TEMP_COMMENTS"
  
  echo "$STORY" | jq \
    --argjson comments "$COMMENTS_JSON" \
    '{
      id: .id,
      title: .title,
      url: .url,
      score: .score,
      by: .by,
      time: .time,
      descendants: .descendants,
      comments: $comments
    }' >> "$OUTPUT_FILE"
  
  # Add comma between objects
  if [ $post_count -lt 20 ]; then
    echo "," >> "$OUTPUT_FILE"
  fi
done

# Finalize JSON
echo "]}" >> "$OUTPUT_FILE"

echo "" >&2
echo "✅ Complete! Saved to: $OUTPUT_FILE" >&2

# Display summary statistics
echo "" >&2
jq '.posts | {
  total_posts: length,
  total_comments: map(.comments | length) | add,
  avg_comments_per_post: (map(.comments | length) | add / length | floor)
}' "$OUTPUT_FILE" >&2


