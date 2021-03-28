//
//  requestViewModel.swift
//  ApiTest
//
//  Created by Ad on 2021/3/23.
//
import Foundation
import UIKit
enum ResponseType {
    case success
    case fail
    case local
}
/// 请求回调闭包
typealias RequestClosures = (_ responseType: ResponseType, _ Msg: String?) -> Void
/// 数据处理线程
private let dataQueue: DispatchQueue = DispatchQueue(label: "ApiTestRequestViewModel.Data", attributes: .concurrent)
/// 数据解析线程
private let analysisQueue: DispatchQueue = DispatchQueue(label: "ApiTestRequestViewModel.Analysis")
/// 历史数据分隔符
private let historySperateLine = "historySperateLine"
class MainListViewModel {
    // =================================================================
    //                              属性列表
    // =================================================================
    // MARK: - 属性列表
    /// 单页数据大小
    private var pageSize: UInt = 10
    /// 回调方法
    private var requestClosures: RequestClosures?
    /// 定时器
    private var timer: GCDTimer?
    /// dateFormatter创建比较耗时,每次用同一个
    private lazy var timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd日HH:mm:ss.SSS"
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 8 * 60 * 60) ?? TimeZone.current
        return timeFormatter
    }()
    /// 展示状态[安全属性]
    private var showHistory: Bool {
        get {
            dataQueue.sync {
                return _showHistory
            }
        }
        set {
            dataQueue.async(flags: .barrier) {
                self._showHistory = newValue
            }
        }
    }
    /// 数据源[安全属性]
    private var mainListArray: [MainListModel]? {
        get {
            dataQueue.sync {
                return _mainListArray
            }
        }
        set {
            dataQueue.async(flags: .barrier) {
                self._mainListArray = newValue
            }
        }
    }
    /// 历史数据源[安全属性]
    private var historyArray: [HistoryModel] {
        get {
            dataQueue.sync {
                return _historyArray
            }
        }
        set {
            dataQueue.async(flags: .barrier) {
                self._historyArray = newValue
            }
        }
    }
    /// 主页码[安全属性]
    private var mainPage: UInt {
        get {
            dataQueue.sync {
                return _mainPage
            }
        }
        set {
            dataQueue.async(flags: .barrier) {
                self._mainPage = newValue
            }
        }
    }
    // =================================================================
    //                      非安全属性列表,请勿直接使用
    // =================================================================
    /// 数据源
    private var _mainListArray: [MainListModel]?
    /// 展示状态
    private var _showHistory: Bool = false
    /// 历史数据源
    private var _historyArray = [HistoryModel]()
    /// 主页码
    private var _mainPage: UInt = 0
    // =================================================================
    //                              公开方法
    // =================================================================
    // MARK: 公开方法
    /// 开始刷新数据
    /// - Parameter closures: 回调
    func start(closures: RequestClosures?) {
        requestClosures = closures
        // 读取缓存
        if let dict = MainListCache.readData() {
            analysisModel(dict: dict, isLocal: true)
        }
        // 历史数据清除
        HistoryCache.saveData(object: [String]())
        // 开启定时
        timer = GCDTimer(interval: 5, delaySecs: 5, action: {
            self.netRequest()
        })
    }
    /// 读取模型数据源
    func readModelArray() -> [MainListModelProtocol]? {
        var array: [MainListModelProtocol]?
        array = showHistory ? historyArray : mainListArray
        return array
    }
    /// 数据源切换
    func switchShowModel() {
        showHistory.toggle()
    }
    /// 刷新数据
    func refreshData() {
        if showHistory == true {
            netRequest()
        } else {
            mainPage = 0
        }
        // 读取缓存
        if let dict = MainListCache.readData() {
            analysisModel(dict: dict, isLocal: true)
        }
        // 开启定时
        timer = GCDTimer(interval: 5, delaySecs: 5, action: {
            self.netRequest()
        })
    }
    /// 加载更多数据
    func loadMoreData() {
        if showHistory == true {
            if let array = HistoryCache.readData(), array.isEmpty == false, let lastContent = historyArray.last?.content {
                var lastIndex = 0
                for (idx, string) in array.enumerated() where string.contains(lastContent) {
                    lastIndex = idx
                }
                let endIndex = ((lastIndex + 1) + Int(pageSize)) >= array.count ? array.count - 1 : ((lastIndex + 1) + Int(pageSize))
                let subArray = array[(lastIndex + 1)..<endIndex]
                let modelArray = subArray.map { (string) -> HistoryModel in
                    let stringArray = string.components(separatedBy: historySperateLine)
                    return HistoryModel(title: stringArray[0, true] ?? "", content: stringArray[1, true] ?? "", isSuccess: stringArray[3, true] == "1")
                }
                historyArray.append(contentsOf: modelArray)
                requestClosures?(.local, nil)
            }
        } else {
            if let dict = MainListCache.readData() {
                analysisModel(dict: dict, isLocal: true)
            }
        }
    }
    // =================================================================
    //                              私有方法
    // =================================================================
    // MARK: - 私有方法
    /// 网络请求
    private func netRequest() {
        NetworkClient.request(apiModel: MainListApi()) { (_ responseData) in
            self.addHistoryModel(msg: responseData.message, isSuccess: responseData.errorCode == nil)
            self.requestClosures?(responseData.errorCode == nil ? .success : .fail, responseData.message)
            if let dict = responseData.json, responseData.errorCode == nil {
                self.mainPage = 0
                self.mainListArray = nil
                self.analysisModel(dict: dict)
            } else {
                self.addHistoryModel(msg: responseData.message, isSuccess: false)
            }
        }
    }
    /// 数据模型解析
    /// - Parameters:
    ///   - dict: dict
    ///   - isLocal: 是否是从本地加载数据
    private func analysisModel(dict: [String: Any], isLocal: Bool = false) {
        analysisQueue.async {
            // 从网络获取才保存,记录
            if isLocal == false {
                MainListCache.saveData(object: dict)
            }
            // 指定长度数组
            let resetCount = dict.keys.count - (self.mainListArray?.count ?? 0) > 0 ? dict.keys.count - (self.mainListArray?.count ?? 0) : 0
            let newResetCount = dict.keys.count - ((self.mainListArray?.count ?? 0) + Int(self.pageSize))
            let count = newResetCount > 0 ? Int(self.pageSize) : resetCount
            guard count != 0 else {
                // 主线程执行回调
                DispatchQueue.main.async {
                    self.requestClosures?(isLocal ? .local : .success, nil)
                }
                return
            }
            var array = [MainListModel](repeating: MainListModel(title: "", content: ""), count: count)
            // 赋值
            let startIndex = self.mainPage * self.pageSize
            _ = dict.keys.enumerated().map { (idx, key) in
                if idx >= startIndex && idx < self.pageSize * (self.mainPage + 1) {
                    array[idx - Int(startIndex)] = MainListModel(title: key, content: dict[key] as? String ?? "")
                }
            }
            // 保存
            if self.mainPage != 0 {
                self.mainListArray?.append(contentsOf: array)
            } else {
                self.mainListArray = array
            }
            self.mainPage += 1
            // 主线程执行回调
            DispatchQueue.main.async {
                self.requestClosures?(isLocal ? .local : .success, nil)
            }
        }
    }
    /// 添加历史内容
    /// - Parameters:
    ///   - content: 内容
    ///   - isSuccess: 是否成功
    private func addHistoryModel(msg: String, isSuccess: Bool) {
        let finalContent = timeFormatter.string(from: Date()) as String + msg
        historyArray.insert(HistoryModel(title: isSuccess ? "成功" : "失败", content: finalContent, isSuccess: isSuccess), at: 0)
        // 防止内存占用过大
        if historyArray.count >= 1000 {
            let array = historyArray.dropFirst(899)
            historyArray = historyArray.dropLast(100)
            requestClosures?(.local, nil)
            var stringArray = array.map { (model) -> String in
                return "\(model.title)\(historySperateLine)\(model.content)\(historySperateLine)\(isSuccess ? "1" : "0" )"
            }
            // 读取旧数据
            if var oldArray = HistoryCache.readData(), oldArray.isEmpty == false {
                if oldArray.count > 4900 {
                    oldArray = oldArray.dropLast(oldArray.count - 4900)
                }
                stringArray.append(contentsOf: oldArray)
            }
            // 保存
            HistoryCache.saveData(object: stringArray)
        }
    }
}
