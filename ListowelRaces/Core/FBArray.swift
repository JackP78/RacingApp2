//
//  FBArray.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 06/07/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FirebaseDatabase

open class FBArray<T>: NSObject where T: ModelBase {
    fileprivate var snapShots = [FIRDataSnapshot]()
    var query : FIRDatabaseQuery
    var delegate : FBDelegate
    
    convenience init(withReference reference: FIRDatabaseReference, delegate : FBDelegate) {
        self.init(withReference: reference, delegate: delegate)
    }
    
    init(withQuery initQuery: FIRDatabaseQuery, delegate initDelegate : FBDelegate) {
        query = initQuery
        delegate = initDelegate
        super.init()
        self.initListeners()
    }
    
    subscript(index: Int) -> T? {
        get {
            let snapShot = snapShots[index];
            if let postDict = snapShot.value as? Dictionary<String, AnyObject> {
                let model = T()
                model.setValuesForKeys(postDict)
                return model
            } else {
                NSLog("cast to dictionary failed \(snapShot.value)")
            }
            return nil;
        }
    }
    
    deinit {
       self.query.removeAllObservers()
    }
    
    var count: Int {
        get {
            return snapShots.count
        }
    }
    
    open func refAtIndex(_ index: Int) -> FIRDatabaseReference {
        return snapShots[index].ref
    }
    open func keyForIndex(_ index: Int) -> String {
        return snapShots[index].key
    }
    
    fileprivate func indexForKey(_ key : String?) -> Int {
        var index = 0
        if let cKey = key {
            for snap in self.snapShots {
                if snap.key == cKey {
                    return index
                }
                index += 1
            }
        }
        return -1;
    }
    
    fileprivate func initListeners() {
        self.query.observe(.childAdded, andPreviousSiblingKeyWith: { (snapShot:FIRDataSnapshot, previousChildKey: String?) in
            let index = self.indexForKey(previousChildKey) + 1
            self.snapShots.insert(snapShot, at: index)
            self.delegate.childAdded(snapShot, atIndex: index)
            }
        ) { (error : Error) in
            self.delegate.cancelWithError(error)
        }
        self.query.observe(.childMoved, andPreviousSiblingKeyWith: { (snapShot:FIRDataSnapshot, previousChildKey : String?) in
            let fromIndex = self.indexForKey(snapShot.key)
            let toIndex = self.indexForKey(previousChildKey) + 1
            self.snapShots.remove(at: fromIndex)
            self.snapShots.insert(snapShot, at: toIndex)
            self.delegate.childMoved(snapShot, fromIndex: fromIndex, toIndex: toIndex)
        }) { (error : Error) in
            self.delegate.cancelWithError(error)
        }
        self.query.observe(.childRemoved, with: { (snapShot: FIRDataSnapshot) in
            let index = self.indexForKey(snapShot.key)
            self.snapShots.remove(at: index)
            self.delegate.childRemoved(snapShot, atIndex: index)
        }) { (error : Error) in
            self.delegate.cancelWithError(error)
        }
        self.query.observe(.childChanged, with: { (snapShot: FIRDataSnapshot) in
            let index = self.indexForKey(snapShot.key)
            self.snapShots[index] = snapShot
            self.delegate.childChanged(snapShot, atIndex: index)
        }) { (error : Error) in
            self.delegate.cancelWithError(error)
        }
    }
}
