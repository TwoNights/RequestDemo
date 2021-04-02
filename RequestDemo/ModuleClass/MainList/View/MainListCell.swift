//
//  MainListCell.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/28.
//
import UIKit
import SnapKit
let MainListCellID = "MainListCell"
// =================================================================
//                            协议
// =================================================================
// MARK: - 协议
protocol MainListCellProtocol: NSObjectProtocol {
    var titleLabel: UILabel { get set }
    var contentLabel: UILabel { get set }
    func configProtocolUI()
    func configTitleLabel()
    func configContentLabel()
    func updateUI<DataType: MainListModelProtocol>(model: DataType)
}
// =================================================================
//                          协议拓展
// =================================================================
// MARK: - 协议拓展
extension MainListCellProtocol where Self: UITableViewCell {
    func configProtocolUI() {
        selectionStyle = .none
        configTitleLabel()
        configContentLabel()
    }
    func configTitleLabel() {
        titleLabel = UILabel()
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(15)
            maker.bottom.equalToSuperview().offset(-15)
            maker.left.equalToSuperview().offset(15)
            maker.width.equalTo(120)
        }
    }
    func configContentLabel() {
        contentLabel = UILabel()
        contentLabel.textColor = .black
        contentLabel.numberOfLines = 0
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(15)
            maker.bottom.equalToSuperview().offset(-15)
            maker.right.equalToSuperview().offset(-15)
            maker.left.equalTo(titleLabel.snp.right).offset(5)
        }
    }
}
// =================================================================
//                          MainListCell
// =================================================================
// MARK: - MainListCell
class MainListCell: UITableViewCell, MainListCellProtocol {
    var titleLabel: UILabel = UILabel()
    var contentLabel: UILabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configProtocolUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateUI<DataType>(model: DataType) where DataType: MainListModelProtocol {
        titleLabel.text = model.title
        contentLabel.text = model.content
        titleLabel.textColor = .black
        if let history = model as? HistoryModel, !history.isSuccess {
            titleLabel.textColor = .red
        }
    }
}
