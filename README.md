# Isaac-Server-Docker

## Git 协作标准

一个标准的 Commit Message 由三个部分组成：

1.  Header（题目）： 必需。包含类型、影响范围和简短描述。
2.  Body（正文）： 可选。详细描述修改的原因和逻辑。
3.  Footer（脚注）： 可选。用于破坏性变更声明或关联 Issue。

```text
<type>(<scope>): <subject>
// 空一行
<body>
// 空一行
<footer>
```

1.  `<type>` (类型)
      * 定义： 用于说明 commit 的类别，只允许使用规定的关键字。
      * 目的： 让阅读者一目了然地知道这次提交是加了功能、修了 Bug 还是仅仅修改了文档。
      * 常见枚举值（工程通用）：

| 类型 (Type) | 含义 (Meaning) | 详细说明 |
| :--- | :--- | :--- |
| feat | Feature | 新增功能（对应用户层面的更新）。 |
| fix | Fix | 修复 Bug（对应用户层面的修复）。 |
| docs | Documentation | 仅修改了文档（如 README, API 文档）。 |
| style | Style | 不影响代码运行逻辑的格式修改（空格、缩进、分号等，非 CSS 样式）。 |
| refactor | Refactoring | 代码重构（既不修复 Bug 也不添加功能，优化结构）。 |
| perf | Performance | 提升性能的代码更改。 |
| test | Test | 增加测试或更新现有的测试用例。 |
| chore | Chore | 构建过程或辅助工具的变动（如 build.gradle, package.json, CI 配置）。 |
| revert | Revert | 回滚上一次的 commit。 |

2.  `(<scope>)` (范围)

      * 定义： 用于说明 commit 影响的范围。
      * 用法： 通常是文件名、模块名或层级名。
      * 示例： `feat(auth): ...`, `fix(utils): ...`, `style(navbar): ...`

3.  `<subject>` (简述)

      * 定义： commit 的简短描述，不超过 50 个字符。
      * 书写原则：
          * 以动词开头，使用第一人称现在时（Imperative mood）。例如使用 "change" 而不是 "changed" 或 "changes"。
          * 第一个字母不要大写（除非是专有名词）。
          * 结尾不要加句号。
      * 中文语境： 中文团队通常允许使用中文，原则是“动宾结构”，如“修复登录页崩溃问题”。

4.  `<body>` (正文)

      * 定义： 对本次 commit 的详细描述。
      * 内容： 应该回答“为什么要做这次修改”以及“怎么修改的”（如果逻辑复杂）。
      * 格式： 每行文字建议在 72 个字符处换行，避免在 git log 中显示错乱。

5.  `<footer>` (脚注)

      * 定义： 用于记录不兼容的变动（Breaking Changes）或关闭 Issue。
      * 示例：
          * `BREAKING CHANGE: The API definition of 'getUser' has changed.`
          * `Closes #123` (自动关闭 GitHub/GitLab 上的 Issue \#123)。


Bad Case:
```
> commit message:
> `fix bug`
```

Good Case

```
> commit message:
>
> ```text
> fix(user-service): handle null pointer exception in login
> ```

> Check strictly for user existence before validating password.
> Previously, a non-existent user id would crash the service.

> Closes \#45
```

### 辅助工具推荐 (Recommended Tools)

1.  Commitizen (`cz-cli`): 一个撰写合格 Commit message 的工具。当你运行 `git cz` 代替 `git commit` 时，它会通过交互式命令行引导你选择 type、填写 scope 等，自动生成符合规范的提交信息。

2. Husky + Commitlint
  * Husky: Git Hooks 工具，可以在你执行 `git commit` 之前拦截操作。
  * Commitlint: 检查提交信息是否符合规则。
  * 如果你写了 `fix bug` 这种不规范的信息，Commitlint 会直接报错，拒绝你的提交，直到你修改正确为止。

-----