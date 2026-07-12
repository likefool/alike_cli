# Implementation Guide - HackerNews Digest TC Skill

## Complete Workflow

This skill uses three core scripts to generate Traditional Chinese HackerNews digests:

### 1. Data Fetching Phase
**Script**: `fetch_best_posts.sh`

```bash
./fetch_best_posts.sh output.json
```

**What it does:**
- Calls HackerNews API to get top 20 best stories
- For each story, fetches up to 20 comments
- Strips HTML tags from comments
- Outputs clean JSON with posts and comments

**Output format:**
```json
{
  "posts": [
    {
      "id": 48865019,
      "title": "Article Title",
      "url": "https://...",
      "score": 1587,
      "by": "username",
      "time": 1234567890,
      "descendants": 891,
      "comments": [
        {
          "id": 48550436,
          "by": "commenter",
          "score": 5,
          "time": 1234567900,
          "descendants": 2,
          "text": "Comment text (HTML stripped)"
        }
      ]
    }
  ]
}
```

### 2. Markdown Conversion Phase
**Script**: `json_to_markdown.sh`

```bash
./json_to_markdown.sh input.json output.md
```

**What it does:**
- Converts JSON to readable Markdown format
- Includes author links to HackerNews profiles
- Formats scores, timestamps, and article URLs
- Preserves all comments with metadata

### 3. Chinese Summary Generation
**Script**: `generate_tc_summary.sh` (custom script)

```bash
./generate_tc_summary.sh input.json output_tc.md
```

**What it does:**
- Analyzes top 20 posts
- Creates ranked summary tables
- Provides category-based organization
- Synthesizes community sentiment from comments
- Generates reading priority guide
- Creates statistical overview

## Script Locations

```
/home/alikebox/dev/alike_cli/
├── script/hackernews_best/
│   ├── fetch_best_posts.sh          # Fetch posts
│   ├── json_to_markdown.sh          # Convert to Markdown
│   └── fetch_and_convert.sh         # Combined workflow
└── skills/hackernews-digest-tc/
    ├── skill.md                     # This skill definition
    └── resources/
        └── IMPLEMENTATION.md        # This file
```

## Quick Start Commands

### Generate Today's Digest
```bash
cd /home/alikebox/dev/alike_cli/script/hackernews_best
./fetch_and_convert.sh hn_digest_$(date +%Y%m%d)
# Then generate TC summary
./generate_tc_summary.sh hn_digest_*.json hn_digest_tc.md
```

### One-Line Execution
```bash
cd /home/alikebox/dev/alike_cli/script/hackernews_best && \
./fetch_and_convert.sh hn_$(date +%Y%m%d) && \
./generate_tc_summary.sh hn_$(date +%Y%m%d).json hn_$(date +%Y%m%d)_tc.md
```

### Save to /tmp
```bash
cd /home/alikebox/dev/alike_cli/script/hackernews_best && \
./fetch_and_convert.sh hn_digest && \
./generate_tc_summary.sh hn_digest.json /tmp/hn_digest_tc.md
```

## Processing Pipeline

```
┌─────────────────────────────────────────┐
│ HackerNews API                          │
│ - 20 best stories                       │
│ - ~20 comments per story                │
│ - ~260 total API calls                  │
└──────────────────┬──────────────────────┘
                   │ (2-3 minutes)
                   ▼
┌─────────────────────────────────────────┐
│ fetch_best_posts.sh                     │
│ - Aggregate data into JSON              │
│ - Strip HTML from comments              │
└──────────────────┬──────────────────────┘
                   │ (~90 KB JSON)
                   ▼
┌─────────────────────────────────────────┐
│ json_to_markdown.sh                     │
│ - Format for readability                │
│ - Add author links                      │
└──────────────────┬──────────────────────┘
                   │ (~90 KB Markdown)
                   ▼
┌─────────────────────────────────────────┐
│ generate_tc_summary.sh (NEW)            │
│ - Analyze content                       │
│ - Categorize articles                   │
│ - Synthesize sentiment                  │
│ - Create Chinese summary                │
└──────────────────┬──────────────────────┘
                   │ (<2 seconds)
                   ▼
┌─────────────────────────────────────────┐
│ Traditional Chinese Digest              │
│ - 6-8 KB comprehensive summary          │
│ - Ready for publication                 │
└─────────────────────────────────────────┘
```

## Dependencies & Requirements

### Required Packages
```bash
# Debian/Ubuntu
sudo apt-get install curl jq

# macOS
brew install curl jq

# Verify installation
curl --version
jq --version
```

### Bash Version
- Minimum: Bash 4.0
- Check: `bash --version`

### Network Access
- Must access: `https://hacker-news.firebaseio.com/v0`
- No API key required
- Typical bandwidth: 2-5 MB per run

## Output Files Explained

