
## 初始化 sandbox

```bash
sbx run --name rumao claude . /d/mmm/repos/dotfiles/

sbx exec -it rumao bash
cd /d/mmm/repos/dotfiles && bash sbx/setup.sh
```

## 啟動

```bash
# 串接 discord
sbx run rumao -- --channels plugin:discord@claude-plugins-official
```

## 更新

```bash
# optional
winget upgrade Docker.sbx

sbx template ls
sbx template rm docker/sandbox-templates:claude-code-docker

sbx rm rumao
sbx run --name rumao claude . /d/mmm/repos/dotfiles/
```