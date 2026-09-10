---
title: 组学数据去除批次效应（batch effect）
author: Peng Chen
date: '2026-09-12'
slug: batch-effect
categories:
  - metagenomic
tags:
  - batch effect
  - statistics
description: 批次效应是组学研究中最常见的系统性偏差。本文讲解批次效应的来源与识别方法，并用 ComBat / ComBat-Seq / limma 在 R 中演示校正流程与效果评估。
image: index.en_files/figure-html/unnamed-chunk-7-1.png
math: true
license: ~
hidden: no
comments: yes
---



## 什么是批次效应

**批次效应（batch effect）** 指的是由于样本的**采集、处理或测量**发生在不同批次（时间、操作者、试剂批号、测序 lane、质谱仪状态……）而引入的**系统性偏差**。它与研究关心的生物学变量无关，却会混入数据、干扰结论。

这个概念最早在**微阵列**时代就被清楚地观察到：同一样本在不同时间点杂交，信号强度会有系统性差异。之后的 RNA-seq、微生物组、蛋白组、代谢组同样逃不掉，而且**蛋白组和代谢组（质谱数据）尤其明显**——质谱的技术误差较大，通常需要靠前期的 QC 样本配合后期的算法校正来去除。

批次效应带来的后果是双向的：

- **假阳性**：批次与分组恰好部分混杂时，"差异"其实是批次差异；
- **假阴性**：批次引入的额外方差淹没了真实的生物学信号，检验功效下降。

所以它既影响结果的**可靠性**，也影响**可重复性**。

## 批次效应的来源与类型

| 来源 | 典型例子 |
|------|----------|
| 实验设计 | 不同日期、不同操作者、不同试剂批号 |
| 技术平台 | 不同测序仪、不同芯片版本、不同质谱仪 |
| 测序/检测本身 | lane、flowcell、run、上样顺序 |
| 数据处理 | 不同比对版本、不同标准化流程 |

从**是否与生物学变量混淆**的角度，可以分成两类：

- **完全混杂（confounded）**：批次与分组一一对应，例如所有对照组都在批次 1、所有处理组都在批次 2。**这种情况无法用统计方法救回来**，只能重新设计实验。
- **部分混杂（partially confounded）**：每个批次里都有两组样本，只是比例不完全均衡。**这种情况可以校正**。

> 这是最重要的一条实践原则：**实验设计阶段就要让每个批次内包含各种分组**。设计一旦完全混杂，再好的算法也无能为力。

## 如何识别批次效应

校正之前，先要确认批次效应**确实存在、且有多大**。

### 1. 可视化：PCA / 聚类

最直观的方式是主成分分析（PCA）：如果 PC1 / PC2 上样本主要按**批次**而非**分组**分开，说明批次效应是主导变异。

### 2. 定量：PC 与批次的关联

对每个主成分做方差分析，看它是否与批次变量显著相关：

$$
\text{PC}_k \sim \text{batch}
$$

如果前几个 PC 的 p 值都很小，说明批次解释了主要方差。

### 3. 看已知的"阴性对照"

用一些**已知不应该有差异**的特征（管家基因、spike-in、QC 样本）来评估批次波动，是最可靠的做法。

## 常用的校正方法

| 方法 | 类型 | 适用场景 |
|------|------|----------|
| **ComBat** | 经验贝叶斯 | 微阵列、log 转换后的表达数据 |
| **ComBat-Seq** | 负二项 | RNA-seq 原始 count |
| **limma `removeBatchEffect()`** | 线性模型 | 通用，可保留分组效应 |
| **RUV**（替代变量分析） | 因子分析 | 批次未知时，从数据中估计 |
| **DWD**（距离加权判别） | 距离校正 | 样本量小的场景 |
| 基于比值的方法 | 成对比较 | 有配对设计时 |

本文演示最常用的三种：**ComBat**、**ComBat-Seq** 与 **limma**。

## 实操：合成数据演示

为了能**看到校正的"真值"**，这里先构造一份带已知批次效应的合成数据。


``` r
library(sva)
library(limma)
library(dplyr)
library(ggplot2)
library(tidyr)

set.seed(2026)

n_gene <- 2000      # 基因数
n_per  <- 30        # 每个批次的样本数
batch  <- rep(c("B1", "B2"), each = n_per)
group  <- rep(rep(c("Ctrl", "Case"), each = n_per / 2), 2)

# 基础表达水平 + 真实的生物学效应（前 200 个基因在 Case 中上调）
base <- rnorm(n_gene, mean = 8, sd = 1)
X <- matrix(rnorm(n_gene * length(batch), mean = base, sd = 1),
            nrow = n_gene,
            dimnames = list(paste0("gene", seq_len(n_gene)), paste0("S", seq_along(batch))))

# 加入生物学效应
X[1:200, group == "Case"] <- X[1:200, group == "Case"] + 1.5
# 加入批次效应：B2 整体上移 2
X[, batch == "B2"] <- X[, batch == "B2"] + 2

meta <- data.frame(sample = colnames(X), batch = batch, group = group)
head(meta)
##   sample batch group
## 1     S1    B1  Ctrl
## 2     S2    B1  Ctrl
## 3     S3    B1  Ctrl
## 4     S4    B1  Ctrl
## 5     S5    B1  Ctrl
## 6     S6    B1  Ctrl
```

