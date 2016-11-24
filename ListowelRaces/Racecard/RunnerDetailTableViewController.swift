//
//  RunnerDetailTableViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 08/09/2015.
//  Copyright © 2015 Jack McAuliffe. All rights reserved.
//

import UIKit


class RunnerDetailTableViewController: UITableViewController {
    fileprivate let reuseIdentifier = "RunnerDetailCell"
    fileprivate var dataSource: UITableViewDataSource?
    fileprivate var runnerId: NSNumber?
    var runner: Runner?
    var race: Race?
    let objectContext = ObjectContext()
    
    override func loadView() {
        super.loadView()
        let tipButton = UIBarButtonItem.init(title: "Add Tip", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RunnerDetailTableViewController.addTip(_:)))
        self.navigationItem.rightBarButtonItem = tipButton;
        
        
        let runnerSectionDS = objectContext.getRunnerDetails(self.runner!, race: self.race!, tableView: self.tableView)
            
        //FBTableViewDataSource(query: runnerRef!.ref, modelClass: Runner.self, nibNamed: "HorseSummaryCell", cellReuseIdentifier: "HorseSummaryCell", view: self.tableView, section: 0)
        runnerSectionDS.populateCellWithBlock { (rawCell: UITableViewCell, obj: NSObject) -> Void in
            if let cell = rawCell as? HorseSummaryCell {
                let runner = obj as! Runner
                cell.runner = runner
            }
        }
        runnerSectionDS.section = 0
        
        let tipsSection = objectContext.getTipsFor(self.runner!, tableView: self.tableView)
        tipsSection.section = 1
        
        let formSection = objectContext.getFormFor(self.runner!, tableView: self.tableView, prototypeReuseIdentifier: "FormEntryCell")
        formSection.section = 2
        formSection.populateCellWithBlock { (rawCell: UITableViewCell, obj: NSObject) -> Void in
            let cell = rawCell as! RunnerFormCell
            let form = obj as! Form
            cell.raceDate.text = form.meetingdateString()
            cell.courseName.text = form.course!.substring(to: form.course!.characters.index(form.course!.startIndex, offsetBy: 3))
            cell.distance.text = form.distanceYards?.distanceString()
            cell.startingPrice.text = form.startingPrice!
            cell.positionLabel.text = form.finishpositionString()
            cell.comment.text = form.briefcommentString()
            // TODO put this back
            /*if(indexPath.row % 2 == 0) {
                cell.backgroundColor = UIColor.whiteColor()
            }
            else {
                cell.backgroundColor = UIColor.lightGrayColor()
            }*/
        }
        self.dataSource = CompositeTableViewDataSource(dataSources: [runnerSectionDS, tipsSection, formSection])
        self.tableView.dataSource = self.dataSource
    }
    
    func addTip(_ sender: UIBarButtonItem) {
        objectContext.addTip(self.runner!, race: self.race!, parentView: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Runner Detail"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 || self.dataSource?.tableView(self.tableView, numberOfRowsInSection: section) == 0) {
            return 0
        }
        else {
            return 70
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath as NSIndexPath).section == 0) {
            return 100
        }
        else {
            return 40
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch (section) {
        case 1 :
            let cellIdentifier = "TipsHeaderCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            return cell?.contentView
        case 2 :
            let cellIdentifier = "FormHeaderCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            return cell?.contentView
        default :
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FormEntryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! RunnerFormCell
        //if let form = object as? Form {
            cell.raceDate.text = "16 June"
            cell.courseName.text = "GAL"
            cell.distance.text = "3m"
            cell.startingPrice.text = "13/7"
            cell.positionLabel.text = "5/9"
            cell.comment.text = "Section header"
            if((indexPath as NSIndexPath).row % 2 == 0) {
                cell.backgroundColor = UIColor.white
            }
            else {
                cell.backgroundColor = UIColor.lightGray
            }
        //}
        return cell
    }

}
