# cocoapods-freezer

cocoapods-freezer是一款基于CocoaPods的集成缓存插件。

## 安装

``` shell
$ gem install cocoapods-freezer
```

## 使用
	
``` shell
$ pod install --frozen

```

## 原理

基于集成的Pod组件版本一般更新频率不高，其源码改动频率同样不高，因此这部分编译产物在一段时间内存在不变性，故通过对这其进行缓存，节省重复编译时间，最终达到提速效果。

## 能力

[x] 基于Podfile进行Pods缓存分析，配合'Pod install'进行缓存
[x] 目前仅支持static-library预打包处理（需屏蔽'use_framework!'）
[x] 目前仅支持release打包配置
[x] 目前仅支持单iOS平台
[x] 支持增量打包
[x] 支持缓存复用
[x] 缓存路径定制

## 计划

- 预编译相关
  - [] 支持全平台（Platform）、全配置（Configuration）缓存
  - [] 支持Framework(Dynamic\Static)方式构建
  - [] 支持local类型
  - [] 支持swift类型
	- [] 打包脚本定制？
	- [] Configuration定制？
	- [] 多Target使用相同Pod但不同subspec相应缓存

- 命令相关
	- [] 支持'pod update'命令工作
	- [] 支持'pod freeze'命令的查询、缓存操作

如果你喜欢这个插件，请留下🌟！欢迎提出遇到的问题，以及希望增加的功能！