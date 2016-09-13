//
//  Form.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 09/09/2015.
//  Copyright © 2015 Jack McAuliffe. All rights reserved.
//

import Foundation
import SwiftyJSON

class Form  : NSObject {
    var course: String?
    var distanceBeaten: NSNumber? // distance behind next horse
    var distanceBehindWinner: NSNumber? // distance behind winning horse
    var distanceWon: NSNumber? // distance ahead, if the winner
    var distanceYards: NSNumber? // course distance in yards
    var finishPosition: NSNumber? // finishing position
    var going: String?
    var inRaceComment: String?
    var meetingDate: String?
    var numRunners: NSNumber? // number of runners
    var runnerId: NSNumber?
    var startingPrice: String?  // price as a fraction
    var startingPriceDecimal: NSNumber? // number of runners
    var winner: String?

    override init() {
        super.init()
    }
    
    func meetingdateString() -> String {
        if meetingDate != nil {
            let dateFormatter = NSDateFormatter()
            let dateParser = NSDateFormatter()
            dateFormatter.dateFormat = "d MMM yy"
            dateParser.dateFormat = "yyyy-MM-dd"
            return dateFormatter.stringFromDate(dateParser.dateFromString(meetingDate!)!)
        }
        else {
            return ""
        }
    }
    
    func finishpositionString() -> String {
        if finishPosition != nil && numRunners != nil {
            return "\(finishPosition!)/\(numRunners!)"
        }
        else if numRunners != nil {
            return "0/\(numRunners!)"
        }
        else {
            return ""
        }

    }
    
    func briefcommentString() -> String {
        var response: String = ""
        if finishPosition != nil {
            if (finishPosition! == 1) {
                response = "Won"
                if distanceWon != nil && distanceWon?.integerValue > 0 {
                    response += " by \(distanceWon!.integerValue)l"
                }
            }
            else {
                if distanceBehindWinner != nil && distanceBehindWinner?.integerValue > 0 {
                    response = "\(distanceBehindWinner!.integerValue)l "
                }
                if winner != nil {
                    response += "to \(winner!)"
                }
            }
            return response
        }
        else {
            return "no finish"
        }

    }
}