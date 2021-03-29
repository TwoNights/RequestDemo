//
//  MainListController.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/28.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MainListController: UIViewController {
    // =================================================================
    //                              属性列表
    // =================================================================
    // MARK: - 属性列表
    private let disposeBag = DisposeBag()
    /// tableView
    private lazy var tableView: UITableView = {
        // 没导入约束库,暂时用frame实现
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 0
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(MainListCell.self, forCellReuseIdentifier: MainListCellID)
        tableView.addRefreshHeader {
            self.viewModel.refreshData()
        }
        tableView.edFooter = RefreshFooter(handler: { [weak self] in
            self?.tableView.edFooter?.stopRefresing()
            self?.viewModel.loadMoreData()
        })
        return tableView
    }()
    /// 头部标题
    private lazy var topLabel: UILabel = {
        let topLabel = UILabel()
        topLabel.numberOfLines = 3
        topLabel.text = "请求中"
        topLabel.backgroundColor = .yellow
        topLabel.adjustsFontSizeToFitWidth = true
        topLabel.textAlignment = .center
        return topLabel
    }()
    /// 历史切换按钮
    private lazy var switchButton: UIButton = {
        let switchButton = UIButton()
        switchButton.setTitle("点击显示历史记录", for: .normal)
        switchButton.setTitle("点击显示最新列表数据", for: .selected)
        switchButton.titleLabel?.adjustsFontSizeToFitWidth = true
        switchButton.backgroundColor = .darkGray
//        switchButton.addTarget(self, action: #selector(switchButtonAction), for: .touchUpInside)
        switchButton.setTitleColor(.black, for: .normal)
        switchButton.setTitleColor(.black, for: .selected)
        return switchButton
    }()
    /// viewModel
    private lazy var viewModel: MainListViewModel = MainListViewModel()
    // =================================================================
    //                              生命周期
    // =================================================================
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI配置
        configUI()
        // rx配置
        configRx()
        // 开启请求
        startRequest()
    }
    // =================================================================
    //                              私有方法
    // =================================================================
    // MARK: - 私有方法
    /// 切换按钮点击事件
    private func switchButtonAction() {
        switchButton.isSelected.toggle()
        viewModel.switchShowModel()
    }
    //swiftlint:disable  unused_closure_parameter
    /// Rx配置
    private func configRx() {
        switchButton.rx.tap.subscribe(onNext: { [weak self]_ in
            self?.switchButtonAction()
        }).disposed(by: disposeBag)
        viewModel.dataObserver.bind(to: tableView.rx.items(cellIdentifier: MainListCellID, cellType: MainListCell.self)) { row, item, cell in
            if self.switchButton.isSelected {
                cell.updateUI(model: item as? HistoryModel ?? HistoryModel(title: "", content: "", isSuccess: false))
            } else {
                cell.updateUI(model: item as? MainListModel ?? MainListModel(title: "", content: ""))
            }
        }.disposed(by: disposeBag)
    }
    //swiftlint:enable  unused_closure_parameter

    /// UI布局初始化
    private func configUI() {
        view.addSubview(topLabel)
        view.addSubview(switchButton)
        view.addSubview(tableView)
        topLabel.snp.makeConstraints { (_ maker) in
            maker.left.equalToSuperview()
            maker.top.equalTo(topLayoutGuide.snp.bottom)
            maker.width.equalTo(screenWidth * 0.5)
            maker.height.equalTo(60)
        }
        switchButton.snp.makeConstraints { (_ maker) in
            maker.right.equalToSuperview()
            maker.top.width.height.equalTo(topLabel)
        }
        tableView.snp.makeConstraints { (_ maker) in
            maker.top.equalTo(switchButton.snp_bottomMargin)
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
    }
    /// 开始请求数据
    private func startRequest() {
        viewModel.start { [weak self] (_ reponse, _ errorMsg) in
            switch reponse {
            case .fail:
                self?.topLabel.backgroundColor = .red
                self?.topLabel.text = "刷新失败,\(errorMsg ?? "")"
            case .success:
                self?.topLabel.backgroundColor = .green
                self?.topLabel.text =  "请求成功"
            default:
                break
            }
            self?.tableView.stopHeaderRefreshing()
            self?.tableView.stopFooterRefreshing()
        }
    }
}
