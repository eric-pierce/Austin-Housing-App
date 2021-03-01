//
//  SecurityDataSource.swift
//  AustinHousing
//
//  Created by Eric Pierce on 2/28/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation

struct SecurityDataSource {
    let values = [0, 1]
    
    func title(for index: Int) -> String? {
        guard index < values.count else { return nil }
        return String(values[index])
    }
    
    func value(for index: Int) -> Double? {
        guard index < values.count else { return nil }
        return Double(values[index])
    }
}
