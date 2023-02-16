//
//  Extension+String.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.02.2023.
//

import UIKit

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
