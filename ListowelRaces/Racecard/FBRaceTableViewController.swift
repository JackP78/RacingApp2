//
//  FBRaceTableViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 27/02/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//
//  This is the first page that lists the races for a particular day

import UIKit



class FBRaceTableViewController: UITableViewController {
    let context = ObjectContext()
    private let reuseIdentifier = "raceInfoCell"
    let titleDateFormatter = NSDateFormatter()
    var dataSource:FBTableViewDataSource?
    
    @IBOutlet weak var datePicker: DIDatepicker!
    
    var initialDate:NSDate?
    
    var populateCellHandler: (cell: UITableViewCell, object: NSObject) -> Void = { (cell: UITableViewCell, object: NSObject) -> Void in
        if let snap = object as? Race {
            cell.textLabel?.text = snap.scheduledTime
            cell.detailTextLabel?.text = snap.raceTitle
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleDateFormatter.dateFormat = "EEE d"
        
        let firstDate = context.getFirstRaceDate()
        self.datePicker.fillDatesFromDate(firstDate, numberOfDays: 9)
        self.datePicker.addTarget(self, action: #selector(FBRaceTableViewController.dateSelected), forControlEvents: .ValueChanged)
        
        
        // get a datasource contain the races for the day
        self.dataSource = context.findRacesFor(nil, cellReuseIdentifier: reuseIdentifier, tableView: self.tableView)
        self.dataSource!.populateCell = populateCellHandler
        self.tableView.dataSource = self.dataSource
    }

    func dateSelected() {
        self.title = titleDateFormatter.stringFromDate(self.datePicker.selectedDate)
        self.dataSource = context.findRacesFor(self.datePicker.selectedDate, cellReuseIdentifier: reuseIdentifier, tableView: self.tableView)
        self.dataSource!.populateCell = populateCellHandler
        self.tableView.dataSource = self.dataSource
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowRunner", sender: self)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using [segue destinationViewController].
        let detailScene = segue.destinationViewController as! PageRacesViewController
        
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
            detailScene.raceNumber = indexPath.row
            detailScene.totalRaces = self.dataSource!.array!.count
            detailScene.dataSource = self.dataSource?.array
        }
    }
}
