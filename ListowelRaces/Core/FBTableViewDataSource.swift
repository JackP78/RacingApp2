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
    var array: FBArray!
    var reuseIdentifier : String
    var tableView : UITableView?
    var populateCell:((_ cell: UITableViewCell, _ object: NSObject) -> Void)?
    var section : Int = 1
    
    func populateCellWithBlock(_ block : @escaping (UITableViewCell, _ object: NSObject) -> Void) {
        self.populateCell = block
    }
    
    init(query: FIRDatabaseQuery, modelClass model: AnyClass?, nibNamed: String?, cellReuseIdentifier: String, view : UITableView, section : Int) {
        reuseIdentifier = cellReuseIdentifier
        tableView = view
        super.init()
        array = FBArray(withQuery: query, delegate : self, modelClass: model)
        self.reuseIdentifier = cellReuseIdentifier
        self.tableView = view
        self.section = section
        if (nibNamed != nil) {
            let nib = UINib.init(nibName: nibNamed!, bundle: nil)
            self.tableView?.register(nib, forCellReuseIdentifier: self.reuseIdentifier)
        }
    }
    
    convenience init(query: FIRDatabaseQuery, modelClass model: AnyClass?, cellReuseIdentifier: String, view : UITableView) {
        self.init(query: query, modelClass: model, nibNamed: nil, cellReuseIdentifier: cellReuseIdentifier, view : view, section : 0)
    }
    
    convenience init(query: FIRDatabaseQuery, modelClass model: AnyClass?, nibNamed: String, cellReuseIdentifier: String, view : UITableView) {
        self.init(query: query, modelClass: model, nibNamed: nibNamed, cellReuseIdentifier: cellReuseIdentifier, view : view, section : 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier)
        let model = array[(indexPath as NSIndexPath).row]
        self.populateCell!(cell!, model)
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
