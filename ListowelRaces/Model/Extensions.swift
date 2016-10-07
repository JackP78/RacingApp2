//
//  Extensions.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 02/03/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import Foundation

extension NSNumber {
    func moneyString() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        return currencyFormatter.string(from: self)!
    }
    
    func distanceString() -> String {
        let distanceFurlongs: Int = Int(self) / 220;
        var labelText: String
        if (distanceFurlongs / 8) > 0 {
            labelText = "\(distanceFurlongs / 8)m "
        }
        else {
            labelText = ""
        }
        if distanceFurlongs % 8 > 0 {
            labelText = labelText + "\(distanceFurlongs % 8)f"
        }
        return labelText
    }
}