### 1. Raw JSON (`hn_digest_20260712.json`)
- Complete data dump
- ~90 KB
- Used for filtering and re-analysis
- Keep for historical records

### 2. Markdown (`hn_digest_20260712.md`)
- Human-readable format
- ~90 KB  
- Includes all comments
- Good for archival

### 3. TC Summary (`hn_digest_20260712_tc.md`)
- Traditional Chinese
- ~6-8 KB (compressed)
- Synthesized analysis
- Ready for publication/sharing
- Includes:
  - Ranked overview table
  - Top 5 deep dives with sentiment
  - Categorized article listings
  - Trend analysis
  - Reading priorities
  - Statistics & insights

## Customization Examples

### Fetch Only 5 Posts (for testing)
Edit `fetch_best_posts.sh`, line 14:
```bash
STORY_IDS=$(echo "$BEST_STORIES" | jq -r '.[0:5][]')
```

### Get More Comments Per Post
Edit `fetch_best_posts.sh`, line 28:
```bash
COMMENT_IDS=$(echo "$STORY" | jq -r '.kids[0:50][]? // empty')
```

### Custom API Endpoint
Edit `fetch_best_posts.sh`, line 7:
```bash
API_BASE="https://hacker-news.firebaseio.com/v0"  # Change if needed
```

## Integration Examples

### Scheduled Cron Job (Daily 9 AM)
```bash
# Add to crontab
0 9 * * * cd /home/alikebox/dev/alike_cli/script/hackernews_best && \
./fetch_and_convert.sh hn_$(date +\%Y\%m\%d) && \
./generate_tc_summary.sh hn_$(date +\%Y\%m\%d).json /tmp/hn_digest_tc.md && \
mail -s "HackerNews 最佳文章摘要" user@example.com < /tmp/hn_digest_tc.md
```

### Docker Container
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl jq
COPY script/hackernews_best/ /app/
WORKDIR /app
CMD ["./fetch_and_convert.sh", "hn_digest"]
```

### GitHub Action
```yaml
name: Daily HackerNews Digest
on:
  schedule:
    - cron: '0 9 * * *'
jobs:
  digest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: |
          cd script/hackernews_best
          ./fetch_and_convert.sh hn_$(date +%Y%m%d)
          ./generate_tc_summary.sh hn_*.json hn_tc_summary.md
      - uses: actions/upload-artifact@v3
        with:
          name: hn-digest
          path: script/hackernews_best/hn_tc_summary.md
```

## Monitoring & Logging

### Enable Debug Mode
```bash
set -x  # In scripts
# or
bash -x script_name.sh
```

### Check API Health
```bash
curl -s https://hacker-news.firebaseio.com/v0/beststories.json | jq 'length'
# Should return: 30
```

### Validate JSON Output
```bash
jq . hn_digest.json > /dev/null && echo "Valid JSON"
```

### Check File Integrity
```bash
# Verify post count
jq '.posts | length' hn_digest.json

# Verify comment count
jq '.posts | map(.comments | length) | add' hn_digest.json
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "command not found: jq" | `sudo apt-get install jq` or `brew install jq` |
| "Permission denied" | `chmod +x *.sh` |
| Empty JSON file | Check internet, verify API: `curl https://hacker-news.firebaseio.com/v0/beststories.json` |
| Timeout during fetch | Network issue, try again (API may be slow) |
| Memory error with 20 posts | Reduce post count to 10 or 5 for testing |
| Special characters in comments | Already handled by HTML stripping |

## Performance Optimization

### Reduce API Calls
```bash
# Fetch fewer posts
.[0:10]  # Instead of .[0:20]

# Reduce comments per post
.kids[0:10]  # Instead of .kids[0:20]
```

### Parallel Processing
```bash
# Fetch posts in parallel (advanced)
xargs -P 5 -I {} curl ...
```

### Caching Strategy
```bash
# Reuse JSON without re-fetching
./json_to_markdown.sh cached_file.json
./generate_tc_summary.sh cached_file.json
```

## Quality Assurance

### Before Publishing
- ✅ Validate JSON syntax
- ✅ Check all titles are readable
- ✅ Verify links are formatted correctly
- ✅ Review Chinese translations for accuracy
- ✅ Check comment count matches
- ✅ Verify score calculations

### After Publishing
- ✅ Test links in summary
- ✅ Verify Chinese displays correctly
- ✅ Check file size is reasonable
- ✅ Monitor user feedback
- ✅ Track most clicked topics

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-07-12 | Initial release with 3-script workflow |
| - | - | - |

## Support & Feedback

For issues or improvements:
1. Check IMPLEMENTATION.md troubleshooting section
2. Review script logs
3. Test individual components
4. Verify dependencies installed

---

**Last Updated**: 2026-07-12  
**Maintained by**: likefool  
**Repository**: /home/alikebox/dev/alike_cli/skills/hackernews-digest-tc/
