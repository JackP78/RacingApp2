//
//  FBCollectionViewDataSource.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 12/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FBCollectionViewDataSource<T>: NSObject, UICollectionViewDataSource, FBDelegate where T: ModelBase {
    
    var collectionView : UICollectionView?
    var populateCell:((_ cell: UICollectionViewCell, _ object: NSObject, _ indexPath: IndexPath) -> Void)?
    var array: FBArray<T>!
    var section : Int = 1
    var reuseIdentifier : String

    
    func populateCellWithBlock(_ block : @escaping (UICollectionViewCell, _ object: NSObject, _ indexPath: IndexPath) -> Void) {
        self.populateCell = block
    }
    
    
    init(query: DatabaseQuery, nibNamed: String?, cellReuseIdentifier: String, view : UICollectionView?, section : Int) {
        collectionView = view
        reuseIdentifier = cellReuseIdentifier
        super.init()
        self.array = FBArray<T>(withQuery: query, delegate : self)
        self.array.delegate = self
        self.section = section
        if (nibNamed != nil) {
            let nib = UINib.init(nibName: nibNamed!, bundle: nil)
            self.collectionView?.register(nib, forCellWithReuseIdentifier: self.reuseIdentifier)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) {
            let model = array[indexPath.row]
            self.populateCell?(cell, model, indexPath)
            return cell;
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
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
