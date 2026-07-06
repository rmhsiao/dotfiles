# 104 人力銀行 API 規格

## Endpoint 1: Search API (職缺搜尋)

```
GET https://www.104.com.tw/jobs/search/api/jobs
```

**必備 headers**:

```python
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36",
    "Referer": "https://www.104.com.tw/jobs/search/",
}
```

沒帶 `Referer` API 會回傳錯誤或空資料。

**主要 query 參數** (完整對照表見 `codes.md`)

| 參數 | 說明 | 範例 |
|------|------|------|
| `keyword` | 搜尋關鍵字 | `LLM` / `AI工程師` |
| `area` | 地區代碼，多選用 `,` | `6001001000,6001002000` (北北) |
| `jobcat` | 職務類別代碼，多選用 `,` | `2007001020` (AI 工程師) |
| `isnew` | 多少天內更新 | `7` (一週內) / `30` (一個月) |
| `jobexp` | 經歷要求（年），多選用 `,` | `3,5` (1–3 年 + 3–5 年) |
| `edu` | 學歷要求 | `5` (碩士) |
| `remoteWork` | 遠端 | `1` 完全遠端 / `2` 部分遠端 |
| `order` | 排序 | `1` 符合度 / `2` 日期 / `13` 待遇 |
| `asc` | 排序方向 | `0` 由大到小 / `1` 由小到大 |
| `pagesize` | 每頁筆數 | `30` |
| `page` | 頁數 | `1` |

**Response schema** (已刪減為實際會用到的欄位):

```json
{
  "data": [
    {
      "jobName": "LLM 應用工程師 / LLM Application Engineer",
      "custName": "禾多移動多媒體股份有限公司",
      "jobAddrNoDesc": "台北市中山區",
      "appearDate": "20251110",
      "description": "【工作內容】...",
      "coIndustryDesc": "數位內容產業",
      "link": { "job": "https://www.104.com.tw/job/8t9ak" }
    }
  ],
  "metadata": {
    "pagination": {
      "count": 30,
      "currentPage": 1,
      "lastPage": 18,
      "total": 517
    }
  }
}
```

- `data[i].link.job` 的最後一段就是 **jobId** (給 Content API 用)
- `metadata.pagination.total` 判斷是否需要分頁

完整原始 response 還有 `hrBehaviorPR`、`interactionRecord`、`major` 等欄位，對評估職缺沒幫助，直接忽略。

## Endpoint 2: Content API (職缺詳細)

```
GET https://www.104.com.tw/job/ajax/content/{jobId}
```

**必備 headers**:

```python
headers = {
    "User-Agent": "Mozilla/5.0 ...",
    "Referer": f"https://www.104.com.tw/job/{job_id}",
}
```

注意 `Referer` 要帶具體的 `jobId`。

**Response 重點欄位** (其他忽略):

```json
{
  "data": {
    "header": {
      "jobName": "...",
      "appearDate": "2025/11/10",
      "custName": "...",
      "custUrl": "..."
    },
    "condition": {
      "workExp": "不拘" | "1年以上" | ...,
      "edu": "大學以上" | ...,
      "specialty": [
        { "description": "LLM" },
        { "description": "Python" }
      ]
    },
    "jobDetail": {
      "jobDescription": "...(full text)...",
      "jobCategory": [
        { "code": "2007001020", "description": "AI工程師" }
      ],
      "salary": "待遇面議" | "月薪 70000~100000 元" | ...,
      "salaryMin": 0 | <int>,
      "salaryMax": 0 | <int>,
      "salaryType": 10,
      "addressRegion": "台北市中山區",
      "remoteWork": null | 1 | 2
    },
    "welfare": {
      "tag": ["年終獎金", ...],
      "legalTag": ["週休二日", "勞保", ...]
    }
  }
}
```

## 請求慣例

```python
import time, requests

SEARCH_URL = "https://www.104.com.tw/jobs/search/api/jobs"
CONTENT_URL = "https://www.104.com.tw/job/ajax/content/{job_id}"

UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

def search(params):
    r = requests.get(
        SEARCH_URL,
        params=params,
        headers={"User-Agent": UA, "Referer": "https://www.104.com.tw/jobs/search/"},
        timeout=10,
    )
    r.raise_for_status()
    return r.json()

def content(job_id):
    r = requests.get(
        CONTENT_URL.format(job_id=job_id),
        headers={"User-Agent": UA, "Referer": f"https://www.104.com.tw/job/{job_id}"},
        timeout=10,
    )
    r.raise_for_status()
    return r.json()["data"]

def job_id_from_link(link_job):
    # e.g. "https://www.104.com.tw/job/8t9ak" -> "8t9ak"
    return link_job.rstrip("/").split("/")[-1]
```

**Rate limiting**: 兩個 API 共用額度。連續呼叫 Content API 時，每次間隔至少 0.5s。整個搜尋任務（search + top 5 contents）應在 1–2 分鐘內完成，不要用迴圈抓整個分頁。

**錯誤處理**:

- `HTTP 200` + response 沒有 `data`：視為 0 筆，不是錯誤
- `HTTP 403` / `429`: 被擋，立即停止後續所有請求，告訴使用者
- `HTTP 5xx`: 單次重試一次（sleep 2s），仍失敗就停
- `KeyError` 解析單一職缺：跳過該筆，繼續處理其他，最後在報告中註明「N 筆解析失敗」

**不要**做的事:
- 不要跑到第 5 頁以後 — 符合度排序下通常前 30–60 筆就夠了
- 不要對同一個 jobId 重複打 Content API — 結果在一次對話中是穩定的
