---
title: go 指针学习
date: 2019-03-05 17:36:27
tags: ["go"]
toc: true
---


 指针就是一个变量，用于存储另一个变量的内存地址，所有的数据都存储在内存中，**变量** 只是给某一块的地址起的别名。

指针也是一个变量，他指向的内存存储的不仅是一个值，而且是另一个值的内存地址


![指针图示](/images/pointer.jpeg)

###  指针声明

指针的的语法声明如下：

```go

// 通过符号*可以声明指针类型，t只保留类型为T的类型指针

// 任何未初始化的指针值都为nil
var t *T

```

###  指针的初始化 和 输出

指针的初始化只需给它赋予其他变量的内存地址入口，变量的地址通过符号&获取

```go
var a = 10
var p *int = &a

fmt.Println(a) //10
fmt.Println(p) // a 的内存地址
fmt.Println(*p) // 10 通过*号，可以解引用，输出内存地址存储的变量值
```

###  多重指针

确切含义是指向指针的指针

```go

var a = 10

var p = &a

var pp = &p

fmt.Println(a) //10
fmt.Println(p) // a 的内存地址
fmt.Println(*p) // 10 输出a的值
fmt.Println(&p) // 输出p的内存地址
fmt.Println(pp) // 输出p的内存地址
fmt.Println(*pp) //输出a的内存地址 
fmt.Println(***pp) // 10 

```


### 通过引用赋值

示例：
```go
package main

import "fmt"

func main() {
    // 指针的使用
    var k int
    setK(&k)
    fmt.Print(k)
}

func setK(key *int) {
  *key = 10
}
```

<font color=red>tip: </font> go中没有指针算术运算
