//
//  FBDelegate.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 19/08/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//
import UIKit

protocol FBDelegate {
    func childAdded(_ object: AnyObject, atIndex: Int)
    
    func childChanged(_ object: AnyObject, atIndex: Int)
    
    func childRemoved(_ object: AnyObject, atIndex: Int)
    
    func childMoved(_ object: AnyObject, fromIndex: Int, toIndex: Int)
    
    func cancelWithError(_ error: Error)
}
