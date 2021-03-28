//
//  DeviceSizeHeader.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//

import UIKit
/// 状态栏高度
let statusBarHeight = isFullScreen ? CGFloat(44.0) : CGFloat(20.0)
/// NavigationBar 高度
let navBarHeight = CGFloat(44.0)
/// tabbar高度
let tabbarHeight = isFullScreen ? CGFloat(49+34) : CGFloat(49)
/// 状态栏 + NavigationBar 高度
let statusNavBarHeight = statusBarHeight + navBarHeight
/// 屏幕宽度
let screenWidth = UIScreen.main.bounds.width
/// 屏幕高度
let screenHeight = UIScreen.main.bounds.height
/// 屏幕真实宽度
let screenTrueWidth = screenWidth * UIScreen.main.scale
/// 屏幕真实高度
let screenTrueHeight = screenHeight * UIScreen.main.scale
/// 状态栏高度
let safeBottomHeight = isFullScreen ? 15.0 : 0.0
/// 全面屏判断(注意不要在window赋值之前使用)
var isFullScreen: Bool {
    let window: UIWindow = getKeyWindow() ?? UIWindow(frame: UIScreen.main.bounds)
    if window.safeAreaInsets.left > 0 || window.safeAreaInsets.bottom > 0 {
        return true
    }
    return false
}
/// 获取keyWindow
func getKeyWindow() -> UIWindow? {
    return (UIApplication.shared.delegate as? AppDelegate)?.window
}
