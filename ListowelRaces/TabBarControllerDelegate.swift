//
//  TabBarControllerDelegate.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 29/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class TabBarControllerDelegate: NSObject, UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController)->Bool {
        NSLog("Selected a new tab \(viewController.title)")
        return true;
    }
}
