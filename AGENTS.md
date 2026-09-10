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
- `2026-09-09-r-mofa/index.en.Rmd`：**多组学因子分析(MOFA)**。用 `MOFA2` 包 + 内置 `make_example_data()` 合成 3 组学（RNA/DNAme/Protein）、2 组样本数据，讲概率矩阵分解原理、ARD 稀疏、多组扩展，流程为 create/prepare/run_mofa → 方差解释热图 → weights/因子得分 → 协变量关联 → 模型诊断。
- `2026-09-09-r-latent-class/index.en.Rmd`：**潜类别分析(LCA)**。用 `poLCA` 包 + 内置 `carcinoma` 数据（7 位病理学家诊断 118 例宫颈癌），讲潜变量/局部独立/EM 算法原理、模型选择（BIC/AIC/G²）、条件概率画像（3 类=无癌/有癌/分歧）、后验分类与标准化熵，另有模拟数据演示带协变量的 LCA。
- `2026-09-10-julia/index.en.Rmd`：**Julia 入门**。讲两语言问题、`juliaup` 安装、REPL 模式、基本语法、多重派发、`Pkg` 环境、性能（类型稳定/`@time`/`@btime`）与 R 互操作（`JuliaCall` / `RCall.jl`）。全文 `eval=FALSE`（本机未装 Julia）。
- **2026-09-11 ~ 2026-09-24 批量发布 14 篇**（原为 `un-*` 目录、`hidden: yes`、`uncompleted` 标签，现已去掉前缀与标签）：
  - `2026-09-11-mmseqs2`：MMseqs2 序列聚类，对比 CD-HIT，讲 createdb/cluster/easy-cluster/clusterupdate 与内存估算公式 $M=6Nr$。全文 `eval=FALSE`。
  - `2026-09-12-batch-effect`：批次效应，`sva::ComBat` / `limma::removeBatchEffect` / `ComBat_seq`，合成数据 PCA 前后对比。**可执行**。
  - `2026-09-13-crispr-analysis`：CRISPRCasFinder（Singularity 容器部署）+ spacer 拆分。`eval=FALSE`（含一段可执行的 R spacer 解析）。
  - `2026-09-14-c-cycling` / `2026-09-15-n-cycling`：碳/氮循环功能基因，标志基因表 + 合成丰度汇总与热图。**可执行**（注意 `MASS::rnegbin` 需显式命名空间）。
  - `2026-09-16-r-machine-learning`：LASSO(`glmnet`)/随机森林/XGBoost 三基线 + caret 交叉验证，强调数据泄漏与不平衡指标。**可执行**。
  - `2026-09-17-r-package`：`usethis`+`devtools` 包开发流程，重点讲"包内不用 `library()`/`source()`"。`eval=FALSE`。
  - `2026-09-18-trophic-strategy`：营养策略（自养/异养/混合），碳源×能量二维框架 + MAG 分型合成示例。**可执行**。
  - `2026-09-19-differential-abundance-analysis`：差异丰度，`ALDEx2` + `DESeq2` 双方法对比 + 效应量四象限图。**可执行**。
  - `2026-09-20-r-rvest`：rvest 爬虫，CSS 选择器速查 + 内联 HTML 演示 + 礼貌抓取准则。**可执行**（用内联 HTML，不依赖网络）。
  - `2026-09-21-quarto`：Quarto 入门，与 R Markdown 的四点差异、`format`、`#|` 选项、交叉引用。`eval=FALSE`。
  - `2026-09-22-circos`：circos（Perl 安装/配置结构）+ `circlize` 实际作图（弦图、基因组多轨道、微生物组环形堆叠）。**可执行**（circlize 部分）。
  - `2026-09-23-r-medicine`：医学统计（组间比较/相关/Logistic/生存分析/ROC）。**可执行**。
  - `2026-09-24-virsorter2-dram`：VirSorter2 鉴定 + DRAM-v 注释 AMG，含 DRAM 建库踩坑（需给 `database_processing.py` 打补丁）。`eval=FALSE`。

### 相关环境备注（供续写/扩展）

