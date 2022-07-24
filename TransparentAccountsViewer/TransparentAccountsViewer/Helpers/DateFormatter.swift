//
//  DateFormatter.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 24.07.2022.
//

import Foundation
import SwiftUI

extension String {
    var formatDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        let formated = dateFormatter.date(from: self) ?? Date()
        let calendar = Calendar.current.dateComponents([.year], from: formated)
        if calendar.year == 3000 {
            return "unlimited"
        }
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: formated)
    }
}
