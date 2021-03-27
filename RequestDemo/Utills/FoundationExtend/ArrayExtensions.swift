//
//  ArrayExtensions.swift
//  RequestDemo
//
//  Created by Leslie on 2021/3/27.
//
import UIKit
extension Array {
    /// 防止数组越界
    ///       let model = optionalArray[indexPath.row, true]
    subscript(index: Int, safe: Bool) -> Element? {
        if safe {
            if self.count > index {
                return self[index]
            } else {
                return nil
            }
        } else {
            return self[index]
        }
    }
}
