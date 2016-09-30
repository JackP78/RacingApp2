//
//  LocalInforEntry.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 27/01/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import Foundation
import MapKit

class LocalInfoEntry : NSObject, MKAnnotation {
    var name: String?
    var type: String?
    var excerptDescription: String?
    var email: String?
    var phone: String?
    var url: String?
    var imageUrl: String?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var location: CLLocation?
    
    // MKAnnontation protocol properties
    @objc var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    }
    
    @objc var title: String? {
        return name
    }
    
    @objc var subtitle: String? {
        return type
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        NSLog("No setting for key \(key)")
    }
}