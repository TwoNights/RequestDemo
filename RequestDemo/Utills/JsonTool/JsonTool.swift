//
//  JsonTool.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//

import Foundation
struct JsonTool {
    /// 字典转String
    /// - Parameter array: 字典
    /// - Returns: string
    static func arrayToString(array: [Any]) -> String? {
        if !JSONSerialization.isValidJSONObject(array) {
            print("无法解析出JSONString")
            return nil
        }
        if let data = try? JSONSerialization.data(withJSONObject: array, options: []) as NSData? {
            let JSONString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
            if JSONString != nil {
                return JSONString! as String
            }
        }
        print("转JSONString失败")
        return nil
    }
    /// 字典转jsonString
    /// - Parameter dict: 字典
    /// - Returns: string
    static func dictToString(dict: [String: Any]) -> String? {
        if !JSONSerialization.isValidJSONObject(dict) {
            print("无法解析出JSONString")
            return nil
        }
         if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) as NSData? {
             let JSONString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
             if JSONString != nil {
                 return JSONString! as String
             }
         }
         print("转JSONString失败")
         return nil
    }
    /// string转字典
    /// - Parameter string: string
    /// - Returns: 字典
    func stringToDictionary(string: String) -> [String: Any]? {
        if let jsonData: Data = string.data(using: .utf8) {
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any]
            return dict
        }
        return nil
    }
    /// string转数组
    /// - Parameter string: string
    /// - Returns: 数组
    func stringTotoArray(string: String) -> [Any]? {
        if let jsonData: Data = string.data(using: .utf8) {
            let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [Any]
            return array
        }
        return nil
    }
}
