
# FastChainer
[![GitHub stars](https://img.shields.io/github/stars/n9tank/FastChainer)](https://github.com/n9tank/FastChainer/stargazers) [![GitHub forks](https://img.shields.io/github/forks/n9tank/FastChainer)](https://github.com/n9tank/FastChainer/network) [![GitHub issues](https://img.shields.io/github/issues/n9tank/FastChainer)](https://github.com/n9tank/FastChainer/issues)

+ 适用于GameGuardian的（基址/动态基址/链路）获取工具，支持自动检验可行链路、导出脚本。

## 简介
+ FastChainer是产考Rchainer重写的快速链路查找工具，它在搜索和检验的速度做了很大改进，以帮助你更快寻找链路。

## 速度
这里以深度4，最大偏移1000，测试结果。
| 脚本 | 耗时 | 
| --- | --- | 
| Rchainer  | 42.3s | 
| FastChainer | 3.9s | 

现版本使用了重量级筛查，这能大幅减少查询时间，但是对轻量查询性能有所下降。
## 使用

1.选择合适的内存区域 [Cd,Cb,...]

基址：取消保存列表的选择项目

动态链路：将需要匹配的结构体，储存在保存列表并选择

2. 搜索列表的数据量为1，执行 **FastChainer.lua**
