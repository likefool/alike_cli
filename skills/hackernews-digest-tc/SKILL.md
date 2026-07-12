---
name: hackernews-digest-tc
description: "Fetches top 20 HackerNews best posts with comments and generates comprehensive Traditional Chinese summaries with analysis, trends, and insights. Perfect for daily tech news briefing in Chinese. Use when user asks for HackerNews digest in Traditional Chinese or requests /digest-hn."
---

# HackerNews Digest Traditional Chinese

從 HackerNews 最佳文章中自動抓取當日前 20 篇熱門貼文及評論，透過 AI 分析生成傳統中文精選摘要。

## 命令

### `/digest-hn`

執行 HackerNews 傳統中文摘要生成器。

**使用方式**: 輸入 `/digest-hn`，Agent 會執行完整工作流程：
1. 從 HackerNews API 抓取 20 篇最佳文章
2. 抓取每篇文章的評論
3. 轉換為 Markdown 格式
4. 生成傳統中文摘要

---

## 指令碼目錄

**重要**: 所有指令碼位於此 skill 的 `scripts/` 檔案。

**Agent 執行說明**:
1. 確定此 SKILL.md 檔案的目錄路徑為 `SKILL_DIR`
2. 指令碼路徑 = `${SKILL_DIR}/scripts`
3. 以 bash 執行: `bash ${SKILL_DIR}/scripts`

---

## 功能特性

### 🔄 完整工作流程

1. **資料抓取** (2-5 分鐘)
   - 從 HackerNews API 抓取 20 篇最佳文章
   - 每篇文章最多抓取 20 則評論
   - 共約 260 次 API 呼叫
   - 輸出清潔的 JSON 格式

2. **Markdown 轉換** (<1 秒)
   - 將 JSON 轉換為可讀的 Markdown
   - 包含作者連結到 HackerNews 個人頁面
   - 保留完整評論和元數據

3. **傳統中文摘要** (<2 秒)
   - 分析前 20 篇文章
   - 建立排名總覽表
   - 提供前 5 名深度分析
   - 按類別組織文章
   - 合成社群情感
   - 生成優先閱讀指南
   - 統計指標

### 📊 輸出內容

✅ **排名概覽表** - 分數、標題、評論數  
✅ **Top 5 深度分析** - 完整內容 + 社群反應  
✅ **類別分組** - 技術、AI、太空、政策等  
✅ **趨勢分析** - 社群討論模式  
✅ **優先閱讀** - 按重要性排序  
✅ **每日統計** - 文章、評論、參與度指標  

---

## 系統需求

### 必需軟體
- `bash` 4.0+
- `curl` - HTTP 請求工具
- `jq` 1.6+ - JSON 處理工具

### 網路
- 網際網路連線
- 可訪問 hacker-news.firebaseio.com（不需認證）

### 儲存
- 約 200 KB 暫存空間
- 輸出檔案 6-8 KB（傳統中文摘要）

---

## 安裝依賴

```bash
# Ubuntu/Debian
sudo apt-get install curl jq

# macOS
brew install curl jq
```

---

## 使用範例

### 基本用法
```bash
Agent: "生成今天的 HackerNews 摘要，用傳統中文"

結果:
- 抓取 20 篇最佳文章
- 收集評論資料
- 生成傳統中文摘要
- 輸出可供使用的 Markdown 檔案
```

### 自訂輸出名稱
```bash
Agent: "生成 HackerNews 摘要，並命名為 hn_20260712_summary"

結果:
- 生成並保存至指定檔案名稱
```

### 自動排程
```bash
# 每天上午 9 點生成摘要
0 9 * * * bash /path/to/skill/scripts
```

---

## 輸出檔案說明

| 檔案 | 大小 | 用途 |
|-----|------|------|
| `hn_posts.json` | 90-100 KB | 原始資料（用於再分析） |
| `hn_posts.md` | 90-100 KB | 完整 Markdown（含所有評論） |
| `hn_posts_tc.md` | 6-8 KB | 傳統中文摘要（已發佈） |

