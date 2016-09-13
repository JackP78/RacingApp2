//
//  Race+FireBase.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 19/08/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import FirebaseDatabase
import SwiftyJSON

extension Race {
    func fromSnapshot (fromSnapShot snap: FIRDataSnapshot) {
        let jsonObject = JSON(snap.value!)
        self.distancefurlongs = (jsonObject["distanceYards"].number?.distanceString())!
        self.meetingdate = jsonObject["meetingDate"].date
        let dateTime = "\(jsonObject["meetingDate"])T\(jsonObject["scheduledTime"])"
        self.scheduledtime = timeString(Formatter.jsonDateTimeFormatter.dateFromString(dateTime))
        self.prizemoney = (jsonObject["prizeMoney"].number?.moneyString())!
        self.racetitle = jsonObject["raceTitle"].stringValue
    }
}