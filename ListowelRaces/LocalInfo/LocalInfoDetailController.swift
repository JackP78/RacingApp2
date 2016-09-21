//
//  LocalInfoDetailController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 09/02/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class LocalInfoDetailController: UIViewController, LocalInfoSelector {

    var selectedInfo:LocalInfoEntry?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let info = selectedInfo {
            self.nameLabel.text = info.name
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
