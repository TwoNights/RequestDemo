//
//  RequestModel.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//
import Alamofire
/**
 请求基础类,请在组合中自定义部分属性
 */
struct RequestModel {
    var url: String
    var type: HTTPMethod = .get
    var parameter: [String: Any] = [String: Any]()
    var header: HTTPHeaders = CommonHeader.gainCommonHeader()
    /// 自定义构造方法
    /// - Parameters:
    ///   - urlString: 网址
    ///   - requestType: 请求类型,默认post
    ///   - param: 参数
    ///   - headerDict: 请求头
    init(urlString: String, requestType: HTTPMethod = .get, param: [String: Any], headerDict: HTTPHeaders = CommonHeader.gainCommonHeader()) {
        url = urlString
        type = requestType
        parameter = param
        header = headerDict
    }
}
/// 通用Header
struct CommonHeader {
    /// 单例
    static let shared = CommonHeader()
    /// 只在token改变等需要的情况修改header
    private var header: HTTPHeaders = HTTPHeaders()
    /// 获取通用header
    static func gainCommonHeader() -> HTTPHeaders {
        return shared.header
    }
}
