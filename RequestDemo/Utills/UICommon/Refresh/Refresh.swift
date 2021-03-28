//
//  Refresh.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//

import UIKit

public typealias RefreshHandler = (() -> Void)
// =================================================================
//                            下拉刷新
// =================================================================
// MARK: - 下拉刷新
extension UIScrollView {
    /// 给ScrollView和其子类添加头部【下拉刷新】
    /// - Parameter autoHidden: 是否自动隐藏
    /// - Parameter toast: 超时的toast,如果不需要在页面消失的时候展示,请在页面消失的时候设置Header的isApear属性
    /// - Parameter handler: 下拉刷新的回调
    /// - Returns: EDRefreshHeaderView
    @discardableResult
    func addRefreshHeader(autoHidden: Bool = false, toast: String? = nil, handler: @escaping RefreshHandler, timeOutHandler: RefreshHandler? = nil) -> RefreshHeader {
        let edHeader: RefreshHeader = RefreshHeader(autoHidden: autoHidden, toast: toast, handler: handler, timeOutHandler: timeOutHandler)
        self.edHeader = edHeader
        return edHeader
    }
    /// 停止下拉刷新
    func stopHeaderRefreshing() {
        edHeader?.stopRefresing()
    }
    /// 头部是否在刷新
    func headerIsRefreshing() -> Bool {
        if let isRefreshing = header?.isRefreshing {
            return isRefreshing
        }
        return false
    }
    /// 移除头部【移除下拉刷新】
    func removeRefreshHeader() {
        edHeader = nil
    }
}
// =================================================================
//                          上拉加载更多
// =================================================================
// MARK: - 上拉加载更多
extension UIScrollView {
    /// 给ScrollView和其子类添加底部【上拉加载更多】
    /// - Parameter handler: 上拉的回调
    /// - Returns: EDRefreshFooterView
    @discardableResult
    func addRefreshFooter(handler: @escaping RefreshHandler) -> RefreshFooter {
        let edFooter: RefreshFooter = RefreshFooter(handler: handler)
        self.edFooter = edFooter
        return edFooter
    }
    /// 停止上拉刷新
    func stopFooterRefreshing() {
        edFooter?.stopRefresing()
    }
    /// 停止刷新,并且更新状态至没有更多数据
    func stopFooterRefreshingWithNoMoreData() {
        edFooter?.stopRefresingWitnNoMoreData()
    }
    /// 是否在刷新
    func footerIsRefreshing() -> Bool {
        if let isRefreshing = edFooter?.isRefreshing() {
            return isRefreshing
        }
        return false
    }
    /// 恢复上拉加载更多标识【取消 没有更多数据的标识】
    func resetNoMoreData() {
        edFooter?.resetNoMoreData()
    }
    /// 移除底部【移除上拉加载更多】
    func removeRefreshFooter() {
        edFooter = nil
    }
}

// =================================================================
//                    header/footer属性关联
// =================================================================
// MARK: - edHeader/edFooter属性关联

private var kRefreshHeaderKey: Void?
private var kRefreshFooterKey: Void?

extension UIScrollView {
    var edHeader: RefreshHeader? {
        get {
            return (objc_getAssociatedObject(self, &kRefreshHeaderKey) as? RefreshHeader)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kRefreshHeaderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            if newValue == nil {
                self.es.removeRefreshHeader()
            } else {
                if self.header != newValue?.headerView {
                    self.es.removeRefreshHeader()
                    self.header = newValue?.headerView
                    guard let header = header else {
                        return
                    }
                    if header.superview == nil {
                        let headerH = header.animator.executeIncremental
                        header.frame = CGRect.init(x: 0.0, y: -headerH /* - contentInset.top */, width: self.bounds.size.width, height: headerH)
                        self.addSubview(header)
                    }
                }
            }
        }
    }
    var edFooter: RefreshFooter? {
        get {
            return (objc_getAssociatedObject(self, &kRefreshFooterKey) as? RefreshFooter)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kRefreshFooterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            if newValue == nil {
                self.es.removeRefreshFooter()
            } else {
                if self.footer != newValue?.footerView {
                    self.es.removeRefreshFooter()
                    self.footer = newValue?.footerView
                    guard let footer = footer else {
                        return
                    }
                    if footer.superview == nil {
                        let footerH = footer.animator.executeIncremental
                        footer.frame = CGRect.init(x: 0.0, y: self.contentSize.height + self.contentInset.bottom, width: self.bounds.size.width, height: footerH)
                        self.addSubview(footer)
                    }
                }
            }
        }
    }
}
