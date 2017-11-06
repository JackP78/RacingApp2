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
    var typeSection: SelectableSection<ListCheckRow<String>>?
    var objContext = ObjectContext()
    
    @IBAction func submitClicked(_ sender: UIButton) {
        objContext.saveLocalInfo(self, values: self.form.values())
        self.navigationController?.popViewController(animated: true)

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
                $0.value = URL(string: "http://www.google.ie")
            }
            <<< LocationRow("location"){
                $0.title = "LocationRow"
                $0.value = CLLocation(latitude: 52.4460488, longitude: -9.4853655)
            }
        
            +++ Section("Description")
            
                <<< TextAreaRow("description") { $0.placeholder = "Descriptino" }
        
        let continents = ["Music", "Accomodation", "Food", "Taxi", "Betting", "Bar"]
        
        typeSection = SelectableSection<ListCheckRow<String>>() { section in
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
