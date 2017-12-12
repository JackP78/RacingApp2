//
//  SegmentViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 26/01/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class SegmentViewController: UIViewController, SegmentDelegateSource {

    @IBOutlet weak var containerView: UIView!
    var viewControllers: [UIViewController?] = []
    weak var currentViewController: UIViewController?
    var delegate: SegmentDelegateSource?
    
    func getSegments() -> [(name: String, value: UIViewController)] {
        return [(name: "Map", value: self.storyboard!.instantiateViewController(withIdentifier: "localInfoMapView")),
        (name: "List", value: self.storyboard!.instantiateViewController(withIdentifier: "localInfoTableView"))]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        
        // add a button to nav bar to add new entry
        let tipButton = UIBarButtonItem.init(title: "Add New", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SegmentViewController.addNew(_:)))
        self.navigationItem.rightBarButtonItem = tipButton;

        if let vc = self.delegate?.getSegments() {
            var labels : [String] = []
            for tuple in vc {
                viewControllers.append(tuple.value)
                labels.append(tuple.name)
            }
            let segment: UISegmentedControl = UISegmentedControl(items: labels)
            segment.sizeToFit()
            segment.selectedSegmentIndex = 0;
            segment.addTarget(self, action: #selector(SegmentViewController.segmentChanged(_:)), for: .valueChanged)
            self.navigationItem.titleView = segment
            
            // add viewController so you can switch them later.
            if let vc = viewControllers[0] {
                currentViewController = vc;
                vc.view.frame = self.containerView.bounds
                self.addChildViewController(vc)
                self.containerView.addSubview(vc.view)
            }
        }
    }
    
    @objc func addNew(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "addNewLocalInfo", sender: self)
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if let vc = viewControllers[sender.selectedSegmentIndex] {
            vc.view.frame = self.containerView.bounds
            self.addChildViewController(vc)
            self.containerView.addSubview(vc.view)
            self.addChildViewController(vc)
            self.transition(from: currentViewController!, to: vc, duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                self.currentViewController!.view.removeFromSuperview()
                vc.view.frame = self.containerView.bounds
                self.containerView.addSubview(vc.view)
            }) { (success: Bool) -> Void in
                vc.didMove(toParentViewController: self)
                self.currentViewController?.removeFromParentViewController()
                self.currentViewController = vc
            }
            self.navigationItem.title = vc.title;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // Get the new view controller using [segue destinationViewController].
        if var destinationScene = segue.destination as? LocalInfoSelector {
            if let source = sender as? LocalInfoSelector {
                destinationScene.selectedInfo = source.selectedInfo
            }
        }
    }


}
