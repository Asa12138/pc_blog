---
title: R语言爬虫（rvest包）
author: Peng Chen
date: '2023-11-22'
slug: r-rvest
categories:
  - R
tags:
  - 爬虫
description: ~
image: ~
math: ~
license: ~
hidden: no
comments: yes
---

## Introduction

什么是网络数据爬取
为什么需要爬取数据
数据爬取方法

## 网页基础知识


## R爬取网页

https://zhuanlan.zhihu.com/p/158883589

Rvest API介绍
读取与提取：

read_html() 读取html文档的函数
html_nodes() 选择提取文档中指定元素的部分
html_name() 提取标签名称；
html_text() 提取标签内的文本；
html_attr() 提取指定属性的内容；
html_attrs() 提取所有的属性名称及其内容；
html_table() 解析网页数据表的数据到R的数据框中；
html_form() 提取表单。
乱码处理：
guess_encoding() 用来探测文档的编码，方便我们在读入html文档时设置正确的编码格式
repair_encoding() 用来修复html文档读入后的乱码问题
行为模拟：
set_values() 修改表单
submit_form() 提交表单
html_session() 模拟HTML浏览器会话
jump_to() 得到相对或绝对链接
follow_link() 通过表达式找到当前页面下的链接
session_history() 历史记录导航工具



```r
# 加载包
library('rvest')

# 指定要爬取的url
url <- 'https://zhuanlan.zhihu.com/p/27238535'

# 从网页读取html代码
webpage <- read_html(url)

# 用CSS选择器获取排名部分
rank_data_html <- html_nodes(webpage,'.external , .Post-Title , .language-text , .css-1s3a4zw+ .css-1s3a4zw .css-1gomreu')

# 把排名转换为文本
rank_data <- html_text(rank_data_html)

# 检查一下数据
head(rank_data)
```

```
## [1] "【译文】R语言网络爬虫初学者指南（使用rvest包）"
## [2] "SAURAV KAUSHIK"                                
## [3] "IMDB"                                          
## [4] "指南"                                          
## [5] "这里"                                          
## [6] "学习路径"
```


