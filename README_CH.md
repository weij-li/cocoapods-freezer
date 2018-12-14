# cocoapods-freezer

cocoapods-freezer是一款基于CocoaPods的集成缓存插件。

## 安装

    $ gem install cocoapods-freezer

## 使用

按如下配置，并触发'pod install'即可运行。
	
``` ruby
#use_framework! 目前插件不支持Framework构建

use_freezer! :options => {
	:all => true #or false (default is false)
}

target 'Demo' do
  pod 'AFNetworking'
end

```

## 背景

目前基于cocoapods的工程每次进行编译时，由于集成的Pod版本不变性，继而源码不变性，导致出现不必要的重复编译时间。

## 原理

首次启用freezer后，会在cocoapods集成前，对依赖的Pods进行预打包处理，并缓存产物。基于Pod的版本不变性，继而源码不变性，从而产物不变性（二进制数据）。后续集成编译将直接加载缓存产物，节省重复编译时间，提高速度。

## 能力

[x] 基于Podfile进行Pods缓存分析，配合'Pod install'进行缓存
[x] 支持配置”全部Pods启用、禁用Freezer功能“
[x] 目前仅支持static-library预打包处理（需屏蔽'use_framework!'）
[x] 目前仅支持release打包配置
[x] 目前仅支持单iOS平台
[x] 支持增量打包
[x] 支持缓存复用

## 计划

- 缓存相关
	[] 支持单独Pod缓存定制
  [] 支持全平台
  [] 支持Framework(Dynamic\Static)方式构建
  [] 支持local类型
  [] 支持swift类型
	[] 缓存路径定制
	[] 打包脚本定制？
	[] Configuration定制？

- 命令相关
	[] 支持'pod update'命令工作
	[] 支持'pod freeze'命令的查询、缓存操作

如果你喜欢这个插件，请留下🌟！欢迎提出遇到的问题，以及希望增加的功能！