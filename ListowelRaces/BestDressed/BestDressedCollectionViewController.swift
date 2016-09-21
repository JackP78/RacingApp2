//
//  BestDressedCollectionViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 23/02/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import SDWebImage

class BestDressedCollectionViewController: UICollectionViewController {
    private let reuseIdentifier = "PictureEntry"
    private let firebaseRef = FIRDatabase.database().reference().child("photos")
    var dataSource:FBCollectionViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.dataSource = FBCollectionViewDataSource(query: firebaseRef, cellReuseIdentifier: reuseIdentifier, view: self.collectionView!)
        self.dataSource!.populateCellWithBlock { (cell: UICollectionViewCell, obj: NSObject) -> Void in
            if let myCell = cell as? PicCollectionViewCell {
                let snap = obj as! FIRDataSnapshot
                NSLog("\(snap)")
                myCell.nameLabel.text = snap.value!.objectForKey("name") as? String
                myCell.voteCount.text = (snap.value!.objectForKey("votes") as? NSNumber)?.stringValue
                if let url = snap.value!.objectForKey("url") as? String {
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

}
