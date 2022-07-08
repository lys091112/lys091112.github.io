---
title: Github与TravisCi的集成
date: 2017-09-24 23:36:17
tags: ["github"] 
categories: ["util"]
toc: true
---

在看github上好的开源项目时，总会在README中看到类似的成功或失败的图标, 那么它们时怎么生成的呢，这就不可避免需要谈到Github的好基友[Travis-Ci](https://travis-ci.org/), 下面就来说一下github与travis-ci的集成过程. ![Build Status](https://travis-ci.org/lys091112/moonstar.svg?branch=master)

**简单分为一下几步**

- 首先需要有一个github账号，并且需要有个自己的项目（废话，没有项目谁会去弄这东西，哈哈）
- 有github账号登录[Travis-Ci](https://travis-ci.org/)
- 在Travis-Ci中，进入 ``Accounts`` 界面， 在该界面上选择要进行集成测试的项目(这个按照页面的说明进行)
- 需要在项目的根目录下建立 ``.travis.yml`` 文件，具体文件的书写语法可网上搜寻或参考开源项目
- 将代码push上去后，如果一切顺利，Travis就会自动开始构建这个Maven工程。可以在Travis上看到构建结果和详细的输出
- 如果想要添加 ``build:passing`` 这样的图标， 可以在REASDME.md中添加这样的一个图标
    ```
    [![Build Status](https://travis-ci.org/${accountName}/${projectName}.svg?branch=master)](https://travis-ci.org/${accountName}/${projectName})
    
    例如我的地址为：
    [![Build Status](https://travis-ci.org/lys091112/moonstar.svg?branch=master)](https://travis-ci.org/lys091112/moonstar)
    ```

