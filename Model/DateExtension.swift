//
//  DateExtension.swift
//  Nasa-Client
//
//  Created by Dmitrii on 21.08.2021.
//

import Foundation

extension Date {
    var timeIntervalSince1970inMilliseconds: TimeInterval {
        return self.timeIntervalSince1970 * 1000
    }
    var milisecondsSince1970: Int {
        return Int(timeIntervalSince1970inMilliseconds)
    }
    
    init(milisecondsSince1970: Int) {
        self = Date(timeIntervalSince1970: Double(milisecondsSince1970) / 1000)
    }
}
