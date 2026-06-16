# HackerNews Scraper - Complete Solution

A shell script collection that fetches HackerNews best posts with comments and converts them to multiple formats.

## 📦 Components

### 1. **fetch_best_posts.sh** - Fetch Posts API
- Fetches **20 best posts** from HackerNews API
- Fetches **up to 20 comments** per post
- Outputs clean **JSON format**
- Progress indicators for long-running operations

### 2. **json_to_markdown.sh** - Convert to Markdown
- Converts JSON output to **readable Markdown format**
- Includes author links to HackerNews profiles
- Formats scores, timestamps, and URLs
- Strips HTML tags from comments

### 3. **fetch_and_convert.sh** - One-Command Workflow
- Combines both scripts in sequence
- Fetches posts **then** converts to Markdown
- Single command for complete workflow
- Displays final statistics

---

## 🚀 Quick Start

### One Command (Recommended)
```bash
./fetch_and_convert.sh
```
Output: `hn_posts.json` + `hn_posts.md`

### Fetch Only
```bash
./fetch_best_posts.sh my_posts.json
```
Output: `my_posts.json`

### Convert Existing JSON
```bash
./json_to_markdown.sh my_posts.json my_posts.md
```
Output: `my_posts.md`

---

## 📋 Requirements

- `bash` - Shell interpreter
- `curl` - HTTP requests
- `jq` - JSON processing

### Install jq
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

---

## 📊 Workflow

```
fetch_best_posts.sh     json_to_markdown.sh
        |                       |
        v                       v
  API Calls          JSON Processing
        |                       |
        v                       v
    JSON File      +---------> Markdown File
        |           (processed by)
        |
   Use for data
  analysis with jq
```

---

## 📄 Output Examples

### JSON Format
```json
{
  "posts": [
    {
      "id": 48546294,
      "title": "A backdoor in a LinkedIn job offer",
      "url": "https://roman.pt/posts/linkedin-backdoor/",
      "score": 1401,
      "by": "lwhsiao",
      "descendants": 268,
      "comments": [
        {
          "id": 48550436,
          "by": "shubb",
          "score": null,
          "text": "Comment text (HTML stripped)..."
        }
      ]
    }
  ]
}
```

### Markdown Format
```markdown
# HackerNews Best Posts & Comments

## Post #48546294

A backdoor in a LinkedIn job offer

**Author:** [lwhsiao](https://news.ycombinator.com/user?id=lwhsiao)  
**Score:** 1401 | **Comments:** 268 | **URL:** [Link](https://...)

---

### Comments (20)

**Comment 1** by [shubb](https://news.ycombinator.com/user?id=shubb)
Score: 5 | Replies: 0

> Comment text here...
```

---

## 🔧 Usage Examples

### Basic Workflow
```bash
# 1. Fetch and convert
./fetch_and_convert.sh latest

# 2. View markdown
cat latest.md

# 3. Query JSON
jq '.posts[].title' latest.json
```

### Advanced Queries with jq

**Find posts by author:**
```bash
jq '.posts[] | select(.by == "username") | {title, score}' hn_posts.json
```

**Get highest scoring posts:**
```bash
jq '.posts | sort_by(.score) | reverse | .[0:5]' hn_posts.json
```

**Find specific comment:**
```bash
jq '.posts[].comments[] | select(.by == "username")' hn_posts.json
```

**Export to CSV:**
```bash
jq -r '.posts[] | [.id, .title, .score, .by] | @csv' hn_posts.json > posts.csv
```

**Count comments by author:**
```bash
jq '.posts[].comments[] | .by' hn_posts.json | sort | uniq -c | sort -rn
```

---

## ⚙️ Customization

### Fetch Fewer Posts (for testing)
Edit `fetch_best_posts.sh` line 14:
```bash
STORY_IDS=$(echo "$BEST_STORIES" | jq -r '.[0:5][]')  # Get 5 posts instead of 20
```

### Get More Comments Per Post
Edit `fetch_best_posts.sh` line 28:
```bash
COMMENT_IDS=$(echo "$STORY" | jq -r '.kids[0:50][]? // empty')  # Get 50 comments instead of 20
```

### Change API Endpoint
Edit `fetch_best_posts.sh` line 7:
```bash
API_BASE="https://hacker-news.firebaseio.com/v0"
```

---

## 📈 Performance

| Operation | Time | Details |
|-----------|------|---------|
| Fetch 20 posts | 2-5 min | ~260 API calls |
| Convert JSON→MD | < 1 sec | jq processing |
| Total workflow | 2-5 min | fetch + convert |

**File Sizes:**
- JSON: 500KB - 1MB
- Markdown: 850KB - 1.5MB

---

## 🐛 Troubleshooting

### "command not found: jq"
```bash
sudo apt-get install jq  # Linux
brew install jq          # macOS
```

### "Permission denied"
```bash
chmod +x fetch_best_posts.sh
chmod +x json_to_markdown.sh
chmod +x fetch_and_convert.sh
```

### "curl: (7) Failed to connect"
- Check internet connection
- Test API: `curl https://hacker-news.firebaseio.com/v0/beststories.json`

### JSON file is empty
- Verify API connectivity
- Check for network timeouts
- Try with fewer posts (edit script)

---

## 📚 Documentation

- **WORKFLOW.md** - Detailed workflow guide
- **README_SCRIPT.md** - Script documentation
- **USAGE_EXAMPLES.md** - jq query examples
- **QUICK_START.txt** - Quick reference

---

## 🔗 Resources

- [HackerNews API](https://github.com/HackerNews/API)
- [jq Manual](https://stedolan.github.io/jq/manual/)
- [Markdown Guide](https://www.markdownguide.org/)

---

## 📝 License

Based on the public HackerNews API provided by Y Combinator.

---

## 💡 Tips

1. **Save bandwidth**: Keep JSON files for reprocessing instead of re-fetching
2. **Parallel processing**: Convert multiple JSON files to Markdown
3. **Automation**: Add to cron jobs for periodic fetching
4. **Filtering**: Use jq to pre-process data before converting to Markdown
5. **Testing**: Edit scripts to fetch fewer posts for quick testing

---

## Examples

### Create daily digest
```bash
DATE=$(date +%Y%m%d)
./fetch_and_convert.sh "hn_digest_$DATE"
```

### Track trending topics
```bash
./fetch_best_posts.sh daily.json
jq '.posts | map(.title) | unique' daily.json > topics.txt
```

### Find discussion threads
```bash
jq '.posts[] | select(.descendants > 100) | {title, descendants}' hn_posts.json
```

---

Created: 2026-06-16
