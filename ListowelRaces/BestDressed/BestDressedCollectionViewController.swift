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

class BestDressedCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {
    fileprivate let reuseIdentifier = "PictureEntry"
    fileprivate let objectContext = ObjectContext()
    fileprivate let imagePicker = UIImagePickerController()
    var dataSource:FBCollectionViewDataSource<BestDressedEntry>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.dataSource = objectContext.getBestDressedLadies(reuseIdentifier, collectionView: self.collectionView)
        self.dataSource!.populateCellWithBlock { (cell: UICollectionViewCell, obj: NSObject, indexPath: IndexPath) -> Void in
            if let myCell = cell as? PicCollectionViewCell {
                let snap = obj as! BestDressedEntry
                NSLog("\(snap)")
                myCell.nameLabel.text = snap.name
                myCell.voteCount.text = snap.votes?.stringValue
                if let url = snap.url {
                    myCell.entryImage.sd_setImage(with: URL(string: url), completed: { (image, error, cachetype, url) in
                        if let imageVar = image,
                            let urlVar = url {
                            myCell.aspectRatio = imageVar.size.width / imageVar.size.height > 1.0 ? AspectRatio.landscape : AspectRatio.portrait
                            print("image \(urlVar) aspect ratio: \(myCell.aspectRatio!)")
                        }
                    })
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: 300, height: 300);
        let viewWidth = collectionView.bounds.width - 20;
        if let entry = self.dataSource?.array[indexPath.row],
            let imgWidth = entry.width as? NSNumber,
            let imgHeight = entry.height as? NSNumber{
            let viewHeight = CGFloat(imgHeight.doubleValue / imgWidth.doubleValue * Double(viewWidth));
            size = CGSize(width: viewWidth, height: viewHeight + 100);
        }
        switch UIDevice.current.orientation{
        case .portrait, .portraitUpsideDown:
            return size;
        case .landscapeLeft, .landscapeRight:
            return CGSize(width: viewWidth / 2, height: viewWidth / 2)
        default:
            return size;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
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
            if let object = self.dataSource?.array.refAtIndex(indexPath.row) {
                NSLog("\(object)")
                let votesRef = object.child("votes")
                
                votesRef.runTransactionBlock({
                    (currentData:MutableData!) in
                    var value = currentData.value as? Int
                    if (value == nil) {
                        value = 0
                    }
                    currentData.value = value! + 1
                    return TransactionResult.success(withValue: currentData)
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
