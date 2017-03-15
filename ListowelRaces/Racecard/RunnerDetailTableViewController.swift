//
//  RunnerDetailTableViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 08/09/2015.
//  Copyright © 2015 Jack McAuliffe. All rights reserved.
//

import UIKit


class RunnerDetailTableViewController: UITableViewController, FBDelegate {
    var runner: Runner?
    var race : Race?
    fileprivate var horseList : FBArray<Runner>?
    fileprivate var formList : FBArray<Form>?
    fileprivate var tipList : FBArray<Tip>?
    fileprivate let objectContext = ObjectContext()
    
    fileprivate func hasTips() -> Bool {
        return (tipList?.count)! > 0
    }
    
    override func loadView() {
        super.loadView()
        
        let formHeaderNib = UINib(nibName: "FormSectionHeaderView", bundle: nil)
        self.tableView?.register(formHeaderNib, forHeaderFooterViewReuseIdentifier: "FormHeader")
        
        let tipHeaderNib = UINib(nibName: "TipSectionHeaderView", bundle: nil)
        self.tableView?.register(tipHeaderNib, forHeaderFooterViewReuseIdentifier: "TipHeader")
        
        let tipButton = UIBarButtonItem.init(title: "Add Tip", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RunnerDetailTableViewController.addTip(_:)))
        self.navigationItem.rightBarButtonItem = tipButton;
        
        self.horseList = objectContext.getRunnerDetails(self.runner!, race: self.race!, delegate: self)
        self.tipList = objectContext.getTipsFor(self.runner!, delegate: self)
        self.formList = objectContext.getFormFor(self.runner!, delegate: self)
    }
    
    func addTip(_ sender: UIBarButtonItem) {
        objectContext.addTip(self.runner!, race: self.race!, parentView: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0
        }
        else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 80
        }
        else {
            return 40
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (hasTips()) {
            return 3;
        }
        return 2;
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1 && hasTips()) {
            let rawCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TipHeader")
            if let tipHeader = rawCell as? TipSectionHeaderView {
                return tipHeader
            }
            return nil;
        }
        else if (section >= 1) {
            let rawCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FormHeader")
            if let formHeader = rawCell as? FormSectionHeaderView {
                return formHeader
            }
            return nil;
        }
        else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return horseList!.count;
        }
        else if (section == 1 && hasTips()) {
            return tipList!.count;
        }
        else {
            return formList!.count;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let horseCell = tableView.dequeueReusableCell(withIdentifier: "HorseSummaryCell") as! HorseSummaryCell
            horseCell.runner = self.horseList?[indexPath.row]
            return horseCell;
        }
        else if (indexPath.section == 1 && hasTips()) {
            let tipCell = tableView.dequeueReusableCell(withIdentifier: "TipEntry") as! TipRowCell
            tipCell.tip = self.tipList?[indexPath.row]
            tipCell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.white : UIColor.lightGray;
            return tipCell;
        }
        else {
            let formCell = tableView.dequeueReusableCell(withIdentifier: "FormEntry") as! FormRowCell
            formCell.form = self.formList?[indexPath.row]
            formCell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.white : UIColor.lightGray;
            return formCell;
        }
    }
    
    func getSectionFor(object: AnyObject) -> Int {
        if object is Runner {
            return 0;
        }
        else if object is Tip {
            return 1;
        }
        else if object is Form {
            return hasTips() ? 2 : 1;
        }
        return -1;
    }
    
    // FB Delegate cells
    func childAdded(_ object: AnyObject, atIndex: Int) {
        let section = getSectionFor(object: object)
        self.tableView?.beginUpdates()
        if (object is Tip && atIndex == 0) {
            // inserting our first tip
            let indexSet = IndexSet([1])
            self.tableView?.moveSection(1, toSection: 2)
            self.tableView?.insertSections(indexSet, with: .automatic)
        }
        self.tableView?.insertRows(at: [IndexPath(row: Int(atIndex), section: section)], with: .automatic)
        self.tableView?.endUpdates()
    }
    
    func childChanged(_ object: AnyObject, atIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.reloadRows(at: [IndexPath(row: Int(atIndex), section: getSectionFor(object: object))], with: .automatic)
        self.tableView?.endUpdates()
    }
    
    func childRemoved(_ object: AnyObject, atIndex: Int) {
        let section = getSectionFor(object: object)
        self.tableView?.beginUpdates()
        self.tableView?.deleteRows(at: [IndexPath(row: Int(atIndex), section: section)], with: .automatic)
        if (object is Tip && tipList!.count == 0) {
            // removing our last tip
            let indexSet = IndexSet([1])
            //self.tableView?.moveSection(1, toSection: 2)
            self.tableView?.deleteSections(indexSet, with: .automatic)
        }
        self.tableView?.endUpdates()
    }
    
    func childMoved(_ object: AnyObject, fromIndex: Int, toIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.moveRow(at: IndexPath(row: Int(fromIndex), section: getSectionFor(object: object)), to: IndexPath(row: Int(toIndex), section: 1))
        self.tableView?.endUpdates()
    }
    
    func cancelWithError(_ error: Error) {
        NSLog("Something went wrong here")
    }

}
