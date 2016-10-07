//
//  ImageUpload.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 23/05/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import MBProgressHUD

class ImageUpload: NSObject {
    
    func uploaderProgress(_ bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int, context: AnyObject!) {
    }
    
    func uploaderSuccess(_ result: [AnyHashable: Any]!, context: AnyObject!) {
    }
    
    func uploadImage (_ image: UIImage, parentView: UIView, completion : (_ url: String?) -> Void) {
        let hud = MBProgressHUD.showAdded(to: parentView, animated: true)
        
        let imageData = UIImageJPEGRepresentation(image, 0.05)
        
        // save it to cloudinary
        /*let cloudinary = CLCloudinary(url: "cloudinary://275766598556953:IPDyfPYSrVxTMcZt18CsJavXPP8@listowelraces");
        let uploader = CLUploader(cloudinary, delegate: self)
        //let response = uploader.upload(imageData, options: nil)
        
        uploader.upload(imageData, options: nil, withCompletion: { (successResult: [NSObject : AnyObject]!, errorResult: String!, code: Int, context: AnyObject!) -> Void in
            if let url = successResult["url"] as? String {
                completion(url: url)
            }
            else {
                completion(url: nil)
            }
            hud.hide(true)
            }, andProgress: nil)*/
        NSLog("Upload to Firebase instead")
    }
}