现在数据里同时存在**生物学效应**（真实、要保留）和**批次效应**（技术、要移除）。样本比较均衡：每个批次里 Ctrl / Case 各 15 例，属于**部分混杂**，可以校正。

### 校正前：PCA 看结构


``` r
plot_pca <- function(mat, meta, color_var, title) {
  pca <- prcomp(t(mat), scale. = TRUE)
  pct <- round(100 * pca$sdev^2 / sum(pca$sdev^2), 1)
  df <- data.frame(PC1 = pca$x[, 1], PC2 = pca$x[, 2], meta)
  ggplot(df, aes(PC1, PC2, color = .data[[color_var]])) +
    geom_point(size = 2.5) +
    labs(x = paste0("PC1 (", pct[1], "%)"),
         y = paste0("PC2 (", pct[2], "%)"),
         title = title) +
    theme_bw()
}

plot_pca(X, meta, "batch", "校正前：按批次着色")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-3-1.png" alt="" width="672" />

``` r
plot_pca(X, meta, "group", "校正前：按分组着色")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-3-2.png" alt="" width="672" />

校正前，样本会明显沿 PC1 分成两团，**与批次完全对应**——这就是批次效应主导的典型表现。

### 方法一：ComBat（经验贝叶斯）

`ComBat` 是 sva 包的核心函数，用经验贝叶斯（Empirical Bayes）收缩每个基因在每批次的位置/尺度参数。关键是要用 `mod` 参数**告诉它哪些是生物学变量**，否则会把真实效应一起抹掉：


``` r
# 关键：mod 里放的是"要保留"的生物学变量
mod <- model.matrix(~ group)

X_combat <- ComBat(dat = X, batch = batch, mod = mod)
```

> ⚠️ `mod` 参数是 ComBat 最容易用错的地方。如果只写 `ComBat(X, batch)`，它会**假设数据里除了批次没有别的结构**，进而把真实的分组差异也当作需要消除的偏差——这会造成严重的假阴性。

### 方法二：limma `removeBatchEffect()`

思路与 ComBat 相通，但对协变量结构更透明，输出的是"移除批次后"的表达矩阵：


``` r
X_limma <- removeBatchEffect(X, batch = batch, design = mod)
```

### 方法三：ComBat-Seq（针对原始 count）

如果手里是 RNA-seq 的**原始 count**（非负整数），不要用 ComBat，应该用 `ComBat-Seq`，因为它基于负二项分布建模：


``` r
library(sva)
counts <- matrix(rnbinom(1000 * 60, mu = 100, size = 5), nrow = 1000)

counts_corrected <- ComBat_seq(
  counts = counts,
  batch  = batch,
  group  = group        # ComBat-Seq 直接接收生物学分组，无需 model.matrix
)
```

## 评估校正效果

校正后要做两件事：**批次是否消失**、**生物学信号是否保留**。

### 1. PCA：批次分开度


``` r
plot_pca(X_combat, meta, "batch", "ComBat 校正后：按批次着色")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-7-1.png" alt="" width="672" />

``` r
plot_pca(X_combat, meta, "group", "ComBat 校正后：按分组着色")
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-7-2.png" alt="" width="672" />

理想的校正结果是：**按批次着色不再分开，而按分组着色仍然分开**。

### 2. 定量比较：PC 与批次的关联


``` r
pc_batch_p <- function(mat) {
  pca <- prcomp(t(mat), scale. = TRUE)
  vapply(1:3, function(k) {
    summary(aov(pca$x[, k] ~ batch))[[1]][["Pr(>F)"]][1]
  }, numeric(1))
}

comp <- rbind(
  `校正前` = pc_batch_p(X),
  `ComBat` = pc_batch_p(X_combat),
  `limma`  = pc_batch_p(X_limma)
)
colnames(comp) <- c("PC1", "PC2", "PC3")
knitr::kable(comp, digits = 4, caption = "PC 与批次关联的 p 值（越大越好，说明批次不再驱动该 PC）")
```



Table: <span id="tab:unnamed-chunk-8"></span>Table 1: PC 与批次关联的 p 值（越大越好，说明批次不再驱动该 PC）

