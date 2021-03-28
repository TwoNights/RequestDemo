//
//  RequestModel.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//
import Alamofire
// =================================================================
//                          基础协议
// =================================================================
// MARK: - 基础协议
protocol RequestModelProtocol {
    func getUrl() -> String
    func getRequestType() -> HTTPMethod
    func getParameter() -> [String: Any]?
    func getHeader() -> HTTPHeaders
}
extension RequestModelProtocol {
    func getRequestType() -> HTTPMethod {.get}
    func getParameter() -> [String: Any]? {nil}
    func getHeader() -> HTTPHeaders {CommonHeader.gainCommonHeader()}
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
// =================================================================
//                          MainList
// =================================================================
// MARK: - MainList
struct MainListApi: RequestModelProtocol {
    func getUrl() -> String {"https://api.github.com"}
}
