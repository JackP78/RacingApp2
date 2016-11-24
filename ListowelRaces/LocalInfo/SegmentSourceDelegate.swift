//
//  SegmentSourceDelegate.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 16/11/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import Foundation

protocol SegmentDelegateSource {
    func getSegments() -> [(name: String, value: UIViewController)]
}
