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
    var populateCell:((_ cell: UICollectionViewCell, _ object: NSObject) -> Void)?
    var array: FBArray?
    var section : Int = 1
    var reuseIdentifier : String
    var modelClass : AnyClass?

    
    func populateCellWithBlock(_ block : @escaping (UICollectionViewCell, _ object: NSObject) -> Void) {
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
            self.collectionView?.register(nib, forCellWithReuseIdentifier: self.reuseIdentifier)
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
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) {
            let snap = array![(indexPath as NSIndexPath).row]
            if self.modelClass != nil && !self.modelClass!.isSubclass(of: FIRDataSnapshot.self) {
                let objFactory = ObjectFactory(with: self.modelClass)
                let model = objFactory?.create(from: snap) as! NSObject
                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                    model.setValuesForKeys(postDict)
                    if self.populateCell != nil {
                        self.populateCell!(cell, model)
                    }
                }
            }
            else if self.populateCell != nil {
                self.populateCell!(cell, snap)
            }
            return cell;
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array!.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func childAdded(_ object: AnyObject, atIndex: Int) {
        self.collectionView?.insertItems(at: [IndexPath(row: Int(atIndex), section: self.section)])
    }
    
    func childChanged(_ object: AnyObject, atIndex: Int) {
        self.collectionView?.reloadItems(at: [IndexPath(row: Int(atIndex), section: self.section)])
    }
    
    func childRemoved(_ object: AnyObject, atIndex: Int) {
        self.collectionView?.deleteItems(at: [IndexPath(row: Int(atIndex), section: self.section)])
    }
    
    func childMoved(_ object: AnyObject, fromIndex: Int, toIndex: Int) {
        self.collectionView?.moveItem(at: IndexPath(row: Int(fromIndex), section: self.section), to: IndexPath(row: Int(toIndex), section: self.section))
    }
    
    func cancelWithError(_ error: Error) {
        NSLog("Something went wrong here")
    }

}
