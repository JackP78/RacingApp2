//
//  BestDressedCollectionViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 23/02/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

class BestDressedCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    private let reuseIdentifier = "PictureEntry"
    private let objectContext = ObjectContext()
    private let imagePicker = UIImagePickerController()
    var dataSource:FBCollectionViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.dataSource = objectContext.getBestDressedLadies(reuseIdentifier, collectionView: self.collectionView)
        self.dataSource!.populateCellWithBlock { (cell: UICollectionViewCell, obj: NSObject) -> Void in
            if let myCell = cell as? PicCollectionViewCell {
                let snap = obj as! BestDressedEntry
                NSLog("\(snap)")
                myCell.nameLabel.text = snap.name
                myCell.voteCount.text = snap.votes?.stringValue
                if let url = snap.url {
                    myCell.entryImage.sd_setImageWithURL(NSURL(string: url))
                }
                myCell.voteButton.addTarget(self, action: #selector(BestDressedCollectionViewController.votePressed(_:)), forControlEvents: .TouchUpInside)

            }
            else {
                NSLog("could not cast cell but got \(obj)")
            }
        }
        
        self.collectionView!.dataSource = self.dataSource
        self.initButtons()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func votePressed(sender:UIButton)
    {
        NSLog("Vote pressed")
        let touchPoint = collectionView!.convertPoint(CGPoint.zero, fromView: sender)
        if let indexPath = collectionView!.indexPathForItemAtPoint(touchPoint) {
            if let object = self.dataSource?.array![indexPath.row] {
                NSLog("\(object.ref)")
                let votesRef = object.ref.child("votes")
                
                votesRef.runTransactionBlock({
                    (currentData:FIRMutableData!) in
                    var value = currentData.value as? Int
                    if (value == nil) {
                        value = 0
                    }
                    currentData.value = value! + 1
                    return FIRTransactionResult.successWithValue(currentData)
                })
            }
        }
    }
    
    func initButtons() {
        imagePicker.delegate = self
        let tipButton = UIBarButtonItem.init(title: "Add Entry", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BestDressedCollectionViewController.chooseImage))
        self.navigationItem.rightBarButtonItem = tipButton;
    }
    
    func chooseImage() {
        objectContext.ensureLoggedInWithCompletion(self) { (user) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    // called when the image is picked
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String :
        AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismissViewControllerAnimated(true, completion: nil)
            objectContext.enterBestDressed(self, image: pickedImage)
        }
        
    }

}
