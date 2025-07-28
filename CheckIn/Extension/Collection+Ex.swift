//
//  Collection+Ex.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 21/08/2024.
//

import Foundation


extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
