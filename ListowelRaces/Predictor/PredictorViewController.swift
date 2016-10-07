//
//  PredictorViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 05/02/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import SpriteKit

class PredictorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            //set up notification so scene can get back to this view controller
            NotificationCenter.default.addObserver(self, selector: #selector(PredictorViewController.quitPredictor(_:)), name: NSNotification.Name(rawValue: "quitPredictor"), object: nil)
            
            skView.presentScene(scene)
        }
    }
    
    // Function to pop this view controller and go back to my Levels screen
    func quitPredictor(_ notification: Notification) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscape;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
