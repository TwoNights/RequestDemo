//
//  Cache.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//
import UIKit
let UserDefaults_Key_MainList = "UserDefaults_Key_MainList"
let UserDefaults_Key_HistroyList = "UserDefaults_Key_HistroyList"
/// 列表缓存
struct MainListCache: cacheProtocol {
    static func userDefaultsKey() -> String {
        return  UserDefaults_Key_MainList
    }
    typealias DataType = [String: Any]
}
/// 历史缓存
struct HistoryCache: cacheProtocol {
    typealias DataType = [String]
    static func userDefaultsKey() -> String {
        return  UserDefaults_Key_HistroyList
    }
}
/// 缓存协议
protocol cacheProtocol {
    associatedtype DataType
    static func saveData(object: DataType)
    static func readData() -> DataType?
    static func userDefaultsKey() -> String
}
/// 缓存协议方法拓展
extension cacheProtocol {
    static func saveData(object: DataType) {
        UserDefaults.standard.setValue(object, forKey: userDefaultsKey())
        UserDefaults.standard.synchronize()
    }
    static func readData() -> DataType? {
        return UserDefaults.standard.value(forKey: userDefaultsKey()) as? Self.DataType
    }
}
