//
//  Toast.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//

import UIKit
import Toast_Swift

/// 默认显示的时长
private let defaultDuration: TimeInterval = 2.0
/// 吐司样式
private let style: ToastStyle = {
    var style = ToastStyle()
    style.backgroundColor = .lightGray
    style.titleColor = .white
    return style
}()
struct Toast {
    /// 显示吐司
    /// - Parameters:
    ///   - message: 需要显示的信息
    ///   - view: 需要显示的视图
    ///   - duration: 显示的时长
    static func show(message: String, view: UIView = getKeyWindow() ?? UIView(), duration: TimeInterval = defaultDuration) {
        let closures = {
            DispatchQueue.main.async {
                view.makeToast(message, duration: duration, position: .center, style: style)
            }
        }
        closures()
    }
}
