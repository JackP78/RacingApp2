//
//  LRRunnerTableViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 15/08/2015.
//  Copyright (c) 2015 Jack McAuliffe. All rights reserved.
//

import UIKit


class LRRunnerTableViewController: UITableViewController, FBDelegate {
    fileprivate var objectContext = ObjectContext()
    var array: FBArray<Runner>?
    var raceIndex: Int=0
    var currentRace: Race?
    var titleDelegate : PageTitleDelegate?
    
    override func viewDidLoad() {
        self.title = "Race"
        
        //let headerNib = UINib.init(nibName: "RaceSummaryCellTableViewCell", bundle: nil)
        //self.tableView?.register(headerNib, forCellReuseIdentifier: "Header")
        
        let headerNib = UINib(nibName: "RaceSummaryHeader", bundle: nil)
        self.tableView?.register(headerNib, forHeaderFooterViewReuseIdentifier: "Header")
	
	
        let horseNib = UINib.init(nibName: "HorseSummaryCell", bundle: nil)
        self.tableView?.register(horseNib, forCellReuseIdentifier: "Main")
        
        
        super.viewDidLoad()
        self.array = objectContext.getRunnersForRace(self.currentRace!, delegate: self)
        
        self.tableView.dataSource = self;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array!.count;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rawCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header")
        if let cell = rawCell as? RaceSummaryHeader {
            cell.race = self.currentRace
            return cell
        }
        return nil;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = tableView.dequeueReusableCell(withIdentifier: "Main")
        if let cell = rawCell as? HorseSummaryCell {
            cell.runner = self.array?[indexPath.row]
            return cell
        }
        return rawCell!;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleDelegate?.titleChanged(newTitle: (currentRace?.scheduledTime)!)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showForm", sender: self)
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using [segue destinationViewController].
        if let detailScene = segue.destination as? RunnerDetailTableViewController {
            // Pass the selected object to the destination view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow {
                detailScene.race = self.currentRace
                detailScene.runner = self.array![indexPath.row]
            }
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // FB Delegate cells
    func childAdded(_ object: AnyObject, atIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.insertRows(at: [IndexPath(row: Int(atIndex), section: 0)], with: .automatic)
        self.tableView?.endUpdates()
    }
    
    func childChanged(_ object: AnyObject, atIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.reloadRows(at: [IndexPath(row: Int(atIndex), section: 0)], with: .automatic)
        self.tableView?.endUpdates()
    }
    
    func childRemoved(_ object: AnyObject, atIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.deleteRows(at: [IndexPath(row: Int(atIndex), section: 0)], with: .automatic)
        self.tableView?.endUpdates()
    }
    
    func childMoved(_ object: AnyObject, fromIndex: Int, toIndex: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.moveRow(at: IndexPath(row: Int(fromIndex), section: 0), to: IndexPath(row: Int(toIndex), section: 1))
        self.tableView?.endUpdates()
    }
    
    func cancelWithError(_ error: Error) {
        NSLog("Something went wrong here")
    }
    
    
}
