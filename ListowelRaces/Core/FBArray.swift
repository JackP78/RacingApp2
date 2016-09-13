//
//  FBArray.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 06/07/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FirebaseDatabase

public class FBArray: NSObject {
    var snapShots = [FIRDataSnapshot]()
    var query : FIRDatabaseQuery
    var delegate : FBDelegate
    var modelClass : AnyClass?
    
    convenience init(withReference reference: FIRDatabaseReference, delegate : FBDelegate, modelClass : AnyClass?) {
        self.init(withReference: reference, delegate: delegate, modelClass: modelClass)
    }
    
    init(withQuery initQuery: FIRDatabaseQuery, delegate initDelegate : FBDelegate, modelClass initModelClass : AnyClass?) {
        query = initQuery
        delegate = initDelegate
        modelClass = initModelClass
        super.init()
        self.initListeners()
    }
    
    subscript(index: Int) -> FIRDataSnapshot {
        get {
            return snapShots[index]
        }
        set {
            snapShots[index] = newValue
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
    
    public func modelClassAtIndex(index: Int) -> NSObject? {
        let objFactory = ObjectFactory(withClass: self.modelClass)
        let snap = snapShots[index]
        let model = objFactory.createFromSnapshot(snap) as! NSObject
        if let postDict = snap.value as? Dictionary<String, AnyObject> {
            model.setValuesForKeysWithDictionary(postDict)
            return model
        }
        return nil
    }
    
    public func keyForIndex(index: Int) -> String {
        return snapShots[index].key
    }
    
    private func indexForKey(key : String?) -> Int {
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
    
    private func initListeners() {
        self.query.observeEventType(.ChildAdded, andPreviousSiblingKeyWithBlock: { (snapShot:FIRDataSnapshot, previousChildKey: String?) in
            let index = self.indexForKey(previousChildKey) + 1
            self.snapShots.insert(snapShot, atIndex: index)
            self.delegate.childAdded(snapShot, atIndex: index)
            }
        ) { (error : NSError) in
            self.delegate.cancelWithError(error)
        }
        self.query.observeEventType(.ChildMoved, andPreviousSiblingKeyWithBlock: { (snapShot:FIRDataSnapshot, previousChildKey : String?) in
            let fromIndex = self.indexForKey(snapShot.key)
            let toIndex = self.indexForKey(previousChildKey) + 1
            self.snapShots.removeAtIndex(fromIndex)
            self.snapShots.insert(snapShot, atIndex: toIndex)
            self.delegate.childMoved(snapShot, fromIndex: fromIndex, toIndex: toIndex)
        }) { (error : NSError) in
            self.delegate.cancelWithError(error)
        }
        self.query.observeEventType(.ChildRemoved, withBlock: { (snapShot: FIRDataSnapshot) in
            let index = self.indexForKey(snapShot.key)
            self.snapShots.removeAtIndex(index)
            self.delegate.childRemoved(snapShot, atIndex: index)
        }) { (error : NSError) in
            self.delegate.cancelWithError(error)
        }
        self.query.observeEventType(.ChildChanged, withBlock: { (snapShot: FIRDataSnapshot) in
            let index = self.indexForKey(snapShot.key)
            self.snapShots[index] = snapShot
            self.delegate.childChanged(snapShot, atIndex: index)
        }) { (error : NSError) in
            self.delegate.cancelWithError(error)
        }
    }
}
