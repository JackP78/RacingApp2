//
//  FBDelegate.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 19/08/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//
import UIKit

protocol FBDelegate {
    func childAdded(object: AnyObject, atIndex: Int)
    
    func childChanged(object: AnyObject, atIndex: Int)
    
    func childRemoved(object: AnyObject, atIndex: Int)
    
    func childMoved(object: AnyObject, fromIndex: Int, toIndex: Int)
    
    func cancelWithError(error: NSError)
}
