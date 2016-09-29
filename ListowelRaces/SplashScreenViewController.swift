//
//  SplashScreenViewController.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 27/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        let circleView = SplashView(frame: CGRectMake(0, 0, view.frame.size.width - 10, view.frame.size.height - 200))
        circleView.center = CGPointMake(view.frame.size.width  / 2,
                                        view.frame.size.height / 2);
        view.addSubview(circleView)
        circleView.animateLogoWithCompletion(2.0) {
            self.performSegueWithIdentifier("showMain", sender: self)
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
