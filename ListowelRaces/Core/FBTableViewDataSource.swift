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
    var populateCell:((_ cell: UITableViewCell, _ object: NSObject) -> Void)?
    var section : Int = 1
    
    func populateCellWithBlock(_ block : @escaping (UITableViewCell, _ object: NSObject) -> Void) {
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
            self.tableView?.register(nib, forCellReuseIdentifier: self.reuseIdentifier)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array!.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier)
        let snap = array![(indexPath as NSIndexPath).row]
        if self.modelClass != nil && !self.modelClass!.isSubclass(of: FIRDataSnapshot.self) {
            let objFactory = ObjectFactory(with: self.modelClass)
            let model = objFactory?.create(from: snap) as! NSObject
            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                model.setValuesForKeys(postDict)
                if self.populateCell != nil {
                    self.populateCell!(cell!, model)
                }
            }
        }
        else if self.populateCell != nil {
            self.populateCell!(cell!, snap)
        }
        return cell!;
    }

    func childAdded(_ object: AnyObject, atIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.insertRows(at: [IndexPath(row: Int(atIndex), section: self.section)], with: .automatic)
        self.tableView?.endUpdates()
    }
    
    func childChanged(_ object: AnyObject, atIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.reloadRows(at: [IndexPath(row: Int(atIndex), section: self.section)], with: .automatic)
        self.tableView?.endUpdates()
    }
    
    func childRemoved(_ object: AnyObject, atIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.deleteRows(at: [IndexPath(row: Int(atIndex), section: self.section)], with: .automatic)
        self.tableView?.endUpdates()
    }
    
    func childMoved(_ object: AnyObject, fromIndex: Int, toIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.moveRow(at: IndexPath(row: Int(fromIndex), section: self.section), to: IndexPath(row: Int(toIndex), section: self.section))
        self.tableView?.endUpdates()
    }
    
    func cancelWithError(_ error: Error) {
        NSLog("Something went wrong here")
    }
}
