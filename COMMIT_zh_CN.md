# Git Commit Message 规范

关于项目 Git Commit 的规范说明。

## Git Commit Message 格式

```
<Type>(<scope>):<subject> //标题

<body>                    //内容详情

<footer>                  //结尾
```

对上述的字段说明如下：

### Type

- feat：新功能（feature）
- fix：修补八阿哥
- docs：文档（documentation）
- style：格式（不影响代码运行的变动）
- refactor：重构
- test：测试用例
- chore：构建过程或者辅助工具的变动

### Scope

用来说明本次 Git Commit 影响的范围，简要说明修改会涉及的文件。

### Subject

简要概述 Git Commit 的内容，详细说明会在 Body 中给出。
- 以动词开头，使用第一人称现在时
- 首字母不要大写
- 结尾不要句号

### Body

对上面 Subject 中内容的详细展开。

### Footer

主要放置不兼容变更、 Issue 关闭的信息以及 PR Merge 信息。
