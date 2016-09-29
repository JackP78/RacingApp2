//
//  LocalInfoFormViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 28/01/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import Eureka
import MapKit
import MBProgressHUD

class LocalInfoFormViewController: FormViewController {
    var typeSection: SelectableSection<ListCheckRow<String>, String>?
    
    @IBAction func submitClicked(sender: UIButton) {
        let info = LocalInfoEntry()
        let values = self.form.values()
        let localinfoRef = FIRDatabase.database().reference().child("localinfo")
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
        
        
        /*NSLog("\(values)")
        if let name = values["name"] as? String {
            info.name = name
        }
        if let email = values["email"] as? String {
            info.email = email
        }
        if let phone = values["phone"] as? String {
            info.phone = phone
        }
        if let url = values["url"] as? String {
            info.url = url
        }
        if let location = values["location"] as? CLLocation {
            info.location = location
        }
        if let description = values["description"] as? String {
            info.excerptDescription = description
        }
        if let row = typeSection?.selectedRow() {
            info.type = row.value
            NSLog("\(row.value)")
        }
        if let image = values["image"] as? UIImage {
            let imageUploader = ImageUpload()
            imageUploader.uploadImage(image, parentView: self.view, completion: { (url) in
                info.imageUrl = url
                
            })
        }*/
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        info.saveInBackgroundWithBlock { (result) in
            self.navigationController?.popViewControllerAnimated(true)
        }

    }
    
    override func viewDidLoad() {
        NSLog("loading form")
        super.viewDidLoad()
        form  +++
            
            Section("General Info")
            
            <<< TextRow("name"){
                $0.title = "Name"
                $0.value = "Ocean Bar & Hostel"
            }
            <<< EmailRow("email") {
                $0.title = "Email"
                $0.value = "ocean@hostel.com"
            }
            <<< PhoneRow("phone") {
                $0.title = "Phone"
                $0.value = "0879049899"
            }
            <<< URLRow("url") {
                $0.title = "URL"
                $0.value = NSURL(string: "http://www.google.ie")
            }
            <<< ImageRow("image"){
                $0.title = "ImageRow"
            }
            <<< LocationRow(){
                $0.title = "LocationRow"
                $0.value = CLLocation(latitude: 52.4460488, longitude: -9.4853655)
            }
        
            +++ Section("Description")
            
                <<< TextAreaRow("description") { $0.placeholder = "Descriptino" }
        
        let continents = ["Music", "Accomodation", "Food", "Taxi", "Betting", "Bar"]
        
        typeSection = SelectableSection<ListCheckRow<String>, String>() { section in
            section.header = HeaderFooterView(title: "Type of Business")
            section.tag = "type"
        }
        
        form +++ typeSection!
        
        for option in continents {
            form.last! <<< ListCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.value = nil
            }
        }

    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
