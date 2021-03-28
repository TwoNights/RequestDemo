//
//  RefreshHeader.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//

import UIKit
import Eddid_ESPullToRefresh

class RefreshHeader: NSObject, RefreshHeaderAnimatorDelegate {
    /// 动画的最短时长【刷新动画未达到最短时长时结束刷新，会等到到达最短时长时再结束刷新】
    private let minAnimateDuration: TimeInterval = 0.5
    /// 自动隐藏时间
    private let autoHiddenDuration: TimeInterval = 15
    /// 是否已经过了最短动画时间
    private var reachMinDuration: Bool = false
    /// 是否将要停止动画
    private var willStopRefreshing: Bool = false
    /// 超时提示
    private var timeOutToast: String?
    /// 自动隐藏
    private var timeOutHidden: Bool = false
    // 超时隐藏的handler
    private var timeOutHandler: RefreshHandler?
    /// 需要自动隐藏
    private var needAutoHiddenTime: TimeInterval?
    /// 父视图是否正在展示
    var isAppear: Bool = true
    /// 下拉刷新的View
    let headerView: ESRefreshHeaderView
    /// 指定的构造器
    /// - Parameters:
    ///   - autoHidden: 是否超时15秒自动隐藏
    ///   - toast: 超时自动隐藏后的toast
    ///   - handler: 回调
    init(autoHidden: Bool = false, toast: String? = nil, handler: @escaping RefreshHandler, timeOutHandler: RefreshHandler? = nil) {
        let animator = RefreshHeaderAnimator()
        timeOutHidden = autoHidden
        timeOutToast = toast
        self.timeOutHandler = timeOutHandler
        let header = ESRefreshHeaderView(frame: CGRect.zero, handler: handler, animator: animator)
        headerView = header
        super.init()
        animator.delegate = self
    }
    /// 此初始化方法只给EDRefresh使用，开发者请勿用
    init(headerView: ESRefreshHeaderView) {
        self.headerView = headerView
        super.init()
    }
    /// 是否在刷新
    func isRefreshing() -> Bool {
        return headerView.isRefreshing
    }
    /// 停止刷新
    func stopRefresing() {
        willStopRefreshing = true
        if reachMinDuration == false {
            return
        }
        if timeOutHidden {
            needAutoHiddenTime = nil
        }
        headerView.stopRefreshing()
    }
    /// 配置标题颜色
    func configTitleColor(color: UIColor) {
        let animator = headerView.animator as? RefreshHeaderAnimator
        animator?.configTitleColor(color: color)
    }
}
// =================================================================
//                  EDRefreshHeaderAnimatorDelegate
// =================================================================
// MARK: - EDRefreshHeaderAnimatorDelegate
extension RefreshHeader {
    func refreshAnimationBegin() {
        reachMinDuration = false
        willStopRefreshing = false
        DispatchQueue.main.asyncAfter(deadline: .now() + minAnimateDuration) {
            self.reachMinDuration = true
            if self.willStopRefreshing == true {
                self.stopRefresing()
            }
        }
        // 自动隐藏
        if timeOutHidden {
            needAutoHiddenTime = Date().timeIntervalSince1970
            isAppear = true
            DispatchQueue.main.asyncAfter(deadline: .now() + autoHiddenDuration) {
                [weak self] in
                if self?.needAutoHiddenTime != nil && Date().timeIntervalSince1970 - (self?.needAutoHiddenTime ?? 0) >= self?.autoHiddenDuration ?? 15 {
                    self?.stopRefresing()
                    self?.timeOutHandler?()
                    if self?.isAppear == true && self?.timeOutToast != nil && self?.timeOutToast?.isEmpty == false {
                        Toast.show(message: self?.timeOutToast ?? "请求超时")
                    }
                }
            }
        }
    }
}
