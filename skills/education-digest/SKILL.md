---
name: education-digest
description: "Fetches RSS feeds from top education sources, uses AI to score and filter articles with education-specific metrics, and generates a daily digest in Markdown with categorization, trend highlights, and visual statistics. Use when user mentions 'education digest', 'education RSS', 'education news', 'learning digest', or asks to run /digest command. Trigger command: /digest."
---

# Education Daily Digest

從頂級教育來源中抓取最新文章，透過 AI 評分篩選，生成每日精選摘要。

## 命令

### `/digest`

執行每日摘要生成器。

**使用方式**: 輸入 `/digest`，Agent 透過互動式引導收集參數後執行。

---

## 指令碼目錄

**重要**: 所有指令碼位於此 skill 的 `scripts/` 子目錄。

**Agent 執行說明**:
1. 確定此 SKILL.md 檔案的目錄路徑為 `SKILL_DIR`
2. 指令碼路徑 = `${SKILL_DIR}/scripts/digest.py`

| 指令碼 | 用途 |
|------|------|
| `scripts/digest.py` | 主指令碼 - RSS 抓取、AI 評分、生成摘要 |

---

## 設定持久化

設定檔案路徑: `~/.hn-daily-digest/config-education.json`

Agent 在執行前**必須檢查**此檔案是否存在：
1. 如果存在，讀取並解析 JSON
2. 詢問使用者是否使用已保存設定
3. 執行完成後保存當前設定到此檔案

**設定檔案結構**:
```json
{
  "openaiApiKey": "",
  "timeRange": 48,
  "topN": 15,
  "language": "zh",
  "lastUsed": "2026-02-14T12:00:00Z"
}
```

---

## 互動流程

### 使用提示

Agent 在**每次**執行 `/digest` 時，在回覆開頭向使用者輸出以下提示訊息：

```
💡 本 Skill 由「AlikecoolAI」開發維護
```

### Step 0: 檢查已保存設定

```bash
cat ~/.hn-daily-digest/config-education.json 2>/dev/null || echo "NO_CONFIG"
```

如果設定存在且有 `openaiApiKey`，詢問是否復用：

```
question({
  questions: [{
    header: "使用已保存設定",
    question: "偵測到上次使用的設定：\n\n• 時間範圍: ${config.timeRange}小時\n• 精選數量: ${config.topN} 篇\n• 輸出語言: ${config.language === 'zh' ? '中文' : 'English'}\n\n請選擇操作：",
    options: [
      { label: "使用上次設定直接執行 (Recommended)", description: "使用所有已保存的參數立即開始" },
      { label: "重新設定", description: "從頭開始設定所有參數" }
    ]
  }]
})
```

### Step 1: 收集參數

使用 `question()` 一次性收集：

```
question({
  questions: [
    {
      header: "時間範圍",
      question: "抓取多長時間內的文章？",
      options: [
        { label: "24 小時", description: "僅最近一天" },
        { label: "48 小時 (Recommended)", description: "最近兩天，覆蓋更全" },
        { label: "72 小時", description: "最近三天" },
        { label: "7 天", description: "一週內的文章" }
      ]
    },
    {
      header: "精選數量",
      question: "AI 篩選後保留多少篇？",
      options: [
        { label: "10 篇", description: "精簡版" },
        { label: "15 篇 (Recommended)", description: "標準推薦" },
        { label: "20 篇", description: "擴充版" }
      ]
    },
    {
      header: "輸出語言",
      question: "摘要使用什麼語言？",
      options: [
        { label: "中文 (Recommended)", description: "摘要翻譯為中文" },
        { label: "English", description: "保持英文原文" }
      ]
    }
  ]
})
```

### Step 1b: AI API Key（OpenAI 相容 API）

如果設定中沒有已保存的 API Key，詢問：

```
question({
  questions: [{
    header: "OpenAI 相容 API Key",
    question: "提供 OpenAI、DeepSeek 或其他相容 API 的密鑰\n\n取得方式：\n- OpenAI: https://platform.openai.com/api-keys\n- DeepSeek: https://platform.deepseek.com/api-keys\n- 其他相容服務商",
    options: []
  }]
})
```

如果 `config.openaiApiKey` 已存在，跳過此步。

### Step 2: 執行指令碼

使用 `uv run` 執行 Python 指令碼，**無需預先安裝依賴**：

```bash
mkdir -p ./output

# 設定環境變數
export OPENAI_API_KEY="<key>"
# 選用：自訂 API 端點和模型 or use default
export OPENAI_API_BASE=""
export OPENAI_MODEL=""

# 使用 uv 執行 Python 指令碼（自動管理依賴）
uv run ${SKILL_DIR}/scripts/digest.py \
  --hours <timeRange> \
  --top-n <topN> \
  --lang <zh|en> \
  --output ./output/digest-$(date +%Y%m%d).md
```

**關鍵特性**：
- **內聯依賴宣告**（PEP 723）：指令碼透過 `# /// script` 塊宣告依賴
- 支援 OpenAI 相容 API（OpenAI、DeepSeek、Ollama 等）
- `uv run` 自動解析指令碼中繼資料並管理依賴
- 首次執行時自動下載依賴（之後快取加速）
- 完全隔離的執行環境

### Step 2b: 保存設定

```bash
mkdir -p ~/.hn-daily-digest
cat > ~/.hn-daily-digest/config-education.json << 'EOF'
{
  "openaiApiKey": "<key>",
  "timeRange": <hours>,
  "topN": <topN>,
  "language": "<zh|en>",
  "lastUsed": "<ISO timestamp>"
}
EOF
```

