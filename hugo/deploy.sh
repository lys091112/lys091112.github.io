#!/bin/bash

hugo -t even
echo "生成html文件"

git checkout master

path=`cd .. && pwd`
echo "当前路径：$path"
rm -rf $path/docs
mv $path/hugo/public $path/docs
git add .
git commit -m "deploy"
git push origin master
echo "推送成功"