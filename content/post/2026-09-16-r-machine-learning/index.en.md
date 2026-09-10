---
title: R语言机器学习（基础）
author: Peng Chen
date: '2026-09-16'
slug: r-machine-learning
categories:
  - R
tags:
  - 机器学习
  - R
  - 编程
description: 用 R 入门机器学习。本文梳理监督/无监督/强化学习的区别，介绍生物信息学中的典型应用，并在 iris 数据上用 LASSO、随机森林与 XGBoost 走通"训练-评估"流程。
image: images/tidymodels_cover.png
math: true
license: ~
hidden: no
comments: yes
---



## 什么是机器学习

<img src="images/tidymodels_cover.png" title=""/>

**机器学习（machine learning, ML）** 是人工智能的一个分支：让计算机系统**通过数据和经验自动学习规律**，而不需要为每个具体问题显式编写规则。

它的核心任务可以概括为：给定数据，学习一个从输入到输出的映射（或发现数据内部的结构），并让它在新数据上也能做出合理判断。

## 三大范式

| 范式 | 数据 | 目标 | 典型算法 |
|------|------|------|----------|
| **监督学习** | 有标签 $(X, y)$ | 学习 $X \to y$ 的映射 | 线性/Logistic 回归、决策树、随机森林、SVM、XGBoost |
| **无监督学习** | 无标签 $(X)$ | 发现结构、模式、分组 | PCA、聚类、关联规则 |
| **强化学习** | 与环境交互 | 学习最优策略 | Q-learning、策略梯度 |

生物信息学中，**监督学习**和**无监督学习**占绝大多数。

## 生物信息学中的应用

机器学习在生信里的应用非常广泛，几个典型方向：

1. **基因组学**：基因功能预测、调控网络推断、变异致病性预测；
2. **蛋白质结构预测**：从序列预测结构与功能（AlphaFold 系列是深度学习在此方向的突破）；
3. **药物设计**：预测药物活性、副作用、靶点；
4. **微生物组学**：预测菌株、代谢功能、疾病状态；
5. **临床研究**：
   - 疾病预测与诊断（从临床、基因组、影像数据）；
   - 疾病亚型发现（聚类）；
   - 预后与生存分析；
   - 个体化治疗。

## 常用算法一览

| 算法 | 类型 | 特点 |
|------|------|------|
| **LASSO** | 线性 + 正则 | L1 正则让系数稀疏，兼具**特征选择**与建模 |
| **Logistic 回归（LR）** | 线性分类 | 可解释性强，医学统计的主流 |
| **随机森林（RF）** | 集成（Bagging） | 鲁棒、抗过拟合、可给变量重要性 |
| **XGBoost** | 集成（Boosting） | 表格数据上的强基线，正则化 + 并行 |
| **LightGBM** | 集成（Boosting） | 更快的 Boosting，支持大规模数据 |
| **CatBoost** | 集成（Boosting） | 原生处理**类别特征** |
| **SVM** | 核方法 | 小样本高维表现好 |
| **CNN** | 深度学习 | 图像与序列数据 |

**实践建议**：表格型组学数据上，**先试 LASSO 和随机森林作为基线**，再考虑 Boosting；深度学习只有在样本量足够大时才值得。

## 完整流程：以 iris 为例

下面用一个"三分类"任务演示标准流程。iris 是"玩具数据"，但它足以说明**方法学骨架**——换成真实数据时，只有数据准备部分不同。


``` r
library(caret)
library(glmnet)
library(randomForest)
library(xgboost)
library(dplyr)

set.seed(4719)     # 保证可复现

# 1. 划分训练集 / 测试集（80% / 20%）
train_idx <- createDataPartition(iris$Species, p = 0.8, list = FALSE)
train <- iris[train_idx, ]
test  <- iris[-train_idx, ]

cat("训练集:", nrow(train), "行 | 测试集:", nrow(test), "行\n")
## 训练集: 120 行 | 测试集: 30 行
```

> ⚠️ **最重要的原则**：测试集**在模型开发完成之前绝不能碰**。本文为了对比三种方法，对三个模型都用了同一个测试集，这在实际建模中是不允许的——正确做法是用交叉验证在训练集上挑模型，最后才用测试集报告一次性能。

### 方法一：LASSO（带特征选择）

`glmnet` 的 `alpha = 1` 对应 LASSO。它通过 L1 正则把不重要的变量系数压到 0：

$$
\hat{\beta} = \arg\min_\beta \left\{ \frac{1}{2N}\|y - X\beta\|_2^2 + \lambda \|\beta\|_1 \right\}
$$

