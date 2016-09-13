//
//  FBExtensions.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 25/05/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON
import MapKit

var localinfoRef = FIRDatabase.database().reference().child("localinfo")

extension LocalInfoEntry {
    func saveInBackgroundWithBlock(completion: (result: String) -> Void) {
        let newLocalInfo = localinfoRef.childByAutoId() // 1
        let infoData:[String:AnyObject] = [ // 2
            "name": self.name!,
            "type": self.type!,
            "excerptDescription" : self.excerptDescription!,
            "email" : self.email!,
            "phone" : self.phone!,
            "url" : self.url!,
            "imageUrl" : self.imageUrl!
            //,"latitude" : Double((self.location?.coordinate.latitude)!)
            //,"longitude" : Double((self.location?.coordinate.longitude)!)
        ]
        newLocalInfo.setValue(infoData)
    }
    
    class func findAll(near: String, forEach: (current: LocalInfoEntry) -> Void) {
        // Attach an asynchronous callback to read the data at our posts reference
        localinfoRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            // populate the local info an send it back to the closure
            let jsonObject = JSON(snapshot.value!)
            let localInfo = LocalInfoEntry()
            localInfo.name = jsonObject["name"].string
            localInfo.type = jsonObject["type"].string
            localInfo.excerptDescription = jsonObject["excerptDescription"].string
            localInfo.email = jsonObject["email"].string
            localInfo.phone = jsonObject["phone"].string
            localInfo.url = jsonObject["url"].string
            localInfo.imageUrl = jsonObject["imageUrl"].string
            let lat = CLLocationDegrees(jsonObject["latitude"].doubleValue)
            let long = CLLocationDegrees(jsonObject["longitude"].doubleValue)
            localInfo.location = CLLocation(latitude: lat, longitude: long)
            forEach(current: localInfo)
            }, withCancelBlock: { error in
            print(error.description)
        })
    }
}
