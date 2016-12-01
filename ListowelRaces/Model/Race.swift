//
//  FBRace.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 27/02/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

func timeString(_ value : Date?) -> String {
    if let scheduledTime = value {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: scheduledTime)
    }
    return ""
}

class Race : ModelBase {
    
    var distanceYards: NSNumber = 0
    
    var courseName: String = ""
    
    var meetingDate: String = ""
    
    var scheduledTime: String = ""
    
    var prizeMoney: NSNumber = 0
    
    var raceTitle: String = ""
    
    var raceNumber: Int = 1
    
    var raceId: Int = 0
    
    var runners: [Runner] = []
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        NSLog("undefined key \(key)")
    }
    
    required init() {
        super.init()
    }
}
