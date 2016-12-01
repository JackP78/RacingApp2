//
//  Runner.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 08/09/2015.
//  Copyright © 2015 Jack McAuliffe. All rights reserved.
//

import Foundation
import Firebase

class Runner : ModelBase {
    var age: NSNumber?
    var clothNumber: NSNumber?
    var countryBred: String?
    var damName: String?
    var forecastPrice: String?
    var forecastPriceDecimal: NSNumber?
    var formFigures: String?
    var jockeyName: String?
    var jockeyColours: String?
    var name: String?
    var numberTips: NSNumber?
    var officialRating: NSNumber?
    var ownerName: NSNumber?
    var runnerId: Int = 0
    var silksUrl: String?
    var sireName: String?
    var trainerName: String?
    var speed: Int = 50
    
    required init() {
        super.init()
    }
}
