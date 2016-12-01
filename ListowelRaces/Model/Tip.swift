//
//  Tip.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 31/03/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import Foundation

class Tip : ModelBase {
    var name : String?
    var tipsterScore: Int = 0
    var userId: String?
    var runnerId : Int = 0
    var raceId : Int = 0
    
    required init() {
        super.init()
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        NSLog("key \(key)")
        super.setValue(value, forKey: key)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        NSLog("undefined key \(key)")
    }
}
