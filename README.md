# IsaacLab Server Training (Docker Compose Template)

本仓库用于在服务器上通过 **Docker + Docker Compose** 运行 IsaacLab / Isaac Sim 的训练任务。支持：
- 选择 GPU（通过 `CUDA_VISIBLE_DEVICES`）
- 挂载宿主机工作区源码到容器内运行（通过 `WORKSPACE`）
- 持久化 Isaac Sim 缓存/日志/数据（避免每次容器重建都重新下载/编译）
- 可选接入 **Weights & Biases (wandb)** 记录实验

> 设计理念：容器提供“训练环境”（Isaac Sim/IsaacLab 运行环境）；宿主机提供“项目代码 + 可持久化产物”。

---

## 目录结构（约定）

- `docker-compose.yaml`  
  定义基础服务 `isaac-lab`（镜像、GPU runtime、通用环境变量、缓存/日志/数据挂载等）。

- `python.sh`  
  推荐的训练入口脚本（在宿主机执行）。负责：
  - 选择 GPU：`CUDA_VISIBLE_DEVICES=<id>`
  - 指定工作区路径：`WORKSPACE=<path>`
  - 创建一次性训练容器并传参
  - 容器命名：`${USER}-isaac-lab-gpu${CUDA}`

- `scripts/run.sh`  
  容器内启动脚本：设置渲染相关环境（可选 noVNC），进入工作区，按需安装本地 editable 包，然后启动 IsaacLab 运行入口。

- `isaac-sim/`  
  宿主机侧的 Isaac Sim/Omniverse 运行期目录（cache/log/data/documents）。  
  **注意：该目录内容默认不进入 git，仅保留骨架。**

- `netrc.example`  
  `~/.netrc` 模板（用于 wandb 等需要认证的工具）。真实 `netrc` 不应提交到 git。

---

## 前置要求（服务器）

- Ubuntu 22.04（或同类 Linux）
- NVIDIA Driver 正常 + GPU 可用
- Docker + Docker Compose（plugin 版本均可）
- 当前用户具备运行 docker 的权限（建议加入 `docker` 组；如仍需要 sudo，按服务器规范操作）

---

## 快速开始

### 1) 初始化认证（可选：W&B）

如果你需要 wandb 记录实验：

```bash
cp config/netrc.example ~/.netrc
# 编辑 netrc，将 YOUR_WANDB_API_KEY_HERE 替换为你的 key
chmod 600 ~/.netrc
```

> `netrc` 为敏感信息，默认被 `.gitignore` 忽略，不要提交。

---

### 2) 选择 GPU + 指定工作区并启动训练

基本用法：

```bash
CUDA_VISIBLE_DEVICES=1 WORKSPACE=/abs/path/to/your_project ./python.sh <your_entry.py> <args...>
```

示例（rsl_rl）：

```bash
CUDA_VISIBLE_DEVICES=1 WORKSPACE=~/isaac_ws/IsaacLab \
  ./python.sh scripts/reinforcement_learning/rsl_rl/train.py \
  --task=Isaac-Velocity-Rough-Anymal-C-v0 --headless
```

说明：
- `CUDA_VISIBLE_DEVICES=1`：在容器内只暴露 1 号 GPU。容器内部会把“可见的第一张 GPU”重映射为 `cuda:0`（属预期行为）。
- `WORKSPACE=...`：宿主机上的项目路径，会被挂载到容器内（通常是 `/workspace/Project`，以 `python.sh` 为准）。
- `./python.sh ...`：通过 compose 启动一次性训练容器，并将参数传递给容器内的启动脚本。

---

### 3) 停止训练容器

容器名约定：`${USER}-isaac-lab-gpu${CUDA}`  
例如用户 `swarm-rl` 在 GPU 1 上：`swarm-rl-isaac-lab-gpu1`

停止示例：

```bash
docker stop ${USER}-isaac-lab-gpu1
```

⚠️ 注意不要误停其他人的容器。

---

## 数据与缓存（重要）

`docker-compose.yaml` 将 Isaac Sim / Omniverse 的运行期产物挂载到宿主机 `./isaac-sim/`，用于 **加速 + 持久化**，典型包括：
- Kit / OV / pip 缓存
- GLCache / ComputeCache
- Omniverse logs
- Omniverse data
- Documents

这些目录是运行期产物：
- **不要提交到 git**
- 建议放在大盘/数据盘（避免占满 `/` 导致系统异常）

---

## 常见问题（FAQ）

### Q1: 我设置了 `CUDA_VISIBLE_DEVICES=1`，为什么日志里显示 `cuda:0`？
容器内仅暴露 1 号 GPU 后，该 GPU 在容器内会被重新编号为 `0`（即 `cuda:0`）。这是预期行为。

### Q2: 我不需要 wandb，是否必须配置 netrc？
不需要。你可以不创建 `netrc`，或在训练配置中关闭 wandb（或设置 `WANDB_MODE=disabled`）。

---

## TODO（后续补充）
- [ ] 说明如何将 `isaac-sim/` 放到数据盘（软链接/绑定挂载）
- [ ] noVNC / 端口映射的使用说明与示例
- [ ] 多用户共用服务器的磁盘/权限最佳实践
- [ ] 常见错误排查（editable 安装路径、protobuf 版本冲突、GPU “bad state”等）

---

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