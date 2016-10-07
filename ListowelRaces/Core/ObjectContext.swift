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
    fileprivate var urlDateFormatter = DateFormatter()
    fileprivate var remoteConfig = FIRRemoteConfig.remoteConfig()
    fileprivate let ladiesRef = FIRDatabase.database().reference().child("photos")
    fileprivate let ladiesStorage = FIRStorage.storage().reference().child("ladies")
    var localinfoRef = FIRDatabase.database().reference().child("localinfo")
    
    override init() {
        urlDateFormatter.dateFormat = "yyyy-MM-dd"
        super.init()
        
        // load the config information
        let path = Bundle.main.path(forResource: "ListowelRaces", ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path!) as? Dictionary<String, String> {
            let firstDate = dict["first_date"]
            NSLog("hi there \(firstDate)")
        }
        
        
        
        
        remoteConfig = FIRRemoteConfig.remoteConfig()
        let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaultsFromPlistFileName("ListowelRaces")
        
        let expirationDuration = 43200
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if (status == FIRRemoteConfigFetchStatus.success) {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
            }
        }
        
    }
    
    func ensureLoggedInWithCompletion(_ parentView: UIViewController, completion : @escaping ((_ user: FIRUser) -> Void)) {
        // make sure they are logged in
        do {
            if let user = FIRAuth.auth()?.currentUser {
                if user.isAnonymous {
                    throw LoginError.notLoggedIn
                }
                else {
                    // already logged in so add the tip
                    completion(user)
                }
            } else {
                throw LoginError.notLoggedIn
            }
        }
        catch LoginError.notLoggedIn {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Login", bundle:nil)
            let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
            loginController.completeWithBlock({ (user) in
                completion(user)
            })
            parentView.navigationController?.pushViewController(loginController, animated: true)
            //parentView.presentViewController(loginController, animated:true, completion:nil)
        }
        catch {
            NSLog("Big Problem here")
        }
    }
    
    
    func addTip(_ runner: Runner, race: Race, parentView: UIViewController) {
        self.ensureLoggedInWithCompletion(parentView) { (user) in
            let tipsRef = FIRDatabase.database().reference().child("tips").child(String(runner.runnerId))
            let currentRunnerRef = FIRDatabase.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners").queryOrdered(byChild: "runnerId").queryEqual(toValue: runner.runnerId)
            
            let numberTipsRef = currentRunnerRef.ref.child("numberTips")
            numberTipsRef.runTransactionBlock({
                (currentData:FIRMutableData!) in
                var value = currentData.value as? Int
                if (value == nil) {
                    value = 0
                }
                currentData.value = value! + 1
                return FIRTransactionResult.success(withValue: currentData)
            })
            
            // add a tip entry
            let newTip = tipsRef.childByAutoId()
            let tip:[String:AnyObject] = [ // 2
                "name": user.displayName! as AnyObject,
                "userId": user.uid as AnyObject,
                "runnerId" : runner.runnerId as AnyObject,
                "raceId" : race.raceId as AnyObject,
                "tipsterScore" : 10 as AnyObject,
                ]
            newTip.setValue(tip)
        }
    }
    
    func getRunnerDetails(_ runner: Runner, race: Race, tableView: UITableView) -> FBTableViewDataSource {
        let currentRunnerRef = FIRDatabase.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners").queryOrdered(byChild: "runnerId").queryEqual(toValue: runner.runnerId)
        return FBTableViewDataSource(query: currentRunnerRef, modelClass: Runner.self, nibNamed: "HorseSummaryCell", cellReuseIdentifier: "HorseSummaryCell", view: tableView)
    }
    
    
    func getFormFor(_ runner: Runner, tableView: UITableView, prototypeReuseIdentifier: String) -> FBTableViewDataSource {
        let formRef = FIRDatabase.database().reference().child("form").child((String(runner.runnerId)))
        return FBTableViewDataSource(query: formRef, modelClass: Form.self, cellReuseIdentifier: prototypeReuseIdentifier, view: tableView)
    }
    
    func getTipsFor(_ runner: Runner, tableView: UITableView) -> FBTableViewDataSource {
        let tipsRef = FIRDatabase.database().reference().child("tips").child((String(runner.runnerId)))
        return FBTableViewDataSource(query: tipsRef, modelClass: Tip.self, nibNamed: "TipCell", cellReuseIdentifier: "TipCell", view: tableView, section: 1)
    }
    
    
    func getRunnersForRace(_ race: Race, nibNamed : String, cellReuseIdentifier : String, tableView : UITableView) -> FBTableViewDataSource {
        let currentRaceRef = FIRDatabase.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners")
        return FBTableViewDataSource(query: currentRaceRef, modelClass: Runner.self, nibNamed: "HorseSummaryCell", cellReuseIdentifier: "HorseSummaryCell", view: tableView)
    }
    
    func findRacesFor(_ date : Date?, cellReuseIdentifier : String, tableView : UITableView) -> FBTableViewDataSource {
        let baseRef = FIRDatabase.database().reference().child("races")
        let firstDateStr = remoteConfig["first_date"].stringValue!
        let url = (date != nil) ? urlDateFormatter.string(from: date!) : firstDateStr
        let currentRaceRef = baseRef.child(url)
        return FBTableViewDataSource(query: currentRaceRef, modelClass: Race.self, cellReuseIdentifier: cellReuseIdentifier, view: tableView)
    }
    
    func getFirstRaceDate() -> Date? {
        let firstDateStr = remoteConfig["first_date"].stringValue
        return urlDateFormatter.date(from: firstDateStr!)
    }
    
    func getBestDressedLadies(_ reuseIdentifier : String, collectionView : UICollectionView?) -> FBCollectionViewDataSource {
        return FBCollectionViewDataSource(query: ladiesRef, modelClass: BestDressedEntry.self, cellReuseIdentifier: reuseIdentifier, view: collectionView)
    }
    
    
    func saveLocalInfo(_ parentView: UIViewController, values : [String: Any?]) {
        let newLocalInfo = localinfoRef.childByAutoId()
        var result = [String: AnyObject]()
        NSLog("\(values)")
        for (key, value) in values {
            if let url = value as? URL {
                result[key] = url.absoluteString as AnyObject?
            }
            else if let loc = value as? CLLocation {
                result["latitude"] = Double((loc.coordinate.latitude)) as AnyObject?
                result["longitude"] = Double((loc.coordinate.longitude)) as AnyObject?
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
    
    
    func findLocalInfo(_ near: String, forEach: @escaping (_ current: LocalInfoEntry) -> Void) {
        // Attach an asynchronous callback to read the data at our posts reference
        localinfoRef.observe(.childAdded, with: { (snapshot : FIRDataSnapshot) in
            let model = LocalInfoEntry()
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                model.setValuesForKeys(postDict)
                model.location = CLLocation(latitude: model.latitude, longitude: model.longitude)
            }
        }) { (error : Error) in
            print(error.localizedDescription)
        }
    }
    
    func enterBestDressed(_ parentView: UIViewController, image : UIImage) {
        NSLog("Begin upload best dressed")
        self.ensureLoggedInWithCompletion(parentView) { (user) in
            if let imageData = UIImageJPEGRepresentation(image, 0.25) {
                let uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil))
                let riversRef = self.ladiesStorage.child("\(user.uid)-\(uuid).jpg")
                NSLog("begin upload of \(riversRef)")
                let loadingNotification = MBProgressHUD.showAdded(to: parentView.view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.annularDeterminate
                loadingNotification.labelText = "Uploading"
                
                let uploadTask = riversRef.put(imageData, metadata: nil) { metadata, error in
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
                        ] as [String : Any]
                        itemRef.setValue(messageItem) // 3
                        NSLog("Finish upload \(itemRef)")
                        MBProgressHUD.hideAllHUDs(for: parentView.view, animated: true)
                    }
                }
                let observer = uploadTask.observe(.progress) { snapshot in
                    loadingNotification.progressObject = snapshot.progress
                }
            }
        }
    }
}
