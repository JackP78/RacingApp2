//
//  SegmentViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 26/01/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class SegmentViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    weak var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // add a button to nav bar to add new entry
        let tipButton = UIBarButtonItem.init(title: "Add New", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SegmentViewController.addNew(_:)))
        self.navigationItem.rightBarButtonItem = tipButton;

        // add viewController so you can switch them later.
        let vc = viewControllerForSegmentIndex(self.segmentControl.selectedSegmentIndex)
        vc.view.frame = self.containerView.bounds
        self.addChildViewController(vc)
        self.containerView.addSubview(vc.view)
        self.currentViewController = vc;
    }
    
    func addNew(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("addNewLocalInfo", sender: self)
    }

    @IBAction func segmentChanged(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex;
        let vc = viewControllerForSegmentIndex(index)
        self.addChildViewController(vc)
        self.transitionFromViewController(currentViewController!, toViewController: vc, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { () -> Void in
            self.currentViewController!.view.removeFromSuperview()
            vc.view.frame = self.containerView.bounds
            self.containerView.addSubview(vc.view)
            }) { (success: Bool) -> Void in
                vc.didMoveToParentViewController(self)
                self.currentViewController?.removeFromParentViewController()
                self.currentViewController = vc
        }
        
        self.navigationItem.title = vc.title;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerForSegmentIndex(index: Int) -> (UIViewController) {
        var vc: UIViewController
        switch (index) {
        case 1:
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("localInfoTableView")
            break;
        default:
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("localInfoMapView")
            break
            
        }
        return vc;
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // Get the new view controller using [segue destinationViewController].
        if var destinationScene = segue.destinationViewController as? LocalInfoSelector {
            if let source = sender as? LocalInfoSelector {
                destinationScene.selectedInfo = source.selectedInfo
            }
        }
    }


}
