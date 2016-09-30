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
import FirebaseStorage
import MBProgressHUD
import MapKit

class ObjectContext: NSObject {
    private var urlDateFormatter = NSDateFormatter()
    private var remoteConfig = FIRRemoteConfig.remoteConfig()
    private let ladiesRef = FIRDatabase.database().reference().child("photos")
    private let ladiesStorage = FIRStorage.storage().reference().child("ladies")
    var localinfoRef = FIRDatabase.database().reference().child("localinfo")
    
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
    
    func ensureLoggedInWithCompletion(parentView: UIViewController, completion : ((user: FIRUser) -> Void)) {
        // make sure they are logged in
        do {
            if let user = FIRAuth.auth()?.currentUser {
                if user.anonymous {
                    throw LoginError.NotLoggedIn
                }
                else {
                    // already logged in so add the tip
                    completion(user: user)
                }
            } else {
                throw LoginError.NotLoggedIn
            }
        }
        catch LoginError.NotLoggedIn {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Login", bundle:nil)
            let loginController = storyBoard.instantiateViewControllerWithIdentifier("LoginView") as! LoginViewController
            loginController.completeWithBlock({ (user) in
                completion(user: user)
            })
            parentView.navigationController?.pushViewController(loginController, animated: true)
            //parentView.presentViewController(loginController, animated:true, completion:nil)
        }
        catch {
            NSLog("Big Problem here")
        }
    }
    
    
    func addTip(runner: Runner, race: Race, parentView: UIViewController) {
        self.ensureLoggedInWithCompletion(parentView) { (user) in
            let tipsRef = FIRDatabase.database().reference().child("tips").child(String(runner.runnerId))
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
                "runnerId" : runner.runnerId,
                "raceId" : race.raceId,
                "tipsterScore" : 10,
                ]
            newTip.setValue(tip)
        }
    }
    
    func getRunnerDetails(runner: Runner, race: Race, tableView: UITableView) -> FBTableViewDataSource {
        let currentRunnerRef = FIRDatabase.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners").queryOrderedByChild("runnerId").queryEqualToValue(runner.runnerId)
        return FBTableViewDataSource(query: currentRunnerRef, modelClass: Runner.self, nibNamed: "HorseSummaryCell", cellReuseIdentifier: "HorseSummaryCell", view: tableView)
    }
    
    
    func getFormFor(runner: Runner, tableView: UITableView, prototypeReuseIdentifier: String) -> FBTableViewDataSource {
        let formRef = FIRDatabase.database().reference().child("form").child((String(runner.runnerId)))
        return FBTableViewDataSource(query: formRef, modelClass: Form.self, cellReuseIdentifier: prototypeReuseIdentifier, view: tableView)
    }
    
    func getTipsFor(runner: Runner, tableView: UITableView) -> FBTableViewDataSource {
        let tipsRef = FIRDatabase.database().reference().child("tips").child((String(runner.runnerId)))
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
    
    func getBestDressedLadies(reuseIdentifier : String, collectionView : UICollectionView?) -> FBCollectionViewDataSource {
        return FBCollectionViewDataSource(query: ladiesRef, modelClass: BestDressedEntry.self, cellReuseIdentifier: reuseIdentifier, view: collectionView)
    }
    
    
    func saveLocalInfo(parentView: UIViewController, values : [String: Any?]) {
        let newLocalInfo = localinfoRef.childByAutoId()
        var result = [String: AnyObject]()
        NSLog("\(values)")
        for (key, value) in values {
            if let url = value as? NSURL {
                result[key] = url.absoluteString
            }
            else if let loc = value as? CLLocation {
                result["latitude"] = Double((loc.coordinate.latitude))
                result["longitude"] = Double((loc.coordinate.longitude))
            }
            else if let loc = value as? UIImage {
                // eat image for now
            }
            else if let v = value as? AnyObject {
                result[key] = v
            }
        }
        NSLog("\(result)")
        newLocalInfo.setValue(result)
    }
    
    
    func findLocalInfo(near: String, forEach: (current: LocalInfoEntry) -> Void) {
        // Attach an asynchronous callback to read the data at our posts reference
        localinfoRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            // populate the local info an send it back to the closure
            let model = LocalInfoEntry()
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                model.setValuesForKeysWithDictionary(postDict)
                model.location = CLLocation(latitude: model.latitude, longitude: model.longitude)
            }
            forEach(current: model)
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func enterBestDressed(parentView: UIViewController, image : UIImage) {
        NSLog("Begin upload best dressed")
        self.ensureLoggedInWithCompletion(parentView) { (user) in
            if let imageData = UIImageJPEGRepresentation(image, 0.25) {
                let uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil))
                let riversRef = self.ladiesStorage.child("\(user.uid)-\(uuid).jpg")
                NSLog("begin upload of \(riversRef)")
                let loadingNotification = MBProgressHUD.showHUDAddedTo(parentView.view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.AnnularDeterminate
                loadingNotification.labelText = "Uploading"
                
                let uploadTask = riversRef.putData(imageData, metadata: nil) { metadata, error in
                    if (error != nil) {
                        NSLog("error occured")
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let downloadURL = metadata!.downloadURL()!.absoluteString
                        let itemRef = self.ladiesRef.childByAutoId() // 1
                        let messageItem = [ // 2
                            "name": user.displayName!,
                            "userId": user.uid,
                            "votes": 0
                            ,"url": downloadURL
                        ]
                        itemRef.setValue(messageItem) // 3
                        NSLog("Finish upload \(itemRef)")
                        MBProgressHUD.hideAllHUDsForView(parentView.view, animated: true)
                    }
                }
                let observer = uploadTask.observeStatus(.Progress) { snapshot in
                    loadingNotification.progressObject = snapshot.progress
                }
            }
        }
    }
}
