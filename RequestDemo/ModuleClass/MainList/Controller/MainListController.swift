//
//  MainListController.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/28.
//

import UIKit
import SnapKit
class MainListController: UIViewController {
    // =================================================================
    //                              属性列表
    // =================================================================
    // MARK: - 属性列表
    /// tableView
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 0
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
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
        switchButton.addTarget(self, action: #selector(switchButtonAction), for: .touchUpInside)
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
        // 开启请求
        startRequest()
    }
    // =================================================================
    //                              私有方法
    // =================================================================
    // MARK: - 私有方法
    /// 切换按钮点击事件
    @objc private func switchButtonAction() {
        switchButton.isSelected.toggle()
        viewModel.switchShowModel()
        tableView.endUpdates()
        tableView.reloadData()
    }
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
            self?.tableView.endUpdates()
            self?.tableView.reloadData()
            self?.tableView.stopHeaderRefreshing()
            self?.tableView.stopFooterRefreshing()
        }
    }
}
// =================================================================
//                    tableView代理/数据源
// =================================================================
// MARK: - tableView代理
extension MainListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.readModelArray()?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainListCellID) as? MainListCell ?? MainListCell(style: .subtitle, reuseIdentifier: MainListCellID)
        if let modelArray = viewModel.readModelArray() {
            if switchButton.isSelected {
                cell.updateUI(model: modelArray[indexPath.row, true] as? HistoryModel ?? HistoryModel(title: "", content: "", isSuccess: false))
            } else {
                cell.updateUI(model: modelArray[indexPath.row, true] as? MainListModel ?? MainListModel(title: "", content: ""))
            }
        }
        return cell
    }
}
