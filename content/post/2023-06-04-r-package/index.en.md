---
title: R包开发（基础）
author: PengChen
date: '2023-06-04'
slug: r-package
categories:
  - R
tags:
  - 编程
  - R
description: ~
image: ~
math: ~
license: ~
hidden: yes
comments: yes
---

之前写的包都是东学一点西学一点拼凑起来的感觉，没有系统的了解和学习， 直接使用Rstudio提供的部分功能和`devtools`好像还有点区别，为了一次解决这些问题， 获得最好的制作包体验，这次全面地看一遍R-package这本书吧

## Getting start

These functions setup parts of the package and are typically called once per package:

-   [`create_package()`](https://usethis.r-lib.org/reference/create_package.html)

-   [`use_git()`](https://usethis.r-lib.org/reference/use_git.html)

-   [`use_mit_license()`](https://usethis.r-lib.org/reference/licenses.html)

-   [`use_testthat()`](https://usethis.r-lib.org/reference/use_testthat.html)

-   [`use_github()`](https://usethis.r-lib.org/reference/use_github.html)

-   [`use_readme_rmd()`](https://usethis.r-lib.org/reference/use_readme_rmd.html)

You will call these functions on a regular basis, as you add functions and tests or take on dependencies:

-   [`use_r()`](https://usethis.r-lib.org/reference/use_r.html)

-   [`use_test()`](https://usethis.r-lib.org/reference/use_r.html)

-   [`use_package()`](https://usethis.r-lib.org/reference/use_package.html)

You will call these functions multiple times per day or per hour, during development:

-   [`load_all()`](https://devtools.r-lib.org/reference/load_all.html)

-   [`document()`](https://devtools.r-lib.org/reference/document.html)

-   [`test()`](https://devtools.r-lib.org/reference/test.html)

-   [`check()`](https://devtools.r-lib.org/reference/check.html)

这点我好像没有注意过

最后，重要的是要注意 library() 永远不应该在包内使用。包和脚本依赖于不同的机制来声明它们的依赖关系，这是你需要在你的思维模式和习惯上做出的最大调整之一。我们将在 10.6 节和第 12 章中全面探讨这个主题。

不要使用 library() 或 require()。这些修改搜索路径，影响全局环境中可用的功能。相反，您应该使用 DESCRIPTION 来指定包的要求，如第 10 章所述。这也确保在安装包时安装这些包。

切勿使用 source() 从文件加载代码。 source() 修改当前环境，插入执行代码的结果。没有理由在你的包中使用 source() ，即在 R/ 下的文件中。有时，在包开发期间，人们会在 R/ 下获取 source() 文件，但正如我们在第 5.4 节和第 7.2 节中所解释的那样，load_all() 是加载当前代码以进行探索的更好方法。如果您使用 source() 创建数据集，最好使用第 8 章中的方法将数据包含在包中。

available 包有一个名为 available() 的函数，可以帮助你从多个角度评估一个潜在的包名：

[library](https://rdrr.io/r/base/library.html)([available](https://github.com/r-lib/available))

available("doofus")

建议多使用check()

对于 R 版本 4.0 或更高版本（因此需要版本依赖性或只能有条件地使用），包可以将用户特定的数据、配置和缓存文件存储在从 tools::R_user_dir() 获得的各自用户目录中，前提是通过[sic] 默认大小保持尽可能小，内容得到积极管理（包括删除过时的材料）。