---

## 效能指標

| 操作 | 耗時 | 備註 |
|-----|------|------|
| 抓取貼文與評論 | 2-5 分鐘 | ~260 次 API 呼叫 |
| 轉換 JSON → Markdown | <1 秒 | jq 處理 |
| 生成傳統中文 | <2 秒 | 合成和分析 |
| **總計** | **2-5 分鐘** | **完整流程** |

---

## 設定和自訂

### 調整文章數量（測試）
編輯指令碼中的第 14 行：
```bash
STORY_IDS=$(echo "$BEST_STORIES" | jq -r '.[0:10][]')  # 抓取 10 篇而非 20 篇
```

### 修改每篇評論數量
編輯指令碼中的第 28 行：
```bash
COMMENT_IDS=$(echo "$STORY" | jq -r '.kids[0:50][]? // empty')  # 50 則而非 20 則
```

---

## 疑難排除

### 問題: "command not found: jq"
```bash
sudo apt-get install jq  # Linux
brew install jq          # macOS
```

### 問題: "Permission denied"
```bash
chmod +x /home/alikebox/dev/alike_cli/skills/hackernews-digest-tc/scripts
```

### 問題: API 連線逾時
- 檢查網際網路連線
- 測試 API: `curl https://hacker-news.firebaseio.com/v0/beststories.json`
- 稍後重試

### 問題: JSON 檔案為空
- 驗證網路連線
- 檢查 HackerNews API 狀態
- 嘗試使用較少貼文（編輯指令碼）

---

## 進階用法

### 篩選和查詢結果
```bash
# 找最高評分文章
jq '.posts | sort_by(.score) | reverse | .[0:5]' hn_posts.json

# 只取評論超過 100 則的文章
jq '.posts[] | select(.descendants > 100)' hn_posts.json

# 匯出為 CSV
jq -r '.posts[] | [.id, .title, .score, .by] | @csv' hn_posts.json > posts.csv
```

### 集成其他工具
```bash
# 轉換為 PDF（需要 pandoc）
pandoc hn_posts_tc.md -o hn_posts_tc.pdf

# 透過電子郵件發送
mail -s "HackerNews 摘要" user@example.com < hn_posts_tc.md
```

---

## 相關資源

- [HackerNews API 文檔](https://github.com/HackerNews/API)
- [jq 手冊](https://stedolan.github.io/jq/manual/)
- [Markdown 指南](https://www.markdownguide.org/)
- [Agent Skills 規格](https://agentskills.io)

---

## 訣竅與最佳實踐

1. **排程執行**: 每天在同一時間執行摘要
2. **重複使用 JSON**: 保留 JSON 檔案以供再分析
3. **備份檔案**: 保存每日摘要以供歷史分析
4. **按類別篩選**: 使用 jq 預先處理資料再分享
5. **追蹤趨勢**: 比較多日摘要以發現模式

---

## 版本資訊

- **Skill 版本**: 1.0
- **建立日期**: 2026-07-12
- **最後更新**: 2026-07-12
- **相容性**: Claude 3.5 Sonnet 及以上
- **位置**: `/home/alikebox/dev/alike_cli/skills/hackernews-digest-tc/`

---

## 建立者備註

此 Skill 代表一個完整、生產就緒的工作流程，用於生成每日 HackerNews 摘要（傳統中文）。它結合了資料抓取、分析和合成，成為一個可重複使用的 Agent Skill，可以自然語言呼叫。

該 Skill 設計用於：
- **自給自足**: 所有指令碼和文檔已包含
- **可組合**: 可與其他 Skill 一起使用
- **可擴展**: 易於修改和增強
- **可靠**: 包含錯誤處理和驗證
- **文檔齊全**: 包含多份參考文檔

---

準備就緒，可立即上傳和使用！
