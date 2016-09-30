//
//  MainViewController.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 30/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    var splashScreen : SplashView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Main View Loaded")
        // Do any additional setup after loading the view.
        splashScreen = SplashView(frame: self.view.frame)
        splashScreen?.backgroundColor  = UIColor.whiteColor()
        view.addSubview(splashScreen!)
    }
    
    override func viewDidAppear(animated: Bool) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.splashScreen?.animateLogoWithCompletion(2, onComplete: { 
                self.splashScreen?.removeFromSuperview()
            })
        }
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
