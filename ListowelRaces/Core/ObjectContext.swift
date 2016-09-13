//
//  ObjectContext.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 24/05/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseRemoteConfig

class ObjectContext: NSObject {
    private var urlDateFormatter = NSDateFormatter()
    private var remoteConfig = FIRRemoteConfig.remoteConfig()

    
    override init() {
        urlDateFormatter.dateFormat = "yyyy-MM-dd"
        super.init()
        
        // load the config information
        let path = NSBundle.mainBundle().pathForResource("ListowelRaces", ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path!) as? Dictionary<String, String> {
            let firstDate = dict["first_date"]
            NSLog("hi there \(firstDate)")
        }
        
        
        
        
        remoteConfig = FIRRemoteConfig.remoteConfig()
        let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaultsFromPlistFileName("ListowelRaces")
        
        let expirationDuration = 43200
        remoteConfig.fetchWithExpirationDuration(NSTimeInterval(expirationDuration)) { (status, error) -> Void in
            if (status == FIRRemoteConfigFetchStatus.Success) {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
            }
        }
        
    }
    
    private func persistTip(runner: Runner, race: Race, user: FIRUser) {
        let tipsRef = FIRDatabase.database().reference().child("tips").child(runner.runnerId!.stringValue)
        let currentRunnerRef = FIRDatabase.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners").queryOrderedByChild("runnerId").queryEqualToValue(runner.runnerId)
        
        let numberTipsRef = currentRunnerRef.ref.child("numberTips")
        numberTipsRef.runTransactionBlock({
            (currentData:FIRMutableData!) in
            var value = currentData.value as? Int
            if (value == nil) {
                value = 0
            }
            currentData.value = value! + 1
            return FIRTransactionResult.successWithValue(currentData)
        })
        
        // add a tip entry
        let newTip = tipsRef.childByAutoId()
        let tip:[String:AnyObject] = [ // 2
            "name": user.displayName!,
            "userId": user.uid,
            "tipsterScore" : 10,
        ]
        newTip.setValue(tip)
    }
    
    
    func addTip(runner: Runner, race: Race, parentView: UIViewController) {
        // make sure they are logged in
        do {
            if let user = FIRAuth.auth()?.currentUser {
                if user.anonymous {
                    throw LoginError.NotLoggedIn
                }
                else {
                    // already logged in so add the tip
                    persistTip(runner, race: race, user: user)
                }
            } else {
                throw LoginError.NotLoggedIn
            }
        }
        catch LoginError.NotLoggedIn {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Login", bundle:nil)
            let loginController = storyBoard.instantiateViewControllerWithIdentifier("LoginView") as! LoginViewController
            loginController.completeWithBlock({ (user) in
                self.persistTip(runner, race: race, user: user)
            })
            parentView.navigationController?.pushViewController(loginController, animated: true)
            //parentView.presentViewController(loginController, animated:true, completion:nil)
        }
        catch {
            NSLog("Big Problem here")
        }
        
    }
    
    func getRunnerDetails(runner: Runner, race: Race, tableView: UITableView) -> FBTableViewDataSource {
        let currentRunnerRef = FIRDatabase.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners").queryOrderedByChild("runnerId").queryEqualToValue(runner.runnerId)
        return FBTableViewDataSource(query: currentRunnerRef, modelClass: Runner.self, nibNamed: "HorseSummaryCell", cellReuseIdentifier: "HorseSummaryCell", view: tableView)
    }
    
    
    func getFormFor(forRunner: Runner, tableView: UITableView, prototypeReuseIdentifier: String) -> FBTableViewDataSource {
        let formRef = FIRDatabase.database().reference().child("form").child((forRunner.runnerId?.stringValue)!)
        return FBTableViewDataSource(query: formRef, modelClass: Form.self, cellReuseIdentifier: prototypeReuseIdentifier, view: tableView)
    }
    
    func getTipsFor(forRunner: Runner, tableView: UITableView) -> FBTableViewDataSource {
        let tipsRef = FIRDatabase.database().reference().child("tips").child((forRunner.runnerId?.stringValue)!)
        return FBTableViewDataSource(query: tipsRef, modelClass: Tip.self, nibNamed: "TipCell", cellReuseIdentifier: "TipCell", view: tableView, section: 1)
    }
    
    
    func getRunnersForRace(race: Race, nibNamed : String, cellReuseIdentifier : String, tableView : UITableView) -> FBTableViewDataSource {
        let currentRaceRef = FIRDatabase.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners")
        return FBTableViewDataSource(query: currentRaceRef, modelClass: Runner.self, nibNamed: "HorseSummaryCell", cellReuseIdentifier: "HorseSummaryCell", view: tableView)
    }
    
    func findRacesFor(date : NSDate?, cellReuseIdentifier : String, tableView : UITableView) -> FBTableViewDataSource {
        let baseRef = FIRDatabase.database().reference().child("races")
        let firstDateStr = remoteConfig["first_date"].stringValue!
        let url = (date != nil) ? urlDateFormatter.stringFromDate(date!) : firstDateStr
        let currentRaceRef = baseRef.child(url)
        return FBTableViewDataSource(query: currentRaceRef, modelClass: Race.self, cellReuseIdentifier: cellReuseIdentifier, view: tableView)
    }
    
    func getFirstRaceDate() -> NSDate? {
        let firstDateStr = remoteConfig["first_date"].stringValue
        return urlDateFormatter.dateFromString(firstDateStr!)
    }
}
