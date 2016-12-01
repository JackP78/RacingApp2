//
//  Form.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 09/09/2015.
//  Copyright © 2015 Jack McAuliffe. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Form  : ModelBase {
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

    required init() {
        super.init()
    }
    
    func meetingdateString() -> String {
        if meetingDate != nil {
            let dateFormatter = DateFormatter()
            let dateParser = DateFormatter()
            dateFormatter.dateFormat = "d MMM yy"
            dateParser.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: dateParser.date(from: meetingDate!)!)
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
                if distanceWon != nil && distanceWon?.intValue > 0 {
                    response += " by \(distanceWon!.intValue)l"
                }
            }
            else {
                if distanceBehindWinner != nil && distanceBehindWinner?.intValue > 0 {
                    response = "\(distanceBehindWinner!.intValue)l "
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