$\lambda$ 由交叉验证选择。


``` r
x_train <- as.matrix(train[, -5])
y_train <- train$Species
x_test  <- as.matrix(test[, -5])

# family = "multinomial" 处理多分类
cv_lasso <- cv.glmnet(x_train, y_train, family = "multinomial",
                      alpha = 1, nfolds = 5)

# 用 lambda.min（CV 误差最小）预测
pred_lasso <- as.vector(predict(cv_lasso, newx = x_test, s = "lambda.min", type = "class"))

cat("LASSO 准确率:", round(mean(pred_lasso == test$Species), 3), "\n")
## LASSO 准确率: 0.9
```

可以用 `plot(cv_lasso)` 看 $\lambda$ 与交叉验证误差的关系；`lambda.1se` 给出更简化的模型（误差在一个标准误内），变量数更少。

### 方法二：随机森林

随机森林通过 **Bagging + 随机特征子集** 构建多棵决策树，再投票：


``` r
rf_fit <- randomForest(Species ~ ., data = train, ntree = 200, importance = TRUE)

pred_rf <- predict(rf_fit, test)
cat("随机森林准确率:", round(mean(pred_rf == test$Species), 3), "\n")
## 随机森林准确率: 0.9

# 变量重要性
importance(rf_fit) |> as.data.frame() |> arrange(desc(MeanDecreaseGini))
##                 setosa versicolor virginica MeanDecreaseAccuracy
## Petal.Length 14.876591  21.745612 15.992650            21.676323
## Petal.Width  13.587805  19.724992 18.031246            19.902433
## Sepal.Length  4.217023   4.211613  5.051319             6.372194
## Sepal.Width   2.442033   1.435096 -2.077310             1.749952
##              MeanDecreaseGini
## Petal.Length        36.570647
## Petal.Width         34.240320
## Sepal.Length         7.171011
## Sepal.Width          1.363522
```

变量重要性是随机森林的一大优势，可以直接回答"哪些特征对分类贡献最大"。

### 方法三：XGBoost

XGBoost 是梯度提升的实现，逐步拟合残差：


``` r
dtrain <- xgb.DMatrix(x_train, label = as.numeric(y_train) - 1)

params <- list(
  objective   = "multi:softmax",
  num_class   = 3,
  eta         = 0.3,      # 学习率
  max_depth   = 3,        # 树深
  eval_metric = "mlogloss"
)

xgb_fit <- xgb.train(params, dtrain, nrounds = 50, verbose = 0)

pred_xgb <- predict(xgb_fit, x_test)
cat("XGBoost 准确率:",
    round(mean(pred_xgb == (as.numeric(test$Species) - 1)), 3), "\n")
## XGBoost 准确率: 0.9
```

### 三种方法对比


``` r
acc <- c(
  LASSO     = mean(pred_lasso == test$Species),
  随机森林  = mean(pred_rf == test$Species),
  XGBoost   = mean(pred_xgb == (as.numeric(test$Species) - 1))
)

knitr::kable(
  data.frame(方法 = names(acc), 准确率 = round(acc, 3)),
  row.names = FALSE,
  caption = "三种方法在 iris 测试集上的准确率"
)
```