- **本机未安装 Julia**，`julia` / `juliaup` 均不可用 → 相关教程必须 `eval=FALSE`。
- **未安装的包（写教程时注意别写进可执行代码块）**：`lightgbm`、`catboost`、`epiDisplay`、`ggm`（用 `resid(lm())` 手写偏相关替代）、`iCRISPR`、`ANCOMBC`、`Maaslin2`、`LinDA`、`microbiome`、`mia`、`curatedMetagenomicData`、`epiR`、`quarto`(R 包)。
- **已装且可用于演示**：`rvest`、`glmnet`、`xgboost`、`caret`、`randomForest`、`e1071`、`survival`、`survminer`、`pROC`、`nnet`、`MASS`、`vcd`、`sva`、`limma`、`edgeR`、`ALDEx2`、`DESeq2`、`phyloseq`、`circlize`、`ComplexHeatmap`、`vegan`、`ade4`、`ggplot2`、`dplyr`、`pcutils`、`devtools`/`usethis`/`roxygen2`/`testthat`。
- **命名冲突坑（本会话踩过）**：`library(MASS)` 会 mask `dplyr::select`，`matrixStats` 会 mask `dplyr::count` → 在脚本里一律写 `dplyr::select()` / `dplyr::count()`；`vcd` 的 kappa 函数名是 **`vcd::Kappa()`**（不是 `kap()`）；HTML 节点树函数是 **`xml2::xml_structure()`**（rvest 没有 `html_structure()`）。
- 渲染报错排查：用 `Rscript -e "rmarkdown::render(...)"` 在**干净进程**里跑，与交互式 R 会话的包污染（如 MOFA 的 `get_factors`）不同。
- ⚠️ **`.gitignore` 第 24 行 `content/post/un-*/` 会忽略整个 `un-` 前缀目录**——`hidden: no` 也不会被 git 跟踪、不会部署。发布这类文章必须**去掉目录名的 `un-` 前缀**（URL 由 frontmatter 的 `slug` 决定，改名不影响 URL）。

- `JM` 已安装（EM 算法实现，`jointModel()` 拟合）；`JMbayes` / `JMbayes2` / `riskRegression` 未装。
- `jointModel()` 的生存子模型 `coxph()` / `survreg()` **必须加 `x = TRUE`**。
- `survfitJM()` 预测用患者**纵向历史**子集作为 `newdata`，`summaries[[1]]` 是矩阵（列 `times/Mean/Median/Lower/Upper`），转 data.frame 后即可绘图。
- `parameterization = "slope"` / `"both"` 需额外指定 `derivForm`（较繁琐，教程实操聚焦 `value`）。
- **MOFA2（1.18.0）** 已装；运行后端 `mofapy2`（0.7.5）装在 **base conda**（`/opt/anaconda3/bin/python`）。`run_mofa()` 走 `reticulate`，需让 R 的 reticulate 指向该环境：在渲染脚本开头 `Sys.setenv(RETICULATE_PYTHON = "/opt/anaconda3/bin/python")`（交互会话因 symlink 沙箱限制无法 use_condaenv，用 Rscript + 该环境变量可行）。
- MOFA2 关键 API：`create_mofa(list_of_matrices, groups=)`（矩阵行=特征、列=样本，列序需一致）、`get_default_data_options/model_options/training_options`、`prepare_mofa()`、`run_mofa(mofa, outfile=".hdf5")`。
- 多组结构下 `get_factors()` 返回按组的 list，列名带 `组名.` 前缀（如 `Healthy.Factor1`）；`get_factors(fit, groups="X")` 亦带前缀，合并时需 `sub(paste0("^", g, "."), "", colnames(m))` 去前缀。
- `make_example_data(n_groups=2)` 每组会生成 n_samples 个样本（共 2×n_samples）；样例元数据行数必须等于总列数，顺序与列名一致。
- `run_mofa` 训练后会自动剔除不解释方差的因子（`load_model(..., remove_inactive_factors=FALSE)` 可关）；若因子与总表达水平相关会给出 QC 警告。
- **poLCA（1.6.0.2）** 已装。`poLCA(cbind(Y1,Y2,...) ~ covars, data, nclass=K, nrep=N, verbose=FALSE)`；对象**没有 `num.classes`/`nclass` 字段**，类别数用 `nrow(object$probs[[1]])` 取。`probs[[j]]` 列名为 `Pr(1)`/`Pr(2)`（带空格）。
- LCA 类别**标签顺序不稳定**（EM 初始值决定，会随 set.seed/nrep 交换），解读务必以每个类别的**条件概率画像**为准，并固定 `nrep`+`set.seed` 保证教程可复现。carcinoma 用 `set.seed(4719)`+`nrep=15` → 3 类稳定（18.2%分歧/44.5%有癌/37.4%无癌），熵 R²≈0.926。
- 画 ggplot 图用中文标签时，macOS 需加 `theme(text = element_text(family = "PingFang SC"))`，否则标签乱码（`□□`）；图例/轴标签建议用中文 + 该字体（渲染时已固化为 PNG，跨平台无碍）。

