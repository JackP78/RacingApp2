//
//  FireDataISO8601DateFormatter.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 11/05/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

class FireDataISO8601DateFormatter: ISO8601DateFormatter {
    class func sharedFormatter() -> FireDataISO8601DateFormatter {
        var dictionary: [NSObject : AnyObject] = NSThread.currentThread().threadDictionary()
        var dateFormatterKey: String = "FireDataISO8601DateFormatter"
        var dateFormatter: FireDataISO8601DateFormatter = (dictionary[dateFormatterKey] as! FireDataISO8601DateFormatter)
        if dateFormatter == nil {
            dateFormatter = FireDataISO8601DateFormatter()
            dateFormatter.includeTime = true
            dictionary[dateFormatterKey] = dateFormatter
        }
        return dateFormatter
    }
}