Table: (\#tab:unnamed-chunk-6)三种方法在 iris 测试集上的准确率

|方法     | 准确率|
|:--------|------:|
|LASSO    |    0.9|
|随机森林 |    0.9|
|XGBoost  |    0.9|



在 iris 这种"简单可分"的数据上，三种方法都能达到 0.9 左右，差异不显著——**这正是需要注意的地方**：默认数据集上的表现不能说明方法的优劣。

## 分类任务更该看什么

**准确率（accuracy）在类别不平衡时具有欺骗性**。医学数据常出现患病率很低的情况（例如阳性率 2%），此时把所有样本都预测为阴性就能得到 98% 的准确率。

更完整的评估应包含：

| 指标 | 含义 | 关注场景 |
|------|------|----------|
| 灵敏度（Recall） | 正例被找出的比例 | 不能漏诊 |
| 特异度 | 负例被正确排除的比例 | 不能误诊 |
| 精确率（Precision） | 预测为正的样本中真正为正的比例 | 阳性后续成本高 |
| F1 | 精确率与灵敏度的调和平均 | 综合平衡 |
| **AUC** | ROC 曲线下面积 | 与阈值无关的排序能力 |


``` r
# 混淆矩阵（以随机森林为例）
confusionMatrix(pred_rf, test$Species)
## Confusion Matrix and Statistics
## 
##             Reference
## Prediction   setosa versicolor virginica
##   setosa         10          0         0
##   versicolor      0          7         0
##   virginica       0          3        10
## 
## Overall Statistics
##                                           
##                Accuracy : 0.9             
##                  95% CI : (0.7347, 0.9789)
##     No Information Rate : 0.3333          
##     P-Value [Acc > NIR] : 1.665e-10       
##                                           
##                   Kappa : 0.85            
##                                           
##  Mcnemar's Test P-Value : NA              
## 
## Statistics by Class:
## 
##                      Class: setosa Class: versicolor Class: virginica
## Sensitivity                 1.0000            0.7000           1.0000
## Specificity                 1.0000            1.0000           0.8500
## Pos Pred Value              1.0000            1.0000           0.7692
## Neg Pred Value              1.0000            0.8696           1.0000
## Prevalence                  0.3333            0.3333           0.3333
## Detection Rate              0.3333            0.2333           0.3333
## Detection Prevalence        0.3333            0.2333           0.4333
## Balanced Accuracy           1.0000            0.8500           0.9250
```

`confusionMatrix()` 会一次性给出准确率、Kappa、各分类的灵敏度/特异度，是分类评估的首选工具。

## 数据划分与交叉验证

上面用了最简单的 80/20 划分。更严谨的做法是**交叉验证**：


``` r
ctrl <- trainControl(method = "cv", number = 5, classProbs = TRUE)

cv_rf <- train(Species ~ ., data = train, method = "rf",
               trControl = ctrl, ntree = 200)

cv_rf$results[, c("mtry", "Accuracy", "Kappa")]
##   mtry  Accuracy  Kappa
## 1    2 0.9833333 0.9750
## 2    3 0.9750000 0.9625
## 3    4 0.9833333 0.9750
```

`caret` 的 `train()` 会自动在多种超参数组合上做交叉验证并选择最优，这是比手写循环更可靠的调参方式。

## 常见陷阱

1. **数据泄漏**：在划分训练/测试**之前**做标准化、特征选择或缺失值填补，会把测试集信息泄漏进训练过程。**所有预处理都应在训练集上拟合、再应用到测试集**（`caret::preProcess()` 可以自动化这一点）；
2. **只用准确率**：类别不平衡时改用 AUC / F1 / 灵敏度；
3. **测试集反复使用**：调参过程中反复看测试集表现，等于把测试集变成了训练集。应该用交叉验证调参，测试集只在最后用一次；
4. **过拟合**：训练集表现远好于测试集是典型信号。降低模型复杂度、增加正则、或增加样本量；
5. **忽略可解释性**：医学应用常需要解释"为什么"。随机森林的变量重要性、LASSO 的稀疏系数都能提供线索，但深度模型往往难以解释；
6. **不做外部验证**：单中心、小样本的模型往往泛化性差，理想情况下应有独立队列验证。

## 优缺点

### 机器学习的优势

1. **能处理高维与非线性**：组学数据动辄上万特征，传统统计方法吃力而 ML 更从容；
2. **自动特征交互**：树模型天然捕捉特征间的交互效应；
3. **预测能力强**：在合适的场景下能显著优于线性模型；
4. **工具生态成熟**：`caret`、`tidymodels`、`mlr3` 提供了统一的流程框架。

### 局限

1. **需要样本量**：深度模型尤其"吃数据"；
2. **可解释性差**：多数强模型是黑箱；
3. **易过拟合**：组学数据"高维小样本"的特征使过拟合风险极高；
4. **对流程细节敏感**：预处理、划分、调参的顺序稍有不慎就会得到虚高的性能。

## 小结

机器学习在 R 中的入门路径可以概括为：**划分数据 → 选基线模型（LASSO / 随机森林）→ 交叉验证调参 → 在测试集上评估（不只看准确率）→ 检查是否过拟合**。对生信与医学数据，最需要警惕的不是"选哪个算法"，而是**数据泄漏与过拟合**——这两者会让你的模型在论文里表现优异、在真实场景中失效。

## 参考文献与延伸

1. James, G., et al. (2021). *An Introduction to Statistical Learning* (2nd ed.). Springer. <https://www.statlearning.com/>
2. Kuhn, M., & Silge, J. *Tidy Modeling with R*. <https://www.tmwr.org/>
3. `caret` 文档：<https://topepo.github.io/caret/>
4. `tidymodels`：<https://www.tidymodels.org/>
5. 本站相关：[R语言实现倾向性评分匹配(PSM)](../p/r-psm)、[R医学数据分析](../p/r-medicine)、[使用MLP根据相对丰度预测粪便微生物组负荷｜Cell](../p/mlp-cell)
