//
//  ImageUploader.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 23/02/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FirebaseAuth
import MBProgressHUD

let uploadRef = FIRDatabase.database().reference().child("photos")
    //Firebase(url: "https://listowelraces.firebaseio.com/photos")
let imagePicker = UIImagePickerController()

extension BestDressedCollectionViewController: UIImagePickerControllerDelegate
,UINavigationControllerDelegate {
    
    func initButtons() {
        imagePicker.delegate = self
        let tipButton = UIBarButtonItem.init(title: "Add Entry", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BestDressedCollectionViewController.chooseImage))
        self.navigationItem.rightBarButtonItem = tipButton;
    }
    
    func chooseImage() {
        // make sure they are logged in first
        if let user = FIRAuth.auth()?.currentUser {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .PhotoLibrary
            presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            self.performSegueWithIdentifier("showLogin", sender: self)
        }
    }
    
    func uploaderProgress(bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int, context: AnyObject!) {
    }
    
    func uploaderSuccess(result: [NSObject : AnyObject]!, context: AnyObject!) {
    }
    
    // called when the image is picked
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String :
        AnyObject]) {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                if let myUser = FIRAuth.auth()?.currentUser {
                    let name:String = myUser.displayName!
                    let email:String = myUser.email!
                    
                    let imageUploader = ImageUpload()
                    imageUploader.uploadImage(pickedImage, parentView: self.view, completion: { (url) in
                        if let myUrl = url {
                            let itemRef = uploadRef.childByAutoId() // 1
                            let messageItem = [ // 2
                                "name": name,
                                "email": email,
                                "votes": 0,
                                "url": myUrl
                            ]
                            itemRef.setValue(messageItem) // 3
                        }
                        
                    })

                }
                picker.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
}
