RequestDemo
=======================
## 介绍
接口调用的Demo项目

## 支持
iOS13.0以上系统
支持真机/模拟器运行

## 编码环境
采用swift5编码，需使用Xcode11以上编译器。

## 数据持久化
根据观察,接口返回数据较小
采用UserDefaults保存目前不会有性能瓶颈,故暂未采用数据库和归档等方案
历史请求记录在内存中最大存储量设置为1千,本地化设置为5千
接口返回数据是每次全量覆盖内存和磁盘的数据
两种数据pageSize均为50

## Tips
### 项目Podfile源为https://mirrors.bfsu.edu.cn/git/CocoaPods/Specs.git
如需pod install请自行切换
### main分支为普通版
RxSwift是用RxSwift逐步替换改造的版本
因RxSwift用的较少,理解上可能不够深,所以暂时两个版本都保留
