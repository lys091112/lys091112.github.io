---
title: 利用Hexo搭建个人博客
date: 2017-08-06 22:52:37
tags: 
- hexo
categories:
- util
toc: true
---

首先要申请个人github账号，并以固定格式建立项目名称: {userName}.github.io, 这是github-pages 要求的项目名称。 

本次安装针对于mac系统，linux类似。

## 1. 搭建

### 1.1. 依赖程序安装

1. 安装node
在控制台下执行``brew install node``

2. 安装hexo
   执行命令``npm install -g hexo``

3. 由于在``hexo 3.x`` 版本之后, ``hexo-server`` 模块单独出来，需要独立安装
    执行命令 ``npm install hexo-server --save``, 可以通过 ``hexo server``命令启动 Hexo，访问如出现类似 **can't not GET** 等错误，执行``npm install``

4. 安装 git 模块，使hexo可以推送到git
执行命令 ``npm install hexo-deployer-git --save``

至此，依赖安装完毕。

<!-- more -->


### 1.2. 开发流程

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

### 1.3. 主体更换

常用主题[Next](https://github.com/iissnan/hexo-theme-next)

`` cd {your-own-blog}``, 然后进入 ``themes`` 目录，将[Next](https://github.com/iissnan/hexo-theme-next) 克隆到该目录下， 
然后修改``_config.xml``文件如下:
```
theme: hexo-theme-next
```

### 1.4. Next 使用

1. 修改语言设置
```
    在站点配置文件 _config.yml, 修改language: zh-CN
```

2. 添加 ``about`` 页面。
```
    修改主题配置文件 ``_config.yml`` 文件，打开 ``menu`` 下的 about 标签，
    执行 ``hexo new page about`` ,创建``about`` 页面
 ```

3. 添加 tag 页面
```
    修改主题配置文件 ``_config.yml`` 文件，打开 ``menu`` 下的 about 标签，
    执行 ``hexo new page tags`` ,创建 ``tags``  页面
    编辑新产生的 tags 页面，修改添加 ``type：tags``
```

## 2. 插件使用

### 2.1 搜索插件

1. **安装 hexo-generator-search**
```
    npm install hexo-generator-search --save
```
2. **安装 hexo-generator-searchdb**
```
    npm install hexo-generator-searchdb --save
```
3. **修改站点目录下文件 ``_config.xml``**
```yml
search:
  path: search.xml
  field: post
  format: html
  limit: 10000
```
4. **修改主题配置文件 ``_config.xml`` **
```yml
local_search:
  enable: true
```

### 1.5 遇到的问题

1. 命令 hexo g 执行后没有生成任何的静态文件

  方式一： 通过命令 ``npm ls --depth 0`` 查询hexo缺少的依赖，然后依次安装
  方式二： 由于本地的nap有大版本的更新，就版本的hexo依赖的npm已经消失，此时会出现版本不一致问题，因此用新版本的 hexo init命令生成新的hexo目录文件，然后将文件通过对比拷贝到原有的hexo项目文件中即可

2. deployer not found： git

缺少依赖包： npm install --save hexo-deployer-git
