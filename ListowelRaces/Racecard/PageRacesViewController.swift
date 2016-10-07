//
//  PageRacesViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 29/08/2015.
//  Copyright (c) 2015 Jack McAuliffe. All rights reserved.
//

import UIKit

class PageRacesViewController: UIViewController, UIPageViewControllerDataSource {
    var pageController: UIPageViewController
    var raceNumber: Int=0
    var totalRaces: Int=0
    var dataSource: FBArray?
    
    override func loadView() {
        super.loadView()
        /*let tipButton = UIBarButtonItem.init(title: "Sort", style: UIBarButtonItemStyle.Plain, target: self, action: "changeSort:")
        self.navigationItem.rightBarButtonItem = tipButton;*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        super.init(coder: aDecoder)
        
        let pageControl:UIPageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.backgroundColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Race \(raceNumber + 1)"
        self.pageController.dataSource = self
        self.pageController.view.frame = self.view.bounds
        let viewControllerObject = self.viewControllerAtIndex(raceNumber)!
        
        
        
        let viewControllers = [viewControllerObject];
        
        self.pageController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        self.addChildViewController(self.pageController)
        self.view.addSubview(self.pageController.view)
        self.pageController.didMove(toParentViewController: self)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! LRRunnerTableViewController).raceIndex;
        if (index == 0) {
            return nil;
        }
        index -= 1;
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! LRRunnerTableViewController).raceIndex;
        if (index == totalRaces - 1) {
            return nil;
        }
        index += 1;
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return totalRaces;
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return raceNumber
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerAtIndex(_ index: Int) -> LRRunnerTableViewController? {
        // Get the new view controller using [segue destinationViewController].
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "raceInfoView") as? LRRunnerTableViewController {
            // Pass the selected object to the destination view controller.
            vc.raceIndex = index
            let race = dataSource!.modelClassAtIndex(index) as! Race
            vc.currentRace = race
            return vc;
        }
        else {
            return nil;
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "changeSort" {
            let destination = segue.destinationViewController as! PickerViewController
            destination.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            destination.view.frame = self.view.frame.insetBy(dx: 20, dy: 20)
            destination.providesPresentationContextTransitionStyle = true
            destination.definesPresentationContext = true
            destination.view.backgroundColor = UIColor.clearColor()
        }
    }*/

}