|       |    PC1|    PC2|    PC3|
|:------|------:|------:|------:|
|校正前 | 0.0000| 0.6672| 0.9931|
|ComBat | 0.9903| 0.9136| 0.9065|
|limma  | 1.0000| 1.0000| 1.0000|



### 3. 确认生物学信号还在


``` r
signal_kept <- function(mat, genes = 1:200) {
  # 计算已知上调基因在 Case - Ctrl 之间的平均差异
  mean(rowMeans(mat[genes, meta$group == "Case"]) -
       rowMeans(mat[genes, meta$group == "Ctrl"]))
}
c(
  `校正前` = signal_kept(X),
  `ComBat` = signal_kept(X_combat),
  `limma`  = signal_kept(X_limma)
)
##   校正前   ComBat    limma 
## 1.471229 1.470379 1.471229
```

校正后的差异应该**仍然明显大于 0**（理论上真值约 1.5）。如果接近 0，说明校正过度、把真实效应也抹掉了。

## 结果解读

把上面的输出综合起来，可以得到几个判断：

- **校正前** PC1 与批次的 p 值极小、与分组的关联被批次掩盖，说明批次是主导变异；
- **ComBat / limma 校正后**，PC 与批次的 p 值明显变大（批次不再驱动主轴），而按分组着色的 PCA 仍能分开两组；
- **生物学信号**在校正后基本保留，说明 `mod` / `design` 参数设置正确。

需要强调的是：**校正效果取决于生物学变量是否正确告知算法**。这也是为什么 ComBat 的 `mod` 与 limma 的 `design` 是整段流程中最关键的两行。

## 微生物组数据的特殊性

以上方法是围绕**基因表达（连续、近似正态）** 设计的。微生物组的组成数据（相对丰度、count）有几处不同，需要额外注意：

1. **成分性（compositional）**：相对丰度之和恒为 1，某个物种变化会牵动其他所有物种，普通的线性校正会引入伪相关，通常先做 CLR / log-ratio 转换；
2. **零膨胀**：大量结构零（物种确实不存在）与抽样零混杂，标准化与校正都需要专门处理；
3. **稀疏与高维**：OTU/ASV 数远大于样本数，经验贝叶斯收缩反而更有帮助。

微生物组里常用的处理方法包括 `ComBat-seq`（对 count 向量）、以及把批次作为协变量放进差异丰度模型（如 `MaasLin2`、`ALDEx2`）。**很多时候，把 batch 直接放进模型作为协变量，比"先校正再分析"更稳妥**，因为它保留了不确定性。

## 优缺点与注意事项

### 优点

1. **显著提升可重复性**：消除技术噪声，让不同批次的数据可比；
2. **提升检验功效**：去掉批次引入的额外方差后，真实信号更容易被检出；
3. **方法成熟**：ComBat 等经验贝叶斯方法已有十余年验证，实现稳定。

### 局限

1. **无法修复完全混杂**：批次与分组完全重合时，任何算法都不可靠；
2. **可能过度校正**：参数设置不当会削弱甚至消除真实生物学差异；
3. **引入伪影**：校正后的数据不再是原始观测，下游统计的分布假设可能不再成立；
4. **对上游处理敏感**：不同的标准化方式会与批次校正相互作用。

### 注意事项

- **设计优先**：让每个批次内含各组样本，这是唯一真正可靠的"解法"；
- **先诊断再校正**：用 PCA + 已知阴性对照确认批次存在及其量级，不要盲校正；
- **显式告知生物学变量**：ComBat 的 `mod`、limma 的 `design` 必须写对；
- **保留原始数据**：校正只作用于分析副本，原始 matrix 永远保留；
- **报告方法**：论文中要写明校正方法与参数，这是可重复性的一部分。

## 小结

批次效应是组学数据里的系统性偏差，处理思路可以概括为三步：**设计上避免完全混杂 → 用 PCA 和阴性对照诊断 → 用 ComBat / ComBat-Seq / limma 校正并评估**。校正的目标不是"让数据变好看"，而是在**去掉技术偏差**的同时**保住生物学信号**——后者才是评估校正是否成功的最终标准。

## 参考文献与延伸

1. Johnson, W. E., Li, C., & Rabinovic, A. (2007). Adjusting batch effects in microarray expression data using empirical Bayes methods. *Biostatistics*, 8(1), 118–127.
2. Zhang, Y., Parmigiani, G., & Johnson, W. E. (2020). ComBat-seq: batch effect adjustment for RNA-seq count data. *NAR Genomics and Bioinformatics*, 2(3), lqaa078.
3. Leek, J. T., et al. (2010). Tackling the widespread and critical impact of batch effects in high-throughput data. *Nature Reviews Genetics*, 11, 733–739.
4. sva 包文档：<https://bioconductor.org/packages/sva/>
5. limma 包文档：<https://bioconductor.org/packages/limma/>
