//
//  FBRace.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 27/02/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

func timeString(value : NSDate?) -> String {
    if let scheduledTime = value {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.stringFromDate(scheduledTime)
    }
    return ""
}

class Race : NSObject {
    
    var distanceYards: NSNumber = 0
    
    var courseName: String = ""
    
    var meetingDate: String = ""
    
    var scheduledTime: String = ""
    
    var prizeMoney: NSNumber = 0
    
    var raceTitle: String = ""
    
    var raceNumber: Int = 1
    
    var raceId: Int = 0
    
    var runners: [Runner] = []
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        NSLog("undefined key \(key)")
    }
}
