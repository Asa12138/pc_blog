# Tutorial 项目记忆

## 项目目的

本文件夹用于编写**中文博客教程**（R Markdown / `.Rmd` 文件），帮助本人学习 R 语言中的新包或新统计方法。每篇教程以一个 R 包或统计方法为主题，用中文讲解原理并附上可执行、可复现的 R 代码。

## 参考范式

写作格式参照已有博客：`/Users/asa/Documents/R/pc_blog2/content/post/2025-12-14-r-psm/index.en.Rmd`

该博客为 Hugo/blogdown 风格的站点（`content/post/YYYY-MM-DD-slug/index.en.Rmd`）。

### 文件结构惯例

- 文件名：`index.en.Rmd`（Hugo/blogdown 风格，虽然内容为中文）
- YAML frontmatter 字段：
  - `title`：中文标题
  - `author`：作者（示例为 `Peng Chen`）
  - `date`：日期（YYYY-MM-DD）
  - `slug`：URL 段
  - `categories`：主题类别（如 `R`）
  - `tags`：标签（如 `R`, `statistics`）
  - `description`：一段中文简介
  - `image`：封面图（可指向 `index.en_files/figure-html/...`，可省略）
  - `math`, `license`, `hidden`, `comments` 等可设近似值
- 正文用中文撰写，结构通常为：
  - 引言/背景（说明方法是什么、解决什么问题）
  - 核心概念与统计原理
  - 分步骤的完整操作流程（用 R 代码块演示）
  - 结果解释（平衡性检验、敏感性分析等，视方法而定）
  - 优缺点、注意事项、参考文献/案例

### 写作风格注意

- 代码块直接给出可运行 R 代码，含 `library()` 加载所需包。
- 关键代码用 `set.seed()` 保证可重复（种子取随机整数，不用 123/42 等特殊数）。
- 结果用中文解释，说明统计量含义与判断标准（如 SMD < 0.1 表示平衡良好）。

### knitr 设置惯例（用户偏好）

- `knitr::opts_chunk$set()` 里统一设置 `warning = FALSE`、`message = FALSE`（不输出包加载等噪音）、`cache = TRUE`（缓存代码块）、`collapse = TRUE`（每个代码块的输入输出合并在一个块里）。
- 每篇教程开头用一个 `include=FALSE` 的设置块配置上述选项；包加载用 `pcutils::lib_ps(Packages)`（需先 `requireNamespace("pcutils")`）或 `library()`。
- 展示公式（display math）必须把 `$$` 单独占一行（前后各一行），形如：
  ```
  $$
  E = mc^2
  $$
  ```
  不要把 `$$...$$` 挤在同一行，否则公式渲染不正确。

## 已写教程

- `2026-09-04-r-joint-model/index.en.Rmd`：临床预测的**联合模型(Joint Model)**。用 `JM` 包 + 内置 PBC 数据，讲纵向+生存联合建模、关联参数 α 解读、`survfitJM()` 动态生存预测与可视化。

### 相关环境备注（供续写/扩展）

- `JM` 已安装（EM 算法实现，`jointModel()` 拟合）；`JMbayes` / `JMbayes2` / `riskRegression` 未装。
- `jointModel()` 的生存子模型 `coxph()` / `survreg()` **必须加 `x = TRUE`**。
- `survfitJM()` 预测用患者**纵向历史**子集作为 `newdata`，`summaries[[1]]` 是矩阵（列 `times/Mean/Median/Lower/Upper`），转 data.frame 后即可绘图。
- `parameterization = "slope"` / `"both"` 需额外指定 `derivForm`（较繁琐，教程实操聚焦 `value`）。

## 待办 / 规划

- 按用户要求逐个添加教程，以“学习新 R 包 / 统计方法”为导向。可能的后续：把纵向子模型换成样条/分段，或用 JMbayes2 扩展贝叶斯估计与动态 AUC。

## 本站 Hugo 环境（2026-09-06 更新）

- 使用 Hugo 0.165.0 extended，版本固定在 `.Rprofile` 和 `netlify.toml`。
- 使用完整新版 Stack 主题。站点只覆盖首页欢迎模板与 blogdown shortcode；数学渲染使用主题自带 KaTeX 模板。
- `config.yaml` 启用 Goldmark passthrough，支持 `$$...$$`、`$...$`、`\[...\]`、`\(...\)`；公式内部使用标准 LaTeX（下标 `_`），不要为 Markdown 额外转义下划线。
- `.Rprofile` 只设置本项目选项，不加载用户全局 `.Rprofile`。修改后重启 R。
- 保留 `security.allowContent` 以读取现有本地 HTML widgets；保留 `markup.goldmark.renderer.unsafe` 以呈现文章中的 HTML。
- KaTeX 依赖保留在 `data/external.yaml`（0.16.22）；自定义样式在 `assets/scss/custom.scss`。
