//
//  MainListModel.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/28.
//

import Foundation
// =================================================================
//                          协议
// =================================================================
// MARK: - 协议
protocol MainListModelProtocol {
    var title: String { get set }
    var content: String { get set }
}
// =================================================================
//                          MainListModel
// =================================================================
// MARK: - MainListModel
struct MainListModel: MainListModelProtocol {
    var title: String
    var content: String
}
// =================================================================
//                          HistoryModel
// =================================================================
// MARK: - HistoryModel
struct HistoryModel: MainListModelProtocol {
    var title: String
    var content: String
    var isSuccess: Bool
}
