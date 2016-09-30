//
//  LocalInfoTableViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 31/01/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class LocalInfoTableViewController: UITableViewController, LocalInfoSelector, UISearchResultsUpdating, UISearchBarDelegate {

    var selectedInfo: LocalInfoEntry?
    var filterLocalInfos = [LocalInfoEntry]()
    var localinfos = [LocalInfoEntry]()
    var shouldShowFilteredResults: Bool = false
    let obj = ObjectContext()
    
    var searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.definesPresentationContext = false
        
        // Place the search bar view to the tableview headerview.
        self.tableView.tableHeaderView = searchController.searchBar
        
        obj.findLocalInfo("Listowel") { (current) in
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.localinfos.count, inSection: 0)], withRowAnimation: .Automatic)
            self.localinfos.append(current)
            self.tableView.endUpdates()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filterLocalInfos.count
        }
        return localinfos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("localInfoCell", forIndexPath: indexPath)
        let candy: LocalInfoEntry
        if searchController.active && searchController.searchBar.text != "" {
            candy = filterLocalInfos[indexPath.row]
        } else {
            candy = localinfos[indexPath.row]
        }
        cell.textLabel!.text = candy.name
        cell.detailTextLabel!.text = candy.type
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if searchController.active && searchController.searchBar.text != "" {
                selectedInfo = filterLocalInfos[indexPath.row]
            } else {
                selectedInfo = localinfos[indexPath.row]
            }
        }
        self.parentViewController?.performSegueWithIdentifier("showLocalDetail", sender: self)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filterLocalInfos = localinfos.filter { candy in
            return candy.name!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
