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
    fileprivate let reuseIdentifier = "raceInfoCell"
    let titleDateFormatter = DateFormatter()
    var dataSource:FBTableViewDataSource<Race>?
    
    @IBOutlet weak var datePicker: DIDatepicker!
    
    var initialDate:Date?
    
    func populateCellWithBlock(rawCell: UITableViewCell, obj: NSObject) -> Void {
        if let cell = rawCell as? RaceSummaryCellTableViewCell {
            let race = obj as! Race
            cell.race = race
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleDateFormatter.dateFormat = "EEE d"
        
        let firstDate = context.getFirstRaceDate()
        self.datePicker.fillDates(from: firstDate as Date!, numberOfDays: 9)
        self.datePicker.addTarget(self, action: #selector(FBRaceTableViewController.dateSelected), for: .valueChanged)
        
        
        // get a datasource contain the races for the day
        self.dataSource = context.findRacesFor(nil, nibNamed: "RaceSummaryCellTableViewCell", cellReuseIdentifier: "HorseSummaryCell", tableView: self.tableView)
        self.dataSource!.populateCell = self.populateCellWithBlock
        self.tableView.dataSource = self.dataSource
    }

    func dateSelected() {
        self.dataSource!.tableView = nil;
        self.title = titleDateFormatter.string(from: self.datePicker.selectedDate)
        self.dataSource = context.findRacesFor(self.datePicker.selectedDate, nibNamed: "RaceSummaryCellTableViewCell", cellReuseIdentifier: "HorseSummaryCell", tableView: self.tableView)
        self.dataSource!.populateCell = self.populateCellWithBlock
        self.tableView.dataSource = self.dataSource
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowRunner", sender: self)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using [segue destinationViewController].
        let detailScene = segue.destination as! PageRacesViewController
        
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
            detailScene.raceNumber = (indexPath as NSIndexPath).row
            detailScene.totalRaces = self.dataSource!.array!.count
            detailScene.dataSource = self.dataSource?.array
        }
    }
}
