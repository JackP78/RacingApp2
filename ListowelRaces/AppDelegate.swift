//
//  AppDelegate.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 13/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import AWSCore
import AWSCognito
import Firebase
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init() {
        super.init()
        FIRApp.configure()
        // not really needed unless you really need it FIRDatabase.database().persistenceEnabled = true
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Initialize the Amazon Cognito credentials provider
        /*let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUWest1,
            identityPoolId:"eu-west-1:3f02f2a6-5376-46b0-8edd-64503ed4adaf")*/
        
        //let configuration = AWSServiceConfiguration(region:.EUWest1, credentialsProvider:credentialsProvider)
        
        //AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

        // Initialize the Cognito Sync client
        //let syncClient = AWSCognito.defaultCognito()
        
        // Create a record in a dataset and synchronize with the server
        /*let dataset = syncClient.openOrCreateDataset("myDataset")
        dataset.setString("myValue", forKey:"myKey")
        dataset.synchronize().continueWithBlock {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
        }*/
        
        
        // Override point for customization after application launch.
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }


}