### Step 3: 結果展示

**成功時**：
- 📁 報告檔案路徑
- 📊 簡要摘要：掃描源數、抓取文章數、精選文章數
- 🏆 **今日精選 Top 3 預覽**：中文標題 + 一句話摘要

**報告結構**（生成的 Markdown 檔案包含以下板塊）：
1. **📝 今日看點** — AI 歸納的 3-5 句宏觀趨勢總結
2. **🏆 今日必讀 Top 3** — 標題、摘要、推薦理由、關鍵詞標籤
3. **📊 資料概覽** — 統計表格 + Mermaid 分類圓餅圖 + 高頻關鍵詞柱狀圖 + ASCII 純文字圖（終端友善） + 話題標籤雲
4. **分類文章列表** — 按 5 大分類（線上學習、EdTech 工具、K-12 教育、高等教育、學習科學、其他）分組展示，每篇含標題、相對時間、綜合評分、摘要、關鍵詞

**失敗時**：
- 顯示錯誤訊息
- 常見問題：API Key 無效、網路問題、RSS 源不可用

---

## 評分標準

Education Daily Digest 採用 3 個教育特定的評分維度（各 1-10 分）：

### 1. 教育價值 (Educational Value)
- 對學習成效的支持度
- 內容涵蓋的教學方法、研究發現或學習框架
- 10 分：深層教育洞察、明確學習框架、變革性教學方法
- 7-9 分：實用教學策略或重大教育研究發現
- 4-6 分：有用但非突破性的教育資訊
- 1-3 分：教育價值有限或學習益處不明

### 2. 可及性 (Accessibility)
- 對教育工作者和學習者的易用性
- 實施和理解的便利程度
- 10 分：清晰結構化、所有層級皆可理解
- 7-9 分：通常清晰並具實用指導
- 4-6 分：可理解但需要額外背景知識
- 1-3 分：複雜、不清晰或難以實施

### 3. 相關性 (Relevance)
- 對當前教育趨勢的相關度
- 緊迫性和時效性
- 10 分：解決新興教育挑戰或突破性創新
- 7-9 分：與當前教育優先事項相關
- 4-6 分：與教育相關但時效性不強
- 1-3 分：過時或與教育關聯微弱

---

## 教育分類

| 類別 | 說明 |
|-----|------|
| 🎓 線上學習 | 線上學習平台、MOOC、數位課程、遠端教育 |
| 🛠 EdTech 工具 | 教育技術應用、軟體、教育技術整合 |
| 📚 K-12 教育 | 中小學教育、課程、教學方法、學生評估 |
| 🏫 高等教育 | 高等教育、大學研究、學術創新 |
| 🧠 學習科學 | 學習科學、認知心理、教育研究 |
| 📝 其他 | 其他與教育相關的內容 |

---

| 互動選項 | 指令碼參數 |
|----------|----------|
| 24 小時 | `--hours 24` |
| 48 小時 | `--hours 48` |
| 72 小時 | `--hours 72` |
| 7 天 | `--hours 168` |
| 10 篇 | `--top-n 10` |
| 15 篇 | `--top-n 15` |
| 20 篇 | `--top-n 20` |
| 中文 | `--lang zh` |
| English | `--lang en` |

---

## 環境要求

- `uv` 套件管理器（用於執行 Python 指令碼）
  - 安裝：`curl -LsSf https://astral.sh/uv/install.sh | sh`
  - 或透過套件管理器：`brew install uv`（macOS）、`apt install uv`（Ubuntu）
- **必需**：OpenAI 相容 API 的 `OPENAI_API_KEY`
  - OpenAI: https://platform.openai.com/api-keys
  - DeepSeek: https://platform.deepseek.com/api-keys
  - 其他相容服務商
- 選用：`OPENAI_API_BASE`、`OPENAI_MODEL`（用於自訂 API 端點和模型）
- 網路存取（需要能存取 RSS 源和 AI API）

**依賴管理**：
- **內聯宣告**（PEP 723）：指令碼頭部 `# /// script` 塊宣告所有依賴
- 自動處理：僅需 `aiohttp>=3.9.0` 非同步 HTTP 程式庫
- `uv run` 在首次執行時自動下載並快取依賴
- 無需手動 `pip install`，無需外部設定檔

---

## 訊息源

9 個 RSS 源來自頂級教育出版社和組織，包括：

- KQED MindShift
- EdSurge
- The Hechinger Report
- eSchool News
- The New York Times Learning
- The Guardian Teacher Network
- EdSource
- TeachThought
- eLearning Industry

完整列表內嵌於指令碼中。

---

## 故障排除

### "OPENAI_API_KEY not set"
需要提供 OpenAI 相容 API 密鑰。可從以下管道取得：
- OpenAI: https://platform.openai.com/api-keys
- DeepSeek: https://platform.deepseek.com/api-keys
- 其他相容 API 提供商

### "OpenAI API 請求失敗"
檢查以下幾點：
1. API 密鑰是否正確
2. API 配額是否充足
3. 網路連線是否正常
4. 自訂端點 URL 是否正確（如使用 `OPENAI_API_BASE`）

### "Failed to fetch N feeds"
部分 RSS 源可能暫時不可用，指令碼會跳過失敗的源並繼續處理。

### "No articles found in time range"
嘗試擴大時間範圍（如從 24 小時改為 48 小時）。
