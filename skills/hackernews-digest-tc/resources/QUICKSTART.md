# Quick Start Guide - HackerNews Digest TC Skill

## 30-Second Setup

```bash
# 1. Ensure dependencies installed
sudo apt-get install curl jq  # Linux
brew install curl jq          # macOS

# 2. Make scripts executable
chmod +x /home/alikebox/dev/alike_cli/script/hackernews_best/*.sh
chmod +x /home/alikebox/dev/alike_cli/skills/hackernews-digest-tc/generate_tc_summary.sh
```

## Generate Today's Digest

### Option A: Simple One-Liner
```bash
cd /home/alikebox/dev/alike_cli/script/hackernews_best && \
./fetch_and_convert.sh hn_digest && \
../skills/hackernews-digest-tc/generate_tc_summary.sh hn_digest.json /tmp/hn_digest_tc.md
```

### Option B: Step-by-Step
```bash
# Step 1: Fetch posts and comments (2-5 minutes)
cd /home/alikebox/dev/alike_cli/script/hackernews_best
./fetch_best_posts.sh hn_posts.json

# Step 2: Convert to markdown
./json_to_markdown.sh hn_posts.json hn_posts.md

# Step 3: Generate Traditional Chinese summary
../skills/hackernews-digest-tc/generate_tc_summary.sh hn_posts.json hn_posts_tc.md
```

### Option C: Using fetch_and_convert
```bash
cd /home/alikebox/dev/alike_cli/script/hackernews_best
./fetch_and_convert.sh hn_$(date +%Y%m%d)
../skills/hackernews-digest-tc/generate_tc_summary.sh hn_$(date +%Y%m%d).json hn_$(date +%Y%m%d)_tc.md
cp hn_$(date +%Y%m%d)_tc.md /tmp/
```

## View Your Digest

```bash
# View in terminal
cat /tmp/hn_digest_tc.md

# Or open in editor
nano /tmp/hn_digest_tc.md
vim /tmp/hn_digest_tc.md

# Or convert to PDF (requires pandoc)
pandoc /tmp/hn_digest_tc.md -o /tmp/hn_digest_tc.pdf
```

## Common Tasks

### Save with Custom Name
```bash
../skills/hackernews-digest-tc/generate_tc_summary.sh hn_posts.json /tmp/20260712_hn_summary.md
```

### Combine Both Outputs
```bash
# Keep both markdown and TC summary
./fetch_and_convert.sh hn_digest
../skills/hackernews-digest-tc/generate_tc_summary.sh hn_digest.json hn_digest_tc.md

# Now you have:
# - hn_digest.json      (raw data)
# - hn_digest.md        (full markdown with all comments)
# - hn_digest_tc.md     (compressed TC summary)
```

### Email the Summary
```bash
# Send via mail command
mail -s "HackerNews 最佳文章摘要 $(date +%Y%m%d)" user@example.com < /tmp/hn_digest_tc.md

# Or with attachment
echo "See attached summary" | mail -s "HackerNews Digest" -a /tmp/hn_digest_tc.md user@example.com
```

### Schedule Daily Digest
```bash
# Edit crontab
crontab -e

# Add this line (runs daily at 9 AM)
0 9 * * * cd /home/alikebox/dev/alike_cli/script/hackernews_best && \
./fetch_and_convert.sh hn_$(date +\%Y\%m\%d) && \
../skills/hackernews-digest-tc/generate_tc_summary.sh hn_$(date +\%Y\%m\%d).json /tmp/hn_daily_tc.md
```

## What You Get

✅ **Traditional Chinese summary** with:
- 📊 Ranked article overview table
- 🔥 Top 5 deep-dive analysis
- 📈 Categorized article listings
- 💡 Trend analysis
- 🎯 Reading priorities
- 📊 Daily statistics

✅ **Files created:**
- `hn_digest.json` - Raw data for analysis
- `hn_digest.md` - Full markdown (all comments)
- `hn_digest_tc.md` - Compressed TC summary (ready to share)

## Typical Runtime

| Step | Time | Notes |
|------|------|-------|
| Fetch posts | 2-5 min | ~260 API calls |
| Convert Markdown | <1 sec | jq processing |
| Generate TC | <2 sec | Synthesis |
| **Total** | **2-5 min** | Full pipeline |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "command not found: jq" | `sudo apt-get install jq` or `brew install jq` |
| "Permission denied" | `chmod +x *.sh` |
| Script hangs | Check internet connection, try again |
| Empty file | Verify API: `curl https://hacker-news.firebaseio.com/v0/beststories.json` |

## Next Steps

1. **Schedule it**: Add to cron for daily digests
2. **Automate sharing**: Email or post digest daily
3. **Archive**: Keep digests for trend analysis
4. **Customize**: Modify scripts to focus on topics you care about

## File Locations

```
/home/alikebox/dev/alike_cli/
├── script/hackernews_best/
│   ├── fetch_best_posts.sh
│   ├── json_to_markdown.sh
│   └── fetch_and_convert.sh
└── skills/hackernews-digest-tc/
    ├── skill.md
    ├── generate_tc_summary.sh
    └── resources/
        ├── IMPLEMENTATION.md
        ├── QUICKSTART.md (this file)
        └── EXAMPLES.md
```

## Need Help?

- **Read full docs**: See `IMPLEMENTATION.md`
- **See examples**: Check `EXAMPLES.md`
- **Check logs**: Run script with debug: `bash -x script_name.sh`
