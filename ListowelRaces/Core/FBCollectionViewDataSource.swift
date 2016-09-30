//
//  FBCollectionViewDataSource.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 12/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FBCollectionViewDataSource: NSObject, UICollectionViewDataSource, FBDelegate {
    
    var collectionView : UICollectionView?
    var populateCell:((cell: UICollectionViewCell, object: NSObject) -> Void)?
    var array: FBArray?
    var section : Int = 1
    var reuseIdentifier : String
    var modelClass : AnyClass?

    
    func populateCellWithBlock(block : (UICollectionViewCell, object: NSObject) -> Void) {
        self.populateCell = block
    }
    
    
    init(query: FIRDatabaseQuery, modelClass model: AnyClass?, nibNamed: String?, cellReuseIdentifier: String, view : UICollectionView?, section : Int) {
        collectionView = view
        reuseIdentifier = cellReuseIdentifier
        modelClass = model
        super.init()
        self.array = FBArray(withQuery: query, delegate : self, modelClass: model)
        self.array!.delegate = self
        self.section = section
        if (nibNamed != nil) {
            let nib = UINib.init(nibName: nibNamed!, bundle: nil)
            self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: self.reuseIdentifier)
        }
        if model == nil {
            self.modelClass = FIRDataSnapshot.self
        }
        else {
            self.modelClass = model!
        }
    }
    
    convenience init(query: FIRDatabaseQuery, modelClass model: AnyClass?, cellReuseIdentifier: String, view : UICollectionView?) {
        self.init(query: query, modelClass: model, nibNamed: nil, cellReuseIdentifier: cellReuseIdentifier, view : view, section : 0)
    }
    
    convenience init(query: FIRDatabaseQuery, modelClass model: AnyClass?, nibNamed: String, cellReuseIdentifier: String, view : UICollectionView?) {
        self.init(query: query, modelClass: model, nibNamed: nibNamed, cellReuseIdentifier: cellReuseIdentifier, view : view, section : 0)
    }
    
    convenience init(query: FIRDatabaseQuery, cellReuseIdentifier: String, view : UICollectionView?) {
        self.init(query: query, modelClass: nil, nibNamed: nil, cellReuseIdentifier: cellReuseIdentifier, view : view, section : 0)
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView?.dequeueReusableCellWithReuseIdentifier(self.reuseIdentifier, forIndexPath: indexPath) {
            let snap = array![indexPath.row]
            if self.modelClass != nil && !self.modelClass!.isSubclassOfClass(FIRDataSnapshot.self) {
                let objFactory = ObjectFactory(withClass: self.modelClass)
                let model = objFactory.createFromSnapshot(snap) as! NSObject
                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                    model.setValuesForKeysWithDictionary(postDict)
                    if self.populateCell != nil {
                        self.populateCell!(cell: cell, object: model)
                    }
                }
            }
            else if self.populateCell != nil {
                self.populateCell!(cell: cell, object: snap)
            }
            return cell;
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array!.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func childAdded(object: AnyObject, atIndex: Int) {
        self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forRow: Int(atIndex), inSection: self.section)])
    }
    
    func childChanged(object: AnyObject, atIndex: Int) {
        self.collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forRow: Int(atIndex), inSection: self.section)])
    }
    
    func childRemoved(object: AnyObject, atIndex: Int) {
        self.collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forRow: Int(atIndex), inSection: self.section)])
    }
    
    func childMoved(object: AnyObject, fromIndex: Int, toIndex: Int) {
        self.collectionView?.moveItemAtIndexPath(NSIndexPath(forRow: Int(fromIndex), inSection: self.section), toIndexPath: NSIndexPath(forRow: Int(toIndex), inSection: self.section))
    }
    
    func cancelWithError(error: NSError) {
        NSLog("Something went wrong here")
    }

}