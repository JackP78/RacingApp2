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
    fileprivate var snapShots = [DataSnapshot]()
    var query : DatabaseQuery
    var delegate : FBDelegate
    
    convenience init(withReference reference: DatabaseReference, delegate : FBDelegate) {
        self.init(withReference: reference, delegate: delegate)
    }
    
    init(withQuery initQuery: DatabaseQuery, delegate initDelegate : FBDelegate) {
        query = initQuery
        delegate = initDelegate
        super.init()
        self.initListeners()
    }
    
    fileprivate func getModelFrom(snapShot: DataSnapshot) -> T? {
        if let postDict = snapShot.value as? Dictionary<String, AnyObject> {
            let model = T()
            model.setValuesForKeys(postDict)
            return model
        }
        else {
            NSLog("problem here jack \(snapShot.ref) \(snapShot.value)");
            return nil;
        }
    }
    
    subscript(index: Int) -> T {
        get {
            return getModelFrom(snapShot: snapShots[index])!;
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
    
    open func refAtIndex(_ index: Int) -> DatabaseReference {
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
        self.query.observe(.childAdded, andPreviousSiblingKeyWith: { (snapShot:DataSnapshot, previousChildKey: String?) in
            if let modelObject = self.getModelFrom(snapShot: snapShot) {
                let index = self.indexForKey(previousChildKey) + 1
                self.delegate.beginUpdates()
                self.snapShots.insert(snapShot, at: index)
                self.delegate.childAdded(modelObject, atIndex: index)
            }
            }
        ) { (error : Error) in
            self.delegate.cancelWithError(error)
        }
        self.query.observe(.childMoved, andPreviousSiblingKeyWith: { (snapShot:DataSnapshot, previousChildKey : String?) in
            if let modelObject = self.getModelFrom(snapShot: snapShot) {
                let fromIndex = self.indexForKey(snapShot.key)
                let toIndex = self.indexForKey(previousChildKey) + 1
                self.delegate.beginUpdates()
                self.snapShots.remove(at: fromIndex)
                self.snapShots.insert(snapShot, at: toIndex)
                self.delegate.childMoved(modelObject, fromIndex: fromIndex, toIndex: toIndex)
            }
        }) { (error : Error) in
            self.delegate.cancelWithError(error)
        }
        self.query.observe(.childRemoved, with: { (snapShot: DataSnapshot) in
            if let modelObject = self.getModelFrom(snapShot: snapShot) {
                let index = self.indexForKey(snapShot.key)
                self.delegate.beginUpdates()
                self.snapShots.remove(at: index)
                self.delegate.childRemoved(modelObject, atIndex: index)
            }
            
        }) { (error : Error) in
            self.delegate.cancelWithError(error)
        }
        self.query.observe(.childChanged, with: { (snapShot: DataSnapshot) in
            if let modelObject = self.getModelFrom(snapShot: snapShot) {
                let index = self.indexForKey(snapShot.key)
                self.delegate.beginUpdates()
                self.snapShots[index] = snapShot
                self.delegate.childChanged(modelObject, atIndex: index)
            }
        }) { (error : Error) in
            self.delegate.cancelWithError(error)
        }
    }
}
