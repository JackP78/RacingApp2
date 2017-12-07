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
    
    var currentRace: Race?
    var scene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            if let scene =  GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                scene.currentRace = currentRace;
                self.scene = scene;
                view.presentScene(self.scene)
            }
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        scene?.viewWillTransition(to: size);
    }
    
    // Function to pop this view controller and go back to my Levels screen
    func quitPredictor(_ notification: Notification) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    /*override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }*/
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
