//
//  FBTableViewDataSource.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 06/07/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FBTableViewDataSource: NSObject, UITableViewDataSource, FBDelegate {
    var array: FBArray?
    var reuseIdentifier : String
    var tableView : UITableView?
    var modelClass : AnyClass?
    var populateCell:((cell: UITableViewCell, object: NSObject) -> Void)?
    var section : Int = 1
    
    func populateCellWithBlock(block : (UITableViewCell, object: NSObject) -> Void) {
        self.populateCell = block
    }
    
    init(query: FIRDatabaseQuery, modelClass model: AnyClass?, nibNamed: String?, cellReuseIdentifier: String, view : UITableView, section : Int) {
        reuseIdentifier = cellReuseIdentifier
        tableView = view
        modelClass = model
        super.init()
        self.array = FBArray(withQuery: query, delegate : self, modelClass: model)
        self.array!.delegate = self
        self.reuseIdentifier = cellReuseIdentifier
        self.tableView = view
        self.section = section
        if (nibNamed != nil) {
            let nib = UINib.init(nibName: nibNamed!, bundle: nil)
            self.tableView?.registerNib(nib, forCellReuseIdentifier: self.reuseIdentifier)
        }
        if model == nil {
            self.modelClass = FIRDataSnapshot.self
        }
        else {
            self.modelClass = model!
        }
    }
    
    convenience init(query: FIRDatabaseQuery, modelClass model: AnyClass?, cellReuseIdentifier: String, view : UITableView) {
        self.init(query: query, modelClass: model, nibNamed: nil, cellReuseIdentifier: cellReuseIdentifier, view : view, section : 0)
    }
    
    convenience init(query: FIRDatabaseQuery, modelClass model: AnyClass?, nibNamed: String, cellReuseIdentifier: String, view : UITableView) {
        self.init(query: query, modelClass: model, nibNamed: nibNamed, cellReuseIdentifier: cellReuseIdentifier, view : view, section : 0)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier)
        let snap = array![indexPath.row]
        if self.modelClass != nil && !self.modelClass!.isSubclassOfClass(FIRDataSnapshot.self) {
            let objFactory = ObjectFactory(withClass: self.modelClass)
            let model = objFactory.createFromSnapshot(snap) as! NSObject
            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                model.setValuesForKeysWithDictionary(postDict)
                if self.populateCell != nil {
                    self.populateCell!(cell: cell!, object: model)
                }
            }
        }
        else if self.populateCell != nil {
            self.populateCell!(cell: cell!, object: snap)
        }
        return cell!;
    }

    func childAdded(object: AnyObject, atIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.insertRowsAtIndexPaths([NSIndexPath(forRow: Int(atIndex), inSection: self.section)], withRowAnimation: .Automatic)
        self.tableView?.endUpdates()
    }
    
    func childChanged(object: AnyObject, atIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.reloadRowsAtIndexPaths([NSIndexPath(forRow: Int(atIndex), inSection: self.section)], withRowAnimation: .Automatic)
        self.tableView?.endUpdates()
    }
    
    func childRemoved(object: AnyObject, atIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.deleteRowsAtIndexPaths([NSIndexPath(forRow: Int(atIndex), inSection: self.section)], withRowAnimation: .Automatic)
        self.tableView?.endUpdates()
    }
    
    func childMoved(object: AnyObject, fromIndex: Int, toIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.moveRowAtIndexPath(NSIndexPath(forRow: Int(fromIndex), inSection: self.section), toIndexPath: NSIndexPath(forRow: Int(toIndex), inSection: self.section))
        self.tableView?.endUpdates()
    }
    
    func cancelWithError(error: NSError) {
        NSLog("Something went wrong here")
    }
}
