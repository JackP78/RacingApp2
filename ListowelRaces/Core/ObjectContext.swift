//
//  ObjectContext.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 24/05/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseDatabase
import FirebaseRemoteConfig
import FirebaseStorage
import MBProgressHUD
import MapKit
import Gloss
import RealmSwift

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
        
        remoteConfig = FIRRemoteConfig.remoteConfig()
        let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaultsFromPlistFileName("ListowelRaces")
        
        let expirationDuration = 43200
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if (status == FIRRemoteConfigFetchStatus.success) {
                self.remoteConfig.activateFetched()
            } else {
                print("Error \(status) \(error?.localizedDescription)")
            }
        }
        
    }
    
    func getFriendList() {
        if((FBSDKAccessToken.current()) != nil) {
            // TODO chane this to friends only not taggable friends
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/taggable_friends", parameters: ["fields": "id,name,picture"])
            graphRequest.start(completionHandler: { (connection, result, error) in
                if (error == nil){
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    print(result!)
                    if let friends = [FriendJSON].from(jsonArray: data["data"] as! [JSON]) {
                        print ("iterate over \(friends.count) json friends")
                        let realm = try! Realm()
                        for friend in friends {
                            let friendObj = FriendEntity(friend: friend)
                            try! realm.write {
                                realm.add(friendObj)
                            }
                        }
                        let friendEnts = realm.objects(FriendEntity.self) // retrieves all Dogs from the default 
                        print ("retrieved \(friendEnts.count) realm friends")
                        for friendEnt in friendEnts {
                            print ("name: \(friendEnt.name)")
                            print ("fbId: \(friendEnt.fbId)")
                            print ("url: \(friendEnt.pictureUrl)")
                        }
                    }
                    else {
                        print("error glossing him")
                    }
                }
                else {
                    print ("error occurred: \(error)")
                }
            })
        }
    }
    
    func ensureLoggedInWithCompletion(_ parentView: UIViewController, completion : @escaping ((_ user: FIRUser) -> Void)) {
        if let token = FBSDKAccessToken.current(), let user = FIRAuth.auth()?.currentUser
        {
            if !user.isAnonymous {
                completion(user)
            }
        }
        else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Login", bundle:nil)
            let loginController = storyBoard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
            loginController.completeWithBlock({ (user) in
                completion(user)
            })
            parentView.navigationController?.pushViewController(loginController, animated: true)
        }
    }
    
    
    func addTip(_ runner: Runner, race: Race, parentView: UIViewController) {
        self.ensureLoggedInWithCompletion(parentView) { (user) in
            let tipsRef = FIRDatabase.database().reference().child("tips").child(String(runner.runnerId))
            let currentRunnerRef = FIRDatabase.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners").queryOrdered(byChild: "runnerId").queryEqual(toValue: runner.runnerId).observe(.childAdded, with: { snapshot in
            	let numberTipsRef = snapshot.ref.child("numberTips")
            	numberTipsRef.runTransactionBlock({
                    (currentData:FIRMutableData!) in
                    var value = currentData.value as? Int
                    if (value == nil) {
                        value = 0
                    }
                    currentData.value = value! + 1
                    return FIRTransactionResult.success(withValue: currentData)
                })
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
    
    func getRunnerDetails(_ runner: Runner, race: Race, delegate : FBDelegate) -> FBArray<Runner> {
        let currentRunnerRef = FIRDatabase.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners").queryOrdered(byChild: "runnerId").queryEqual(toValue: runner.runnerId)
        return FBArray<Runner>(withQuery: currentRunnerRef, delegate : delegate)
    }
    
    
    func getFormFor(_ runner: Runner, delegate: FBDelegate) -> FBArray<Form> {
        let formRef = FIRDatabase.database().reference().child("form").child((String(runner.runnerId)))
        return FBArray<Form>(withQuery: formRef, delegate : delegate)
    }
    
    func getTipsFor(_ runner: Runner, delegate: FBDelegate) -> FBArray<Tip> {
        let tipsRef = FIRDatabase.database().reference().child("tips").child((String(runner.runnerId)))
        return FBArray<Tip>(withQuery: tipsRef, delegate : delegate)
    }
    
    
    func getRunnersForRace(_ race: Race, delegate : FBDelegate) -> FBArray<Runner> {
        let currentRaceRef = FIRDatabase.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners")
        return FBArray<Runner>(withQuery: currentRaceRef, delegate : delegate)
    }
    
    func findRacesFor(_ date : Date?, nibNamed : String, cellReuseIdentifier : String, tableView : UITableView) -> FBTableViewDataSource<Race> {
        let baseRef = FIRDatabase.database().reference().child("races")
        let firstDateStr = remoteConfig["first_date"].stringValue!
        let url = (date != nil) ? urlDateFormatter.string(from: date!) : firstDateStr
        let currentRaceRef = baseRef.child(url)
        return FBTableViewDataSource<Race>(query: currentRaceRef, nibNamed: nibNamed, cellReuseIdentifier: cellReuseIdentifier, view: tableView)
    }
    
    func getFirstRaceDate() -> Date? {
        let firstDateStr = remoteConfig["first_date"].stringValue
        return urlDateFormatter.date(from: firstDateStr!)
    }
    
    func getBestDressedLadies(_ reuseIdentifier : String, collectionView : UICollectionView?) -> FBCollectionViewDataSource<BestDressedEntry> {
        return FBCollectionViewDataSource<BestDressedEntry>(query: ladiesRef, nibNamed: nil, cellReuseIdentifier: reuseIdentifier, view: collectionView, section: 0)
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
            else if let string = value as AnyObject? {
                result[key] = string
            }
            else {
                NSLog("Cannot set \(key) with \(value)")
            }
        }
        NSLog("To be saved \(result)")
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
            forEach(model)
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
                loadingNotification.label.text = "Uploading"
                
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
                        MBProgressHUD.hide(for: parentView.view, animated: true)
                    }
                }
                _ = uploadTask.observe(.progress) { snapshot in
                    loadingNotification.progressObject = snapshot.progress
                }
            }
        }
    }
}