### 渲染/构建流程（重要，供续写）

这篇教程是一步步脚本渲染出来的，与服务器直接跑 Hugo 不同。生成 `index.en.md` 的步骤：

1. 用 `rmarkdown::render("content/post/YYYY-MM-DD-slug/index.en.Rmd", output_format = blogdown::html_page(keep_md = TRUE), quiet = TRUE)` 产出 `.md`（图片落在 `index.en_files/figure-html/`）。
2. 若正文有 `<img>` 内联图，需给 `src` 加 `{{< blogdown/postref >}}` 前缀（参考 `content/post/2026-09-04-r-joint-model/index.en.md`），Hugo 才能解析页面资源路径。frontmatter 的 `image` 字段**不加** postref。
3. YAML 里 `image: index.en_files/figure-html/unnamed-chunk-K-1.png` 的 chunk 编号需与实际渲染对齐（用 `plot_variance_explained` 的热图做封面最合适，可在渲染后核对 `index.en_files/figure-html/` 下的文件名）。
4. `blogdown::build_site()` / `hugo_build()` 只跑 Hugo、不触发 Rmd→md（本站文章都是预先渲染好 .md 再提交的）；验证用 `blogdown::hugo_build(local=TRUE)` 后看 `public/p/<slug>/index.html`。

## 待办 / 规划

- 按用户要求逐个添加教程，以“学习新 R 包 / 统计方法”为导向。可能的后续：把纵向子模型换成样条/分段，或用 JMbayes2 扩展贝叶斯估计与动态 AUC；MOFA 可扩展 MEFISTO（时空因子）或与真实多组学数据对接。
- **MindMap 维护**：`content/page/MindMap/index.md` 已全量校验（215 篇全覆盖、0 断链、0 重复）。用 `R/build_mindmap.R` 重建：它以**每篇 post 的 YAML `slug` 为权威 URL**，以 MindMap 现有内容为 seed 保留人工分类，新增文章需在该脚本的 `missing_sec` 里指定板块后重跑。脚本顶部 `SRC <- MD`（自读自写），改动后直接 `source()` 即可。
- 本站已无 `un-` 前缀目录（全部已发布），后续新增草稿若沿用 `un-` 约定需记得改名前不会部署。

## 本站 Hugo 环境（2026-09-06 更新）

- 使用 Hugo 0.165.0 extended，版本固定在 `.Rprofile` 和 `netlify.toml`。
- 使用完整新版 Stack 主题。站点只覆盖首页欢迎模板与 blogdown shortcode；数学渲染使用主题自带 KaTeX 模板。
- `config.yaml` 启用 Goldmark passthrough，支持 `$$...$$`、`$...$`、`\[...\]`、`\(...\)`；公式内部使用标准 LaTeX（下标 `_`），不要为 Markdown 额外转义下划线。
- `.Rprofile` 只设置本项目选项，不加载用户全局 `.Rprofile`。修改后重启 R。
- 保留 `security.allowContent` 以读取现有本地 HTML widgets；保留 `markup.goldmark.renderer.unsafe` 以呈现文章中的 HTML。
- KaTeX 依赖保留在 `data/external.yaml`（0.16.22）；自定义样式在 `assets/scss/custom.scss`。
