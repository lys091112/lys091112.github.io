---
title: 利用Hexo搭建个人博客
date: 2017-08-06 22:52:37
tags: 
- hexo
categories:
- util
---

首先要申请个人github账号，并以固定格式建立项目名称: {userName}.github.io, 这是github-pages 要求的项目名称。 

本次安装针对于mac系统，linux类似。

## 搭建

### 依赖程序安装

1. 安装node
在控制台下执行``brew install node``

2. 安装hexo
   执行命令``npm install -g hexo``

3. 由于在``hexo 3.x`` 版本之后, ``hexo-server`` 模块单独出来，需要独立安装
    执行命令 ``npm install hexo-server --save``, 可以通过 ``hexo server``命令启动 Hexo，访问如出现类似 **can't not GET** 等错误，执行``npm install``

4. 安装 git 模块，使hexo可以推送到git
执行命令 ``npm install hexo-deployer-git --save``

至此，依赖安装完毕。


### 开发流程

1. ``git clone {own-repo}`` 到本地. 

2. 建立博客目录,(例如： ``mkdir blog``), 然后进入该目录，执行 ``hexo init``， 此时目录会自动生成hexo的基础文件，编辑 ``_config.xml`` 文件, 修改如下部分
```
deploy:
  type: git
  repo: git@github.com:<userName>/<userName>.github.io.git
  branch: master
```
   为了避免更换电脑或系统之后，``blog`` 文件的丢失，可以将其push 到github上进行保存。 方式： 建立分支`` git checkout -b hexo``, 然后将文件push 到 github上。 

3. 书写文档，并发布到github。 常用命令如下：

* hexo g(enerate): 生成静态文件，在public文件夹中
* hexo s(erver): 生成本地预览，默认情况下，网址为： http://localhost:4000/
* hexo d(eploy): 部署并提交代码至GitHub中
* hexo clean：用于清除缓存文件和已经生成的静态文件， 如果发现自己的修改对站点不生效， 那么可以尝试运行该命令

### 主体更换

常用主题[Next](https://github.com/iissnan/hexo-theme-next)

`` cd {your-own-blog}``, 然后进入 ``themes`` 目录，将[Next](https://github.com/iissnan/hexo-theme-next) 克隆到该目录下， 
然后修改``_config.xml``文件如下:
```
theme: hexo-theme-next
```


