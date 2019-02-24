---
title: go module 初步认知
date: 2019-02-24 18:02:04
tags:
- golang
toc: true
---

## GOPATH 

在 go1.11 之前，不是使用gdep, glide，就是直接使用go get安装第三方包
工作空间Workspaces，是Go项目的根目录，也就是``GOPATH`` 是GO项目必备的环境变量，用来存放Go的开发代码和第三方包代码，代码需要按照一定的目录安排

## mod 特性

### 模块定义：

模块根目录和其子目录的所有包构成模块，在根目录下存在 go.mod 文件，子目录会向着父目录、爷目录一直找到 go.mod 文件


环境变量 GO111MODULE 开启或关闭模块支持

- GO111MODULE=off 无模块支持，go 会从 GOPATH 和 vendor 文件夹寻找包。
- GO111MODULE=on 模块支持，go 会忽略 GOPATH 和 vendor 文件夹，只根据 go.mod 下载依赖。
- GO111MODULE=auto 在 ``$GOPATH/src`` 外面且根目录有 go.mod 文件时，开启模块支持

go.mod 可以用来定义当前模块依赖和版本，也可以用来替换和排除依赖

```
// 定义的模块名称
module example.com/m

// 模块依赖
require (
    golang.org/x/text v0.3.0
    gopkg.in/yaml.v2 v2.1.0
)

// 有时由于网络原因，golang.org/x下的包加载不到，可以使用github.com下的包替代
replace (
    golang.org/x/text => github.com/golang/text v0.3.0
)

```

- require语句指定的依赖项模块
- replace语句可以替换依赖项模块
- exclude语句可以忽略依赖项模块

### 常用命令

- go mod init:初始化modules
- go mod download:下载modules到本地cache
- go mod edit:编辑go.mod文件，选项有-json、-require和-exclude，可以使用帮助go help mod edit
- go mod graph:以文本模式打印模块需求图
- go mod tidy:删除错误或者不使用的modules
- go mod vendor:生成vendor目录
- go mod verify:验证依赖是否正确
- go mod why：查找依赖

go build -getmode=vendor 在开启模块支持的情况下，用这个可以退回到使用 vendor 的时代

### go的 mod与get


    go get 命令会将文件下载到$GOPATH/src 下的相应目录
    go mod 会把文件下载到$GOPATH/pkg/mode 目录下，供其他项目共享

go get命令也与时俱进，支持了modules

- 运行 go get -u 将会升级到最新的次要版本或者修订版本
- 运行 go get -u=patch 将会升级到最新的修订版本（比如说，将会升级到 1.0.1 版本，但不会升级到 1.1.0 版本）
- 运行 go get package@version将会升级到指定的版本号

## 如何创建go module项目

1)  定义入口文件

```go
// package main 后一定要跟import 注释的内容就是模块的名称
package main // import "github.com//xxx/examples/modules"

func main() {
    // ...
}

```

2) 在项目目录下执行初始化操作

```
    $ go mod init
    go: creating new go.mod: module github.com/xxx/examples/modules
```
    TIP: 不能在GOPATH 所在的目录下创建mod，不然会报异常

3) 编译执行,查看是否正常

```
    $ go build .
    $ ./modules 

```


参考文档: [Go modules example](https://www.mycodesmells.com/post/go-modules-example)
