//
//  Date+Extension.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/05/05.
//

import Foundation

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}
