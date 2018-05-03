
---
title: 一个小脚本引发的点滴记录
date: 2018-05-02 16:02:25
tags: 
  - shell
toc: true
---

## zsh自定义脚本

在 zsh脚本中添加自定义的快捷方式, 脚本内容如下：
```sh
function dkexec {
    if [ -z "$1" ]; then
        echo "Usage: dockerexec mysql|redis|..."
    else
        image=`docker ps | grep $1 | awk '{print $1}'`
        if [ -z "$image" ]; then
            echo "can't find image by name $1"
        else
            docker exec -it ${image} bash
        fi
    fi
}
```

**遇到的问题：**

1. 判断语句与括号间需要空格分割
    ```
    if [ -z "$1"] 如果$1所在的位置与]之间没有空格，那么会报错误 “dkexec:[:1: ']' expected” 

    如果 $1为空，那么就变成了 if[ -z ], 会把]当成一个字符，引发异常
    ```

2. 所有的if都需要相应的fi来进行闭合

3. 在使用awk的print方法时，如果保证获取的结果值可以赋值给结果变量？

    ```
    需要将语句用反引号``包括起来，才能将结果值赋予image
    ```

## 引申的知识点

###  ** `$0, $1, $2 ...`变量的含义**


   | 变量 | 	含义 |
   | ---- | ------- |
   | `$0`   | 	当前脚本的文件名 |
   | `$n`   | 	传递给脚本或函数的参数。n 是一个数字，表示第几个参数。例如，第一个参数是`$1`，第二个参数是`$2`。 |
   | `$#`   | 	传递给脚本或函数的参数个数。 |
   | `$*`   | 	传递给脚本或函数的所有参数。 |
   | `$@`   | 	传递给脚本或函数的所有参数。被双引号(" ")包含时，与 `$*` 稍有不同，下面将会讲到。 |
   | `$?`   | 	上个命令的退出状态，或函数的返回值。 |
   | `$$`   | 	当前Shell进程ID。对于 Shell 脚本，就是这些脚本所在的进程ID。 |

    `$*` 和 `$@` 的区别

        `$*` 和 `$@` 都表示传递给函数或脚本的所有参数，不被双引号(" ")包含时，都以"`$1`" "`$2`" … "`$n`" 的形式输出所有参数

        但是当它们被双引号(" ")包含时，"`$*`" 会将所有的参数作为一个整体，以"`$1` `$2` … `$n`"的形式输出所有参数；"`$@`" 会将各个参数分开，以"`$1`" "`$2`" … "`$n`" 的形式输出所有参数。

### **`-z -a ... `等判断条件的使用**

    - 字符串判断
        str1 = str2　　　　　　当两个串有相同内容、长度时为真
        str1 != str2　　　　　 当串str1和str2不等时为真
        -n str1　　　　　　　 当串的长度大于0时为真(串非空)
        -z str1　　　　　　　 当串的长度为0时为真(空串)
        str1　　　　　　　　   当串str1为非空时为真

    - 数字的判断
        int1 -eq int2　　　　两数相等为真
        int1 -ne int2　　　　两数不等为真
        int1 -gt int2　　　　int1大于int2为真
        int1 -ge int2　　　　int1大于等于int2为真
        int1 -lt int2　　　　int1小于int2为真
        int1 -le int2　　　　int1小于等于int2为真

    - 文件的判断
        -r file　　　　　用户可读为真
        -w file　　　　　用户可写为真
        -x file　　　　　用户可执行为真
        -f file　　　　　文件为正规文件为真
        -d file　　　　　文件为目录为真
        -c file　　　　　文件为字符特殊文件为真
        -b file　　　　　文件为块特殊文件为真
        -s file　　　　　文件大小非0时为真
        -t file　　　　　当文件描述符(默认为1)指定的设备为终端时为真

    - 复杂逻辑判断
        -a 　 　　　　　 与
        -o　　　　　　　 或
        !　　　　　　　　非

附表：

| 语法 |   含义 |
| --- | ---- |
| [ -a FILE ] |  如果 FILE 存在则为真。 |
| [ -b FILE ] |  如果 FILE 存在且是一个块特殊文件则为真。 |
| [ -c FILE ] |  如果 FILE 存在且是一个字特殊文件则为真。 |
| [ -d FILE ] |  如果 FILE 存在且是一个目录则为真。 |
| [ -e FILE ] |  如果 FILE 存在则为真。 |
| [ -f FILE ] |  如果 FILE 存在且是一个普通文件则为真。 |
| [ -g FILE ] |  如果 FILE 存在且已经设置了SGID则为真。 [ -h FILE ]  如果 FILE 存在且是一个符号连接则为真。 |
| [ -k FILE ] |  如果 FILE 存在且已经设置了粘制位则为真。 |
| [ -p FILE ] |  如果 FILE 存在且是一个名字管道(F如果O)则为真。 |
| [ -r FILE ] |  如果 FILE 存在且是可读的则为真。 |
| [ -s FILE ] |  如果 FILE 存在且大小不为0则为真。 |
| [ -t FD ]   |  如果文件描述符 FD 打开且指向一个终端则为真。 |
| [ -u FILE ] |  如果 FILE 存在且设置了SUID (set user ID)则为真。 |
| [ -w FILE ] |  如果 FILE 如果 FILE 存在且是可写的则为真。 |
| [ -x FILE ] |  如果 FILE 存在且是可执行的则为真。 |
| [ -O FILE ] |  如果 FILE 存在且属有效用户ID则为真。 |
| [ -G FILE ] |  如果 FILE 存在且属有效用户组则为真。 |
| [ -L FILE ] |  如果 FILE 存在且是一个符号连接则为真。 |
| [ -N FILE ] |  如果 FILE 存在 and has been mod如果ied since it was last read则为真。 |
| [ -S FILE ] |  如果 FILE 存在且是一个套接字则为真。 |
| [ FILE1 -nt FILE2 ] |  如果 FILE1 has been changed more recently than FILE2, or 如果 FILE1 exists and FILE2 does not则为真。 |
| [ FILE1 -ot FILE2 ] |  如果 FILE1 比 FILE2 要老, 或者 FILE2 存在且 FILE1 不存在则为真。 |
| [ FILE1 -ef FILE2 ] |  如果 FILE1 和 FILE2 指向相同的设备和节点号则为真。 |
| [ -o OPTIONNAME ]   |  如果 shell选项 “OPTIONNAME” 开启则为真。 |
| [ -z STRING ]       |  “STRING” 的长度为零则为真。 |
| [ -n STRING ] or [ STRING ]  | “STRING” 的长度为非零 non-zero则为真。 |
| [ STRING1 == STRING2 ] |  如果2个字符串相同。 “=” may be used instead of “==” for strict POSIX compliance则为真。 |
| [ STRING1 != STRING2 ] |  如果字符串不相等则为真。 |
| [ STRING1 `<` STRING2 ]  | 如果 “STRING1” sorts before “STRING2” lexicographically in the current locale则为真。 |
| [ STRING1 > STRING2 ] |  如果 “STRING1” sorts after “STRING2” lexicographically in the current locale则为真。 |
| [ ARG1 OP ARG2 ] | “OP” is one of -eq, -ne, -lt, -le, -gt or -ge. These arithmetic binary operators return true if “ARG1” is equal to, not equal to, less than, less than or equal to, greater than, or greater than or equal to “ARG2”, respectively. “ARG1” and “ARG2” are integers. |
 
