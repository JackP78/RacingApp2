//
//  Friend.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 03/11/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import Foundation
import Gloss
import RealmSwift

protocol Friend {
    var name : String? { get set }
    var fbId : String? { get set }
    var pictureUrl : String? { get set }
}

class FriendJSON : Friend, JSONDecodable {
    var name : String?
    var fbId : String?
    var pictureUrl : String?

    required init?(json: JSON) {
        self.fbId = "id" <~~ json
        self.name = "name" <~~ json
        self.pictureUrl = "picture.data.url" <~~ json
    }
}

class FriendEntity : Object, Friend {
    dynamic var name : String?
    dynamic var fbId : String?
    dynamic var pictureUrl : String?
    
    convenience init(friend: Friend) {
        self.init()
        self.name = friend.name
        self.fbId = friend.fbId
        self.pictureUrl = friend.pictureUrl
    }
    
    override static func primaryKey() -> String? {
        return "fbId"
    }
}
