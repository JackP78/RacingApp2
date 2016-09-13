//
//  CompositeTableViewDataSource.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 03/03/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class CompositeTableViewDataSource: NSObject, UITableViewDataSource {
    
    private var sectionDataSources:[UITableViewDataSource]
    
    init(dataSources: [UITableViewDataSource]) {
        sectionDataSources = dataSources
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        NSLog("get cell for row \(indexPath.row) in section \(indexPath.section)")
        let dataSource = sectionDataSources[indexPath.section]
        let newIndex = NSIndexPath(forRow: indexPath.row, inSection: 0)
        NSLog("translated to row \(newIndex.row) in section \(newIndex.section)")
        return dataSource.tableView(tableView, cellForRowAtIndexPath: newIndex)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        NSLog("there are \(sectionDataSources.count) sections")
        return sectionDataSources.count
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        let rows = sectionDataSources[section].tableView(tableView, numberOfRowsInSection: 0)
        NSLog("there are \(rows) in section \(section)")
        return rows
    }
}
