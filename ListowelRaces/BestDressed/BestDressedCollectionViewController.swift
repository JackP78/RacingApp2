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
    fileprivate let reuseIdentifier = "PictureEntry"
    fileprivate let objectContext = ObjectContext()
    fileprivate let imagePicker = UIImagePickerController()
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
                    myCell.entryImage.sd_setImage(with: URL(string: url))
                }
                myCell.voteButton.addTarget(self, action: #selector(BestDressedCollectionViewController.votePressed(_:)), for: .touchUpInside)

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

    func votePressed(_ sender:UIButton)
    {
        NSLog("Vote pressed")
        let touchPoint = collectionView!.convert(CGPoint.zero, from: sender)
        if let indexPath = collectionView!.indexPathForItem(at: touchPoint) {
            if let object = self.dataSource?.array![(indexPath as NSIndexPath).row] {
                NSLog("\(object.ref)")
                let votesRef = object.ref.child("votes")
                
                votesRef.runTransactionBlock({
                    (currentData:FIRMutableData!) in
                    var value = currentData.value as? Int
                    if (value == nil) {
                        value = 0
                    }
                    currentData.value = value! + 1
                    return FIRTransactionResult.success(withValue: currentData)
                })
            }
        }
    }
    
    func initButtons() {
        imagePicker.delegate = self
        let tipButton = UIBarButtonItem.init(title: "Add Entry", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BestDressedCollectionViewController.chooseImage))
        self.navigationItem.rightBarButtonItem = tipButton;
    }
    
    func chooseImage() {
        objectContext.ensureLoggedInWithCompletion(self) { (user) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    // called when the image is picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String :
        Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            objectContext.enterBestDressed(self, image: pickedImage)
        }
        
    }

}
