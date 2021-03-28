//
//  RefreshFooter.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//

import UIKit
import Eddid_ESPullToRefresh

class RefreshFooter: NSObject {
    let footerView: ESRefreshFooterView
    /// 指定的构造器
    init(handler: @escaping RefreshHandler) {
        let footer = ESRefreshFooterView(frame: CGRect.zero, handler: handler)
        footerView = footer
        super.init()
        if let animator = footerView.animator as? ESRefreshFooterAnimator {
            animator.loadingMoreDescription = "Loading more"
            animator.noMoreDataDescription = "No more data"
            animator.loadingDescription = "Loading..."
        }
    }
    /// 此初始化方法只给EDRefresh使用，开发者请勿用
    init(footerView: ESRefreshFooterView) {
        self.footerView = footerView
        super.init()
    }
    /// 是否在刷新
    func isRefreshing() -> Bool {
        return footerView.isRefreshing
    }
    /// 停止刷新
    func stopRefresing() {
        footerView.stopRefreshing()
    }
    /// 停止刷新并且标识没有更多数据了
    func stopRefresingWitnNoMoreData() {
        stopRefresing()
       footerView.noticeNoMoreData()
    }
    /// 恢复上拉加载更多标识【取消 没有更多数据的标识】
    func resetNoMoreData() {
        footerView.resetNoMoreData()
    }
}
