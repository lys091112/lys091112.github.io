#!/bin/bash

hugo -t even
echo "生成html文件"

git checkout master

if [ $? -ne 0 ]; then
    echo "切换到master分支失败，请检查！"
    exit;
else
    echo "success"
fi

path=`cd .. && pwd`
echo "当前路径：$path"

rm -rf $path/docs
mv $path/hugo/public $path/docs

git add . && git commit -m "deploy" && git push origin master

if [ $? -ne 0]; then
    echo "推送到master失败，请手动处理！"
    exit;
else
    echo "推送成功"
fi


echo "切回hugo分支"
git checkout hugo