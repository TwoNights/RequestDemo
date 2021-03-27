//
//  EDNetworkClient.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//
import UIKit
import Alamofire
/** 响应数据 */
struct ResponseData {
    /// 返回的data字段,通常为字典或数组,根据文档自行转换
    var data: Any?
    /// 转换后的json
    var json: AnyObject?
    /// 错误信息
    var message: String = "网络错误,请稍后再试"
    /// 错误码,为nil是请求成功
    var errorCode: Int?
}
class NetworkClient: NSObject {
    /// reachability
    static let reachabilityManager = { () -> NetworkReachabilityManager in
        return NetworkReachabilityManager()!
    }()
    /// 持有者数组
    var holders = [String: [String: Any]]()
    /// 单个请求任务字典
    var singleDict = [String: Bool]()
    /// 任务请求实例
    private lazy var seesion: Session = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        let seesion = Session(configuration: config)
        return seesion
    }()
    /// 单例
    static let shared: NetworkClient = NetworkClient()
}
// MARK: - 请求 下载 上传
extension NetworkClient {
    /// 请求
    /// - Parameters:
    ///   - apiModel: 请求模型
    ///   - holder: 请求持有者,并在持有者deinit方法中执行cancelTask方法.如果为nil,则持有者被销毁时不会主动cancel请求.
    ///   - backTask: 后台任务,超长超时时间
    ///   - handler: 回调
    public static func request(apiModel: RequestModel, holder: AnyObject?, backTask: Bool = false, handler: @escaping (ResponseData) -> Void) {
        // holder字典
        var holdDict = [String: Any]()
        // 对象转换的key
        var holderKey: String = ""
        // 不为空则去取值
        if holder != nil {
            holderKey = NetworkClient.taskKeyString(object: holder!)
            holdDict = shared.holders[holderKey] ?? [String: Any]()
        }
        // 当前时间戳
        let time = TimeTools.currentTimeString()
        // 发起请求
        let request = shared.seesion.request(apiModel.url, method: apiModel.type, parameters: apiModel.parameter, encoding: URLEncoding.default, headers: apiModel.header).responseJSON { (response) in
            // 是否需要回调判断
            if holder != nil {
                // 移除任务
                holdDict.removeValue(forKey: apiModel.url + time)
                // 持有者已经被释放则直接返回
                if shared.holders[holderKey] == nil {
                    return
                }
            }
            // 回调数据解析
            var result = ResponseData()
            switch response.result {
            case .failure(let error):
                result = dealErrorCode(error: error)
            case .success(_):
                result = dealResponsData(data: response.data)
            }
            #if DEBUG
            // 控制台打印错误日志
            if result.errorCode != nil {
                let nowTime = Date().timeIntervalSince1970 * 1000
                print("message:\(result.message) code:\(result.errorCode ?? 0) url:\(apiModel.url)  parameter:\(apiModel.parameter) header:\(apiModel.header ) 耗时:\(Int(nowTime - Double(time)!))ms")
            }
            #endif
            // 回调
            handler(result)
        }
        // 保存holder数据
        if holder != nil {
            holdDict[apiModel.url + time] = request
            shared.holders[holderKey] = holdDict
        }
    }
    /// 处理错误信息
    /// - Parameter error: errror
    private static func dealErrorCode(error: AFError) -> ResponseData {
        var result = ResponseData(message: "未知错误", errorCode: LocalErrorCode)
        if let underlyingError = error.underlyingError {
            if let urlError = underlyingError as? URLError {
                var meesage =  ""
                switch urlError.code {
                case .timedOut:
                    meesage = "请求超时"
                case .notConnectedToInternet:
                    meesage = "网络断开"
                case .cancelled:
                    meesage = "任务取消"
                default:
                    meesage = "未知错误"
                }
                result.message = meesage
                result.errorCode = urlError.code.rawValue
            }
        }
        return result
    }
    /// 处理响应数据
    /// - Parameter data: 响应原始data
    private static func dealResponsData(data: Data?) -> ResponseData {
        // 数据检查
        guard data != nil else {
            return ResponseData(data: nil, json: nil, message: "返回Data为空", errorCode: LocalErrorCode)
        }
        guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject else {
            return ResponseData(data: nil, json: nil, message: "数据解析失败", errorCode: LocalErrorCode)
        }
        // 初始化数据
        var message: String?
        var code: Int?
        var dataList: Any?
        // 数据解析
        dataList = json.value(forKey: "data")
        if let dataDict = dataList as? [String: Any] {
            message = dataDict["msg"] as? String
        }
        // errorCode类型判断
        if let errorCode = json.value(forKey: "code") as? Int {
            if errorCode != 200 {
                code = errorCode
            } else {
                code = nil
            }
        } else if let errorCode = json.value(forKey: "code") as? String {
            if errorCode != "200" {
                code = Int(errorCode)
            } else {
                code = nil
            }
        } else {
            // code字段解析失败
            code = LocalErrorCode
            message = "code字段解析失败"
        }
        if message == nil {
            message = json.value(forKey: "msg") as? String
        }
        return ResponseData(data: dataList, json: json, message: message ?? "网络错误,请稍后再试", errorCode: code)
    }
    /// 移除任务
    /// - Parameter holder: 持有者
    class func cancelTask(holder: AnyObject) {
        let holderKey = NetworkClient.taskKeyString(object: holder)
        if let holdDict = NetworkClient.shared.holders[holderKey] {
            for key in holdDict.keys {
                let request: Request? = holdDict[key] as? Request
                request?.cancel()
            }
            NetworkClient.shared.holders.removeValue(forKey: holderKey)
        }
    }
    /// 任务key转换
    /// - Parameter object: 持有者对象
    static func taskKeyString(object: AnyObject) -> String {
        return  object.description + "\(Unmanaged.passUnretained(object).toOpaque())"
    }
}
// MARK: - 获取当前网络状态
extension NetworkClient {
    // MARK: - 获取当前网络状态
    static func networkStatus() -> NetworkReachabilityManager.NetworkReachabilityStatus {
        reachabilityManager.status
    }
}
