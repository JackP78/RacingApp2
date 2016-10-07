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
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = false
        
        // Place the search bar view to the tableview headerview.
        self.tableView.tableHeaderView = searchController.searchBar
        
        obj.findLocalInfo("Listowel") { (current) in
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: self.localinfos.count, section: 0)], with: .automatic)
            self.localinfos.append(current)
            self.tableView.endUpdates()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterLocalInfos.count
        }
        return localinfos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localInfoCell", for: indexPath)
        let candy: LocalInfoEntry
        if searchController.isActive && searchController.searchBar.text != "" {
            candy = filterLocalInfos[(indexPath as NSIndexPath).row]
        } else {
            candy = localinfos[(indexPath as NSIndexPath).row]
        }
        cell.textLabel!.text = candy.name
        cell.detailTextLabel!.text = candy.type
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if searchController.isActive && searchController.searchBar.text != "" {
                selectedInfo = filterLocalInfos[(indexPath as NSIndexPath).row]
            } else {
                selectedInfo = localinfos[(indexPath as NSIndexPath).row]
            }
        }
        self.parent?.performSegue(withIdentifier: "showLocalDetail", sender: self)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filterLocalInfos = localinfos.filter { candy in
            return candy.name!.lowercased().contains(searchText.lowercased())
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
