//
//  ISO8601DateFormatter.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 12/05/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class ISO8601DateFormatter: NSDateFormatter {
    static let sharedDateFormatter = ISO8601DateFormatter()
    
    override init() {
        super.init()
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
    }
}
