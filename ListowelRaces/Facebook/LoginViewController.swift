//
//  LoginViewController.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 13/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var objectContext = ObjectContext()
    /*!
     @abstract Sent to the delegate when the button was used to login.
     @param loginButton the sender
     @param result The results of the login
     @param error The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if(error == nil)
        {
            NSLog("login complete")
            if let token = FBSDKAccessToken.current() {
                loadFBProfile(token);
                objectContext.getFriendList()
            }
            else if result.isCancelled {
                NSLog("user cancelled the login")
                self.navigationController?.popViewController(animated: true)
            }
        }
        else{
            NSLog(error.localizedDescription)
        }
        
        
    }


    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var profilePicture: FBSDKProfilePictureView!
    
    @IBOutlet weak var lblLoginStatus: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var isLoggedIn = false
        
        if let token = FBSDKAccessToken.current(), let user = Auth.auth().currentUser
        {
            if !user.isAnonymous {
                isLoggedIn = true
                loadFBProfile(token)
            }
        }
        toggleHiddenState(!isLoggedIn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loginButton.readPermissions = ["user_about_me", "public_profile","email", "user_friends"]
        self.loginButton.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadFBProfile(_ token: FBSDKAccessToken) {
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Sign in failed:", error.localizedDescription)
            }
            else {
                print("Sign in worked for", user?.displayName)
                let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name,picture"], tokenString: token.tokenString, version: nil, httpMethod: "GET")
                req?.start(completionHandler: { (connection: FBSDKGraphRequestConnection?, response: Any?, error: Error?) in
                    if (error != nil) {
                        
                    }
                    else {
                        if let result = response as AnyObject? {
                            NSLog("\(result)")
                            self.toggleHiddenState(false)
                            let facebookID = result.value(forKey: "id") as! String
                            let displayName = result.value(forKey: "name") as? String
                            let email = result.value(forKey: "email") as? String
                            
                            
                            self.profilePicture.profileID = facebookID
                            self.lblUsername.text = displayName
                            self.lblEmail.text = email
                            
                            if let user = user {
                                let changeRequest = user.createProfileChangeRequest()
                                
                                changeRequest.displayName = displayName
                                if let pictureUrl = result.value(forKey: "picture") as? String {
                                    changeRequest.photoURL = URL(string: pictureUrl)
                                }
                                changeRequest.commitChanges { error in
                                    if let error = error {
                                        NSLog("\(error)")
                                    } else {
                                        NSLog("profile updated")
                                    }
                                }
                                user.updateEmail(to: email!) { (error) in
                                    if let error = error {
                                        NSLog("\(error)")
                                    } else {
                                        NSLog("email updated")
                                    }
                                }
                            }
                        }
                    }
                })
                self.completionHandler(user!)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        toggleHiddenState(true)
        try! Auth.auth().signOut()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func toggleHiddenState(_ shouldHide: Bool) {
        self.lblUsername.isHidden = shouldHide;
        self.lblEmail.isHidden = shouldHide;
        self.profilePicture.isHidden = shouldHide;
    }
    
    fileprivate var completionHandler:(_ user: User)->Void = {
        (user: User) -> Void in
    }
    
    func completeWithBlock(_ block : @escaping (_ user: User) -> Void) {
        self.completionHandler = block
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
