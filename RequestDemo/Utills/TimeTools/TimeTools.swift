//
//  TimeTools.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//

import Foundation
class TimeTools {
    /// 获取当前时间字符串【毫秒】
    static func currentTimeString() -> String {
        let currentTime = Date().timeIntervalSince1970 * 1000
        return "\(currentTime)"
    }
}
