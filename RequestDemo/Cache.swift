//
//  Cache.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//
import UIKit
/// 列表缓存
struct ListCache: cacheProtocol {
    typealias DataType = String
}
/// 历史缓存
struct HistoryCache: cacheProtocol {
    typealias DataType = [String]
}
/// 缓存协议
private protocol cacheProtocol {
    associatedtype DataType
    static func saveData(object: DataType, key: String)
    static func readData(key: String) -> DataType?
}
/// 缓存协议方法拓展
private extension cacheProtocol {
    static func saveData(object: DataType, key: String) {
        UserDefaults.standard.setValue(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    static func readData(key: String) -> DataType? {
        return UserDefaults.standard.value(forKey: key) as? Self.DataType
    }
}
