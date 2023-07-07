---
title: "ReporterScore package"
author: "Peng Chen"
date: "2023-07-04"
categories:
- R
- metagenomic
tags:
- R
- package
- 功能基因
description: Reporter score is a new method for improved microbial enrichment analysis.
  Here we share its principle and an implemented R package.
image: ~
math: yes
license: null
hidden: no
comments: yes
bibliography: ../../bib/My Library.bib
link-citations: yes
csl: ../../bib/science.csl
slug: "reporterscore-package"
---

<script src="{{< blogdown/postref >}}index.en_files/kePrint/kePrint.js"></script>

<link href="{{< blogdown/postref >}}index.en_files/lightable/lightable.css" rel="stylesheet" />

# Introduction

Functional enrichment analysis is a computational method for analyzing the degree of enrichment of functional patterns in gene collections or genomic data. It can help reveal which functional modules, metabolic pathways, gene families, etc. are statistically enriched or significantly overrepresented in a specific biological context.

<table>
<caption>
Table 1: Methods for microbial enrichment analysis.
</caption>
<thead>
<tr>
<th style="text-align:left;">
Method
</th>
<th style="text-align:left;">
Tools
</th>
<th style="text-align:left;">
Notes
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Hypergeometric test / Fisher’ exact test
</td>
<td style="text-align:left;">
[DAVID](https://david.ncifcrf.gov/) (website)
[clusterProfiler](https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html) (R package) , etc.
</td>
<td style="text-align:left;">
The most common method used in enrichment analysis. The Database for Annotation, Visualization and Integrated Discovery (DAVID) provides a comprehensive set of functional annotation tools for investigators to understand the biological meaning behind large lists of genes. ClusterProfiler automates the process of biological-term classification and the enrichment analysis of gene clusters, which calculates enrichment test for GO terms and KEGG pathways based on hypergeometric distribution.
</td>
</tr>
<tr>
<td style="text-align:left;">
Gene set enrichment analysis (GSEA)
</td>
<td style="text-align:left;">
[GSEA](https://www.gsea-msigdb.org/gsea/index.jsp) (website)
[clusterProfiler](https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html) (R package)
</td>
<td style="text-align:left;">
Gene Set Enrichment Analysis (GSEA) is a computational method that determines whether an a priori defined set of genes shows statistically significant, concordant differences between two biological states. ClusterProfiler can also do GSEA.
</td>
</tr>
<tr>
<td style="text-align:left;">
Reporter score analysis
</td>
<td style="text-align:left;">
[Reporterscore](https://github.com/Asa12138/ReporterScore) (R package)
</td>
<td style="text-align:left;">
The plus or minus sign of reporter score does not represent regulation direction in the "mixed" mode but useful in "directed" mode.
</td>
</tr>
<tr>
<td style="text-align:left;">
Reporter feature analysis
</td>
<td style="text-align:left;">
[Piano](https://www.bioconductor.org/packages/release/bioc/html/piano.html) (R package)
</td>
<td style="text-align:left;">
Reporter feature can achieve enrichment ananlysis for non-directional, mixed-directional up/down-regulation, and distinct-directional up/down-regulation classes.
</td>
</tr>
</tbody>
</table>

**Reporter score** is a new method of improved microbial enrichment analysis. This method was originally developed to reveal transcriptional regulation patterns in metabolic networks, and has been introduced into microbial research for functional enrichment analysis.

The Reporter score algorithm was originally developed by Patil and Nielsen in 2005 to identify metabolites in metabolic regulatory hotspots ([*1*](#ref-patilUncoveringTranscriptionalRegulation2005)).

A recent article discussed the misuse of the positive and negative sign of reporter-score ([*2*](#ref-liuMisuseReporterScore))：

<https://mp.weixin.qq.com/s?__biz=MzUzMjA4Njc1MA==&mid=2247507105&idx=1&sn=d5a0f0aaf176e245de7976f0a48f87a8#rd>

The main conclusion is that the **reporter score** algorithm (above) is an enrichment method that ignores the up/down regulation information of KOs in the pathway, and it is incorrect to directly regard the sign of the reporter score as the regulation direction of the pathway.

Here we have implement the fast calculation of the classic reporterscore (mixed mode), and developed an algorithm in the directed mode, which can give the biological meaning of plus or minus sign of the reporterscore.

# Usage

``` r
install.packages("devtools")
devtools::install_github('Asa12138/pcutils',dependencies=T)
devtools::install_github('Asa12138/ReporterScore',dependencies=T)

library(ReporterScore)
```

# Method

### mixed

“mixed” mode is the original reporter-score method from Patil, K. R. et al. PNAS 2005.

In this mode, the reporter score is **Undirected**, and the larger the reporter score, the more significant the enrichment, but it cannot indicate the up-and-down regulation information of the pathway！(Liu, L. et al. iMeta 2023.)

steps: 1. Use the Wilcoxon rank sum test to obtain the P value of the significance of each KO difference between the two groups (ie$P_{koi}$, i represents a certain KO);

2.  Using an inverse normal distribution, convert the P value of each KO into a Z value ($Z_{koi}$), the formula:

3.  “Upgrade” KO to pathway:$Z_{koi}$, calculate the Z value of the pathway, the formula:

$$
Z_{pathway}=\frac{1}{\sqrt{k}}\sum Z_{koi}
$$

where k means A total of k KOs were annotated to the corresponding pathway;

4.  Evaluate the degree of significance: permutation (permutation) 1000 times, get the random distribution of$Z_{pathway}$, the formula:

$$
Z_{adjustedpathway}=(Z_{pathway}-\mu _k)/\sigma _k
$$
$μ_k$ is The mean of the random distribution,$σ_k$ is the standard deviation of the random distribution.

### directed

Instead, “directed” mode is a derived version of “mixed”, referenced from <https://github.com/wangpeng407/ReporterScore>. This approach is based on the same assumption of many differential analysis methods: the expression of most genes has no significant change.

1.  Use the Wilcoxon rank sum test to obtain the P value of the significance of each KO difference between the two groups (ie$P_{koi}$, i represents a certain KO), and then divide the P value by 2, that is, the range of (0,1\] becomes (0,0.5\],$P_{koi}=P_{koi}/2$;

2.  Using an inverse normal distribution, convert the P value of each KO into a Z value ($Z_{koi}$), the formula:

$$
Z_{koi}=\theta ^{-1}(1-P_{koi})
$$

since the above P value is less than 0.5, all Z values will be greater than 0;

3.  Considering whether each KO is up-regulated or down-regulated, calculate$\Delta KO_i$,

$$
\Delta KO_i=\overline {KO_{i_{g1}}}-\overline {KO_{i_{g2}}}
$$
$\overline {KO_{i_{g1}}}$ is average abundance of$KO_i$ in group1,$\overline {KO_{i_{g2}}}$ is average abundance of$KO_i$ in group2. Then,

$$
Z_{koi} =
\begin{cases} 
-Z_{koi},  & (\Delta KO_i<0) \\
Z_{koi}, & (\Delta KO_i \ge 0)
\end{cases}
$$

so$Z_{koi}$ is greater than 0 Up-regulation,$Z_{koi}$ less than 0 is down-regulation;

4.  “Upgrade” KO to pathway:$Z_{koi}$, calculate the Z value of the pathway,

$$
Z_{pathway}=\frac{1}{\sqrt{k}}\sum Z_{koi}
$$

where k means a total of k KOs were annotated to the corresponding pathway;

5.  Evaluate the degree of significance: permutation (permutation) 1000 times, get the random distribution of$Z_{pathway}$, the formula:

$$
Z_{adjustedpathway}=(Z_{pathway}-\mu _k)/\sigma _k
$$
$μ_k$ is The mean of the random distribution,$σ_k$ is the standard deviation of the random distribution.

The finally obtained$Z_{adjustedpathway}$ is the Reporter score value enriched for each pathway.

In this mode, the Reporter score is **directed**, and a larger positive value represents a significant up-regulation enrichment, and a smaller negative values represent significant down-regulation enrichment.

However, the disadvantage of this mode is that when a pathway contains about the same number of significantly up-regulates KOs and significantly down-regulates KOs, the final absolute value of Reporter score may approach 0, becoming a pathway that has not been significantly enriched.

# Reference

<div id="refs" class="references csl-bib-body">

<div id="ref-patilUncoveringTranscriptionalRegulation2005" class="csl-entry">

<span class="csl-left-margin">1. </span><span class="csl-right-inline">K. R. Patil, J. Nielsen, [Uncovering transcriptional regulation of metabolism by using metabolic network topology](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC549453). *Proceedings of the National Academy of Sciences of the United States of America*. **102**, 2685–2689 (2005).</span>

</div>

<div id="ref-liuMisuseReporterScore" class="csl-entry">

<span class="csl-left-margin">2. </span><span class="csl-right-inline">L. Liu, R. Zhu, D. Wu, Misuse of reporter score in microbial enrichment analysis. *iMeta*. **n/a**, e95.</span>

</div>

</div>