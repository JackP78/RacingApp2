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
import FCAlertView
import Alamofire
import SwiftyJSON

class ObjectContext: NSObject {
    fileprivate var urlDateFormatter = DateFormatter()
    fileprivate var remoteConfig = RemoteConfig.remoteConfig()
    fileprivate let ladiesRef = Database.database().reference().child("photos")
    fileprivate let ladiesStorage = Storage.storage().reference().child("ladies")
    var localinfoRef = Database.database().reference().child("localinfo")
    
    override init() {
        urlDateFormatter.dateFormat = "yyyy-MM-dd"
        super.init()
        
        // load the config information
        let path = Bundle.main.path(forResource: "ListowelRaces", ofType: "plist")
        
        remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaults(fromPlist: "ListowelRaces")
        
        let expirationDuration = 43200
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if (status == RemoteConfigFetchStatus.success) {
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
                    if let friends = [FriendJSON].from(jsonArray: data["data"] as! [Gloss.JSON]) {
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
    
    func ensureLoggedInWithCompletion(_ parentView: UIViewController, completion : @escaping ((_ user: User) -> Void)) {
        if let token = FBSDKAccessToken.current(), let user = Auth.auth().currentUser
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
    
    
    fileprivate func doAddTip(_ runner: Runner, race: Race, tipsRef: DatabaseReference, user: User) {
        let currentRunnerRef = Database.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners").queryOrdered(byChild: "runnerId").queryEqual(toValue: runner.runnerId).observe(.childAdded, with: { snapshot in
            let numberTipsRef = snapshot.ref.child("numberTips")
            numberTipsRef.runTransactionBlock({
                (currentData:MutableData!) in
                var value = currentData.value as? Int
                if (value == nil) {
                    value = 0
                }
                currentData.value = value! + 1
                return TransactionResult.success(withValue: currentData)
            })
        })
        // add a tip entry
        let newTip = tipsRef
        let tip:[String:AnyObject] = [ // 2
            "name": user.displayName! as AnyObject,
            "userId": user.uid as AnyObject,
            "runnerId" : runner.runnerId as AnyObject,
            "horseName" : runner.name as AnyObject,
            "raceId" : race.raceId as AnyObject,
            "tipsterScore" : 10 as AnyObject,
            ]
        newTip.setValue(tip)
    }
    
    
    func addTip(_ runner: Runner, race: Race, parentView: UIViewController) {
        self.ensureLoggedInWithCompletion(parentView) { (user) in
            let key = "\(race.raceId)_\(user.uid)"
            let tipsRef = Database.database().reference().child("tips").child(key)
            tipsRef.observeSingleEvent(of: .value, with: { (snapShot: DataSnapshot) in
                if let horseName = snapShot.childSnapshot(forPath: "horseName").value as? String {
                    // we already have a tip for this race
                    NSLog("You already tipped \(horseName) in this race.  This tip for will replace that tip")
                    let alert = UIAlertController(title: "Replace Tip", message: "You already tipped \(horseName) in this race.  Are you sure you want to replace that tip with \(runner.name!)", preferredStyle: .alert)
                    
                    let confirmAction = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: { (action : UIAlertAction) in
                        self.doAddTip(runner, race: race, tipsRef: tipsRef, user: user)
                        alert.dismiss(animated: true, completion: nil)
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action : UIAlertAction) in
                        alert.dismiss(animated: true, completion: nil)
                    })
                    
                    alert.addAction(confirmAction)
                    alert.addAction(cancelAction)
                    
                    parentView.present(alert, animated: true, completion: nil)
                }
                else {
                    self.doAddTip(runner, race: race, tipsRef: tipsRef, user: user)
                }
            })
        }
    }
    
    func getRunnerDetails(_ runner: Runner, race: Race, delegate : FBDelegate) -> FBArray<Runner> {
        let currentRunnerRef = Database.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners").queryOrdered(byChild: "runnerId").queryEqual(toValue: runner.runnerId)
        return FBArray<Runner>(withQuery: currentRunnerRef, delegate : delegate)
    }
    
    
    func getFormFor(_ runner: Runner, delegate: FBDelegate) -> FBArray<Form> {
        let formRef = Database.database().reference().child("form").child((String(runner.runnerId)))
        return FBArray<Form>(withQuery: formRef, delegate : delegate)
    }
    
    func getTipsFor(_ runner: Runner, delegate: FBDelegate) -> FBArray<Tip> {
        let tipsRef = Database.database().reference().child("tips").queryOrdered(byChild: "runnerId").queryEqual(toValue: runner.runnerId)
        return FBArray<Tip>(withQuery: tipsRef, delegate : delegate)
    }
    
    
    func getRunnersForRace(_ race: Race, delegate : FBDelegate) -> FBArray<Runner> {
        let currentRaceRef = Database.database().reference().child("races").child(race.meetingDate).child(String(race.raceNumber)).child("runners")
        return FBArray<Runner>(withQuery: currentRaceRef, delegate : delegate)
    }
    
