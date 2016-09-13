//
//  LRRunnerTableViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 15/08/2015.
//  Copyright (c) 2015 Jack McAuliffe. All rights reserved.
//

import UIKit


class LRRunnerTableViewController: UITableViewController {
    private let reuseIdentifier = "RunnerCell"
    private var dataSource: FBTableViewDataSource?
    private var objectContext = ObjectContext()
    var raceIndex: Int=0
    var currentRace: Race?
    
    override func viewDidLoad() {
        self.title = "Race"
        
        let predictorButton = UIBarButtonItem.init(title: "Predictor", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(LRRunnerTableViewController.launchPreditor(_:)))
        self.navigationItem.rightBarButtonItem = predictorButton;
        
        super.viewDidLoad()
        self.dataSource = objectContext.getRunnersForRace(self.currentRace!, nibNamed: "HorseSummaryCell", cellReuseIdentifier: "HorseSummaryCell", tableView: self.tableView)
        self.dataSource!.populateCellWithBlock { (rawCell: UITableViewCell, obj: NSObject) -> Void in
            if let cell = rawCell as? HorseSummaryCell {
                let runner = obj as! Runner
                cell.runner = runner
            }
        }
        self.tableView.dataSource = self.dataSource
    }
    
    func launchPreditor(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("predictor", sender: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Configure the PFQueryTableView
        self.title = "Race"
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90;
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellIdentifier = "RaceSectionHeader"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! LRSectionHeader
        if let race = self.currentRace {
            cell.raceName.text = race.raceTitle
            cell.raceNumber.text = "Race \(race.raceNumber)"
            cell.time.text = race.scheduledTime
            cell.prizeMoney.text = race.prizeMoney.moneyString()
            cell.distance.text = race.distanceYards.distanceString()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showForm", sender: self)
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using [segue destinationViewController].
        if let detailScene = segue.destinationViewController as? RunnerDetailTableViewController {
            // Pass the selected object to the destination view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow {
                detailScene.race = self.currentRace
                detailScene.runner = self.dataSource!.array!.modelClassAtIndex(indexPath.row) as? Runner
            }
        }

    }
    
    
}
