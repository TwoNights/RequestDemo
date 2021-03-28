//
//  RefreshHeaderAnimator.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//

import UIKit
import SnapKit
import Eddid_ESPullToRefresh

protocol RefreshHeaderAnimatorDelegate: NSObjectProtocol {
    /// 开始动画
    func refreshAnimationBegin()
}
/// 下拉刷新动画
class RefreshHeaderAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    // ===============================
    //  ESRefreshAnimatorProtocol
    // ===============================
    public var insets: UIEdgeInsets = UIEdgeInsets.zero
    public var view: UIView { return self }
    /// 触发到刷新的偏移量
    public var trigger: CGFloat = 56.0
    /// 头部视图的高度
    public var executeIncremental: CGFloat = 56.0
    public var state: ESRefreshViewState = .pullToRefresh
    // =======================
    //       自定义属性
    // =======================
    /// 代理
    weak var delegate: RefreshHeaderAnimatorDelegate?
    /// 图片的大小
    private let imageViewSize = CGSize(width: 40, height: 40)
    /// 图片
    private let imageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "pullRefresh_0")
        var images = [UIImage]()
        for idx in 0 ... 16 {
            if let aImage = UIImage(named: "pullRefresh_\(idx)") {
                images.append(aImage)
            }
        }
        imageView.animationDuration = 1.0
        imageView.animationImages = images
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    /// 提示的label
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.text = "下拉可以刷新"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    // =================================================================
    //                           构造器
    // =================================================================
    // MARK: - 构造器
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-(trigger - imageViewSize.height) * 0.3)
            make.centerX.equalToSuperview().offset(-50.0)
            make.size.equalTo(imageViewSize)
        }
        self.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(10.0)
            make.centerY.equalTo(imageView).offset(5.0)
        }
    }
    /// 配置标题颜色
    func configTitleColor(color: UIColor) {
        tipLabel.textColor = color
    }
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// =================================================================
//                       ESRefreshProtocol
// =================================================================
// MARK: - ESRefreshProtocol
extension RefreshHeaderAnimator {
    /// 开始动画
    public func refreshAnimationBegin(view: ESRefreshComponent) {
        self.imageView.animationRepeatCount = 0
        self.imageView.startAnimating()
        self.delegate?.refreshAnimationBegin()
    }
    /// 结束动画
    public func refreshAnimationEnd(view: ESRefreshComponent) {
        imageView.stopAnimating()
        imageView.image = UIImage.init(named: "pullRefresh_0")
    }
    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        var imageIndex = Int(progress * 16.0)
        if imageIndex > 16 {
            imageIndex = 16
        }
        imageView.image = UIImage(named: "pullRefresh_\(imageIndex)")
    }
    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
        switch state {
        case .pullToRefresh:
            tipLabel.text = "下拉可以刷新"
        case .releaseToRefresh:
            tipLabel.text = "松开立即刷新"
            imageView.startAnimating()
        case .refreshing:
            tipLabel.text = "正在刷新中..."
        default:
            break
        }
    }
}
