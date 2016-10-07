//
//  CompositeTableViewDataSource.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 03/03/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class CompositeTableViewDataSource: NSObject, UITableViewDataSource {
    
    fileprivate var sectionDataSources:[UITableViewDataSource]
    
    init(dataSources: [UITableViewDataSource]) {
        sectionDataSources = dataSources
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = sectionDataSources[(indexPath as NSIndexPath).section]
        let newIndex = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
        return dataSource.tableView(tableView, cellForRowAt: newIndex)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDataSources.count
    }
    
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        let rows = sectionDataSources[section].tableView(tableView, numberOfRowsInSection: 0)
        return rows
    }
}
