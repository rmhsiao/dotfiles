# git commit message 尾端洩漏前一筆 commit 內容

## 症狀

新建 commit 的 message 尾端被附加上「前一筆（或更舊）commit message
的尾段」，洩漏邊界處可能出現亂碼。具體可觀察到：

1. **commit body 比寫進去的長很多**：用 `-m "..."` 或 `-F file` 給 git
   一段短訊息，但 `git log -1 --format=%B | wc -c` 算出來的 byte 數遠大於
   原始輸入。例如給 10 byte 的 `"test: tiny"`，最終 commit message 變成
   1336 byte。
2. **subject 行被「貼合」**：commit subject 看起來像
   `<你的 subject><前一筆 subject 的尾段>`，因為新內容只覆蓋了前面 N
   個 byte，後面舊內容的開頭剛好接在 subject 行上。
3. **邊界亂碼（次要徵兆）**：洩漏段落起頭可能出現 `��`、`¾`、`¤`、`¹`、
   `Â` 等字元——通常是 UTF-8 多 byte 字元（中文 3 byte、emoji 4 byte）
   被切在中間，剩下的 continuation bytes 沒有合法前綴 byte。

範例（以 `git commit -m "test: tiny"` 觸發）：

```
$ git commit -m "test: tiny"
[feature/x b7dc42a] test: tiny chestrator): 以 try/finally 改寫例外清理
                              ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
                              這段是上一筆 commit subject 從第 11 byte
                              起的尾段（"orchestrator" 的 "or" 被
                              "ny" 蓋掉、剩 "chestrator..."）
```

## 根因

**主因（已直接驗證）**：git 把 commit message 寫進 `.git/COMMIT_EDITMSG`
這個內部緩存檔，再從同一份檔案讀回來做 commit。在 sandbox 的 overlay fs
上，「開檔覆寫」（`open(O_WRONLY | O_TRUNC)` 或等價操作）的 **truncate
語意沒有生效**：新內容只覆蓋從 offset 0 起的 N byte，檔案長度沒被縮到 N，
原本第 N byte 之後的舊內容仍留在檔尾。git 接著讀回整份檔案當訊息來源，
新內容後面就接上舊殘留。

`-m`、`-F`、編輯器互動三種途徑都會經過 `.git/COMMIT_EDITMSG`，因此都會
踩到。

**次要觀察（機制未完全追到）**：洩漏段落的起頭常見 `0xC2 0xXX`（U+0080
~U+00FF 的 latin-1 supplement 在 UTF-8 下的 2 byte 編碼）。這跟「UTF-8
多 byte 字元被切在中間、剩下的 continuation byte 在某處被 latin-1 重新
解碼／編碼」的形狀一致，但具體在哪一步發生這個 round-trip 沒有直接證據
（git 本身對 commit message 是 byte-透明的）。實務上把「邊界亂碼」當
**輔助指紋**，不要當主要診斷依據。

## 偵測方式

**1. 比對「給的訊息長度」vs「commit 後的訊息長度」**

最直接的指紋：

```bash
# 假設 /tmp/msg.txt 是你給 -F 的訊息
wc -c /tmp/msg.txt
git log -1 --format=%B | wc -c
```

兩者差距大（不是只差 1 byte trailing newline），就是洩漏。

**2. 檢查 `.git/COMMIT_EDITMSG` 殘留**

```bash
wc -c .git/COMMIT_EDITMSG   # 跟你給 git 的訊息長度比
tail -c 200 .git/COMMIT_EDITMSG | od -c | head
```

若檔案比你給的訊息大、且尾端是某個舊 commit 的內容片段，根因確認。

**3. 搜疑似邊界亂碼的歷史 commits（非必要）**

```bash
git log --pretty=format:%H | while read h; do
  git log -1 --format=%B "$h" \
    | grep -qP '\xC2[\x80-\xA0\xAD\xBE]' \
    && echo "SUSPECT: $h"
done | head
```

這些 codepoints 在合法中文 commit message 中極少出現。**只是輔助指紋，
不一定都是這個 bug**。

## 解法

### 預防（推薦）

每次 commit 前先刪掉 `.git/COMMIT_EDITMSG`，逼 git 從乾淨狀態建立檔：

```bash
[ -f .git/COMMIT_EDITMSG ] && rm .git/COMMIT_EDITMSG
git commit ...
```

`[ -f ... ]` 守衛是為了 fresh clone 情境（檔還不存在時）不要報錯打斷
後續 `git commit`。也已寫進 global CLAUDE.md 的 `## Sandbox
Environment` 區塊。

### 已被污染、尚未 push 的 commit

`git reset --soft HEAD~N` 退回 staged 狀態，刪掉 `.git/COMMIT_EDITMSG`
後重新 `git commit -F <乾淨訊息檔>`。

### 已被污染、已 push 的 commit

不要 rebase 改寫 SHA，會打掉 PR review reference / discussion 連結。在
PR 描述或本檔案留檔即可。

## 適用環境

- 跑在 overlay fs 之上的容器化 sandbox（典型：Docker / 本 sandbox 環境，
  rootfs 由 lower + upper 疊起來）。
- 一般開發機（ext4 / APFS / NTFS）不會踩到這個 truncate quirk，這條
  workaround 在那裡是 no-op。
