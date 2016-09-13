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

    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var profilePicture: FBSDKProfilePictureView!
    
    @IBOutlet weak var lblLoginStatus: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var isLoggedIn = false
        
        if let user = FIRAuth.auth()?.currentUser {
            if !user.anonymous {
                isLoggedIn = true
                loadFBProfile(FBSDKAccessToken.currentAccessToken())
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
    
    private func loadFBProfile(token: FBSDKAccessToken) {
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            if let error = error {
                print("Sign in failed:", error.localizedDescription)
            }
            else {
                print("Sign in worked for", user?.displayName)
                let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: token.tokenString, version: nil, HTTPMethod: "GET")
                req.startWithCompletionHandler({ (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) in
                    if (error != nil) {
                        
                    }
                    else {
                        NSLog("\(result)")
                        self.toggleHiddenState(false)
                        self.profilePicture.profileID = result.valueForKey("id") as! String
                        self.lblUsername.text = result.valueForKey("name") as? String
                        self.lblEmail.text = result.valueForKey("email") as? String
                    }
                })
                self.completionHandler(user: user!)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let token = result.token{
            loadFBProfile(token)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        toggleHiddenState(true)
        try! FIRAuth.auth()!.signOut()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func toggleHiddenState(shouldHide: Bool) {
        self.lblUsername.hidden = shouldHide;
        self.lblEmail.hidden = shouldHide;
        self.profilePicture.hidden = shouldHide;
    }
    
    private var completionHandler:(user: FIRUser)->Void = {
        (user: FIRUser) -> Void in
    }
    
    func completeWithBlock(block : (user: FIRUser) -> Void) {
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