    func findRacesFor(_ date : Date?, nibNamed : String, cellReuseIdentifier : String, tableView : UITableView) -> FBTableViewDataSource<Race> {
        let baseRef = Database.database().reference().child("races")
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
        localinfoRef.observe(.childAdded, with: { (snapshot : DataSnapshot) in
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
    
    fileprivate func finishUpload(_ downloadURL: String, user: User, parentView: UIViewController, size: CGSize) {
        let itemRef = self.ladiesRef.childByAutoId() // 1
        let messageItem = [ // 2
            "name": user.displayName!,
            "userId": user.uid,
            "votes": 0
            ,"url": downloadURL
            ,"height": size.height
            ,"width": size.width
            ] as [String : Any]
        itemRef.setValue(messageItem) // 3
        NSLog("Finish upload \(itemRef)")
        MBProgressHUD.hide(for: parentView.view, animated: true)
    }
    
    fileprivate func invalidPhotoError(_ message: String, parentView: UIViewController) {
        let alert = UIAlertController(title: "Invalid Photo", message: message, preferredStyle: .alert)
        let sorryAction = UIAlertAction(title: "Sorry", style: UIAlertActionStyle.default, handler: { (action : UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(sorryAction)
        parentView.present(alert, animated: true, completion: nil)
    }
    
    func enterBestDressed(_ parentView: UIViewController, image : UIImage) {
        NSLog("Begin upload best dressed")
        self.ensureLoggedInWithCompletion(parentView) { (user) in
            if let imageData = UIImageJPEGRepresentation(image, 0.25) {
                let uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil))
                let riversRef = self.ladiesStorage.child("\(user.uid)-\(uuid!).jpg")
                NSLog("begin upload of \(riversRef)")
                let loadingNotification = MBProgressHUD.showAdded(to: parentView.view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.annularDeterminate
                loadingNotification.label.text = "Uploading"
                
                let uploadTask = riversRef.putData(imageData, metadata: nil) { metadata, error in
                    if (error != nil) {
                        NSLog("error occured")
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        let downloadURL = metadata!.downloadURL()!.absoluteString
                        loadingNotification.mode = MBProgressHUDMode.indeterminate
                        loadingNotification.label.text = "Validating"
                        
                        let alamoParameters: Parameters = [
                            "image": downloadURL
                        ]
                        let headers = [
                            "app_id": "625bfadb",
                            "app_key": "8fe27b1a44afa1ced2b25837fe468911"
                        ]
                        
                        Alamofire.request("http://api.kairos.com/detect",
                                          method: .post,
                                          parameters: alamoParameters,
                                          encoding: JSONEncoding.default,
                                          headers: headers
                            )
                            .responseJSON{ response in
                                guard response.result.isSuccess else {
                                    print("Error while fetching tags: \(response.result.error)")
                                    self.finishUpload(downloadURL, user: user, parentView: parentView, size: image.size)
                                    return;
                                }
                                let json = SwiftyJSON.JSON(response.result.value!)
                                print("reponse \(json)")
                                if json["Errors"][0].exists() {
                                    let error = json["Errors"][0]
                                    print("error \(error)")
                                    MBProgressHUD.hide(for: parentView.view, animated: true)
                                    riversRef.delete(completion: nil)
                                    self.invalidPhotoError("The photo does not contain any people in it at all", parentView: parentView)
                                    
                                }
                                else if json["images"][0]["faces"].exists() &&
                                   json["images"][0]["faces"].arrayValue.count > 1 {
                                    MBProgressHUD.hide(for: parentView.view, animated: true)
                                    riversRef.delete(completion: nil)
                                    self.invalidPhotoError("The photo has more than one person it it, the photo must contain only one person at a time", parentView: parentView)
                                }
                                else if let gender = json["images"][0]["faces"][0]["attributes"]["gender"]["type"].string,
                                    let femaleConfidence = json["images"][0]["faces"][0]["attributes"]["gender"]["femaleConfidence"].double,
                                    let maleConfidence = json["images"][0]["faces"][0]["attributes"]["gender"]["maleConfidence"].double,
                                    let age = json["images"][0]["faces"][0]["attributes"]["age"].number  {
                                    print ("got good photo M/F \(gender) female confidence \(femaleConfidence) male confidence \(maleConfidence) age\(age)")
                                    if (gender != "F") {
                                        MBProgressHUD.hide(for: parentView.view, animated: true)
                                        riversRef.delete(completion: nil)
                                        self.invalidPhotoError("The photo you uploaded is of a man, this is a best dressed lady competition", parentView: parentView)
                                    }
                                    else if (age.intValue < 18) {
                                        MBProgressHUD.hide(for: parentView.view, animated: true)
                                        riversRef.delete(completion: nil)
                                        self.invalidPhotoError("You are too young to enter the best dressed lady, must be 18", parentView: parentView)
                                    }
                                    else {
                                        MBProgressHUD.hide(for: parentView.view, animated: true)
                                        self.finishUpload(downloadURL, user: user, parentView: parentView, size: image.size)
                                    }
                                }
                        }
                    }
                }
                _ = uploadTask.observe(.progress) { snapshot in
                    loadingNotification.progressObject = snapshot.progress
                }
            }
        }
    }
}
