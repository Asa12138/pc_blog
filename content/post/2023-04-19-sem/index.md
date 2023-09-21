---
title: 结构方程模型（SEM）学习
author: Peng Chen
date: '2023-04-19'
slug: sem
categories:
  - models
tags:
  - 统计模型
  - R
description: ~
image: images/sem_model.jpg
math: ~
license: ~
hidden: no
comments: yes
bibliography: [../../bib/My Library.bib]
link-citations: yes
csl: ../../bib/science.csl
---

https://mp.weixin.qq.com/s/NEhoOlAau_jyxHPTf7H3ug 这篇推文讲的很详细。

## Introduction

结构方程模型（Structural Equation Modeling，简称SEM）是一种结合多元统计方法和数学模型的分析技术。它能够帮助研究者探究多个变量之间的关系和影响，包括直接和间接的影响。SEM 可以同时估计多个方程（即多元回归模型），并且允许变量间相互作用，同时还能考虑隐变量（latent variable）和测量误差等因素。它的应用范围非常广泛，例如社会科学、心理学、教育学、医学、生物学等领域。

在生物学领域，结构方程模型（SEM）被广泛用于探索和测试生物学系统的复杂关系。以下是一些具体的应用示例：

模拟生态系统：SEM可用于建立生态系统的复杂模型，并确定影响生态系统的不同因素之间的关系。例如，可以将SEM应用于研究气候变化对生态系统的影响，或者研究生物多样性和生态系统功能之间的关系（当然包括了微生物生态研究）。

遗传学：SEM可以用于研究遗传因素如何影响特定性状，例如疾病易感性、身高或体重等。通过SEM，可以确定哪些遗传因素是最重要的，以及这些遗传因素之间的相互作用。

病理学：SEM可用于研究疾病的发生机制。通过SEM，可以确定哪些因素对疾病的发生和发展具有关键作用，并识别可以用于治疗疾病的目标因素。

行为科学：SEM可用于研究生物行为的复杂性。例如，可以使用SEM来研究基因、环境和行为之间的相互作用，以确定影响人类和动物行为的主要因素。

生态毒理学：SEM可以用于研究污染物对生态系统的影响。通过SEM，可以确定哪些污染物是最有害的，以及它们对生态系统的影响方式。

## Example

在宏基因组微生物生态学中，研究者通常会测量样品中多个微生物群落的组成和它们所处的环境变量（如温度、pH值等）之间的关系。然而，这些微生物群落之间可能存在相互作用，如竞争、合作等，这些作用可能会影响到它们与环境之间的关系。在这种情况下，SEM可以用来建立微生物群落与环境变量之间的关系网络，同时考虑微生物群落之间的相互作用。

例如，一项研究调查了植物根际微生物群落与土壤性质之间的关系。研究者测量了植物根际中多个微生物群落的组成，以及土壤中的一些物理化学性质，如有机质含量、pH值等。他们使用SEM来建立微生物群落与土壤性质之间的关系网络，并同时考虑微生物群落之间的相互作用。他们发现，微生物群落之间存在着复杂的相互作用，而这些相互作用会影响到微生物群落与土壤性质之间的关系，提高了对微生物群落与环境之间关系的理解。

下面给出一个用R生成模拟数据并实现SEM的例子，假设我们研究一些微生物和它们生长环境之间的关系。其中，环境因子包括pH、温度、盐度，微生物包括细菌、真菌和古菌。

首先，我们需要生成一些符合正态分布的随机数据作为我们的变量。具体代码如下：

``` r
library(mvtnorm)
set.seed(123)

# 生成环境因子数据
n <- 1000
mu_env <- c(pH = 7, temp = 25, salinity = 3)
sigma_env <- matrix(c(1, 0.8, 0.5,
                      0.8, 1, 0.3,
                      0.5, 0.3, 1), ncol = 3)
env <- rmvnorm(n, mean = mu_env, sigma = sigma_env)%>%as.data.frame()

# 生成微生物数据
mu_microbe <- c(bacteria = 20, fungi = 10, archaea = 5)
sigma_microbe <- matrix(c(1, 0.5, 0.3,
                          0.5, 1, 0.2,
                          0.3, 0.2, 1), ncol = 3)
microbe <- rmvnorm(n, mean = mu_microbe, sigma = sigma_microbe)%>%as.data.frame()

# 将生成的数据合并为一个数据框
df <- data.frame(env, microbe)
```

接下来，我们使用sem函数实现SEM。具体代码如下：

``` r
library(lavaan)
model <- '
# 定义测量模型
# bacteria =~ bacteria
# fungi =~ fungi
# archaea =~ archaea

# 定义结构模型
bacteria ~ pH + temp
fungi ~ temp + salinity
archaea ~ pH + salinity

# 直接效应
bacteria ~~ fungi
bacteria ~~ archaea
fungi ~~ archaea
'

# 运行SEM
fit <- sem(model, data = df)

# 查看SEM结果
summary(fit)
```

    ## lavaan 0.6.15 ended normally after 22 iterations
    ## 
    ##   Estimator                                         ML
    ##   Optimization method                           NLMINB
    ##   Number of model parameters                        12
    ## 
    ##   Number of observations                          1000
    ## 
    ## Model Test User Model:
    ##                                                       
    ##   Test statistic                                 3.024
    ##   Degrees of freedom                                 3
    ##   P-value (Chi-square)                           0.388
    ## 
    ## Parameter Estimates:
    ## 
    ##   Standard errors                             Standard
    ##   Information                                 Expected
    ##   Information saturated (h1) model          Structured
    ## 
    ## Regressions:
    ##                    Estimate  Std.Err  z-value  P(>|z|)
    ##   bacteria ~                                          
    ##     pH               -0.022    0.047   -0.463    0.643
    ##     temp              0.074    0.048    1.541    0.123
    ##   fungi ~                                             
    ##     temp              0.019    0.033    0.574    0.566
    ##     salinity          0.024    0.029    0.828    0.408
    ##   archaea ~                                           
    ##     pH                0.017    0.036    0.481    0.631
    ##     salinity          0.028    0.034    0.822    0.411
    ## 
    ## Covariances:
    ##                    Estimate  Std.Err  z-value  P(>|z|)
    ##  .bacteria ~~                                         
    ##    .fungi             0.467    0.035   13.496    0.000
    ##    .archaea           0.295    0.032    9.221    0.000
    ##  .fungi ~~                                            
    ##    .archaea           0.183    0.031    5.869    0.000
    ## 
    ## Variances:
    ##                    Estimate  Std.Err  z-value  P(>|z|)
    ##    .bacteria          0.990    0.044   22.361    0.000
    ##    .fungi             0.988    0.044   22.361    0.000
    ##    .archaea           0.948    0.042   22.361    0.000

最后，我们可以使用semPlot函数绘制SEM图形，以便更好地理解SEM模型的结构。具体代码如下：

``` r
library(semPlot)
semPaths(fit, what = "std", nCharNodes = 10, sizeMan = 8,
         edge.label.cex = 1.1, curvePivot = TRUE, fade = FALSE)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-1.png" width="672" />
运行上述代码后，我们就得到了一个可视化的SEM模型图，该模型描述了微生物和环境因子之间的关系。

## Pro
