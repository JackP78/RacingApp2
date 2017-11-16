//
//  GameScene.swift
//  HorseSwift
//
//  Created by Jack McAuliffe on 04/02/2016.
//  Copyright (c) 2016 Jack McAuliffe. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate, FBDelegate {
    
    
    var currentRace: Race?
    var runners: FBArray<Runner>?
    let context = ObjectContext()
    
    // Scene Nodes
    var horse:SKSpriteNode!
    var finishButton:SKSpriteNode!
    var finishLine:SKSpriteNode!
    var targetLocation: CGPoint = .zero
    
    override func didMove(to view: SKView) {
        loadSceneNodes()
    	physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.runners = context.getRunnersForRace(self.currentRace!, delegate: self)
        updateCamera()
    }
    
    func loadSceneNodes() {
        guard let horse = childNode(withName: "horse") as? SKSpriteNode else {
            fatalError("Sprite Nodes not loaded")
        }
        self.horse = horse
        if let horseName = horse.childNode(withName: "name") as? SKLabelNode {
            horseName.text = "Kauto Star"
        }
        horse.physicsBody!.velocity = CGVector(dx: 200, dy: 0)
        
        guard let finishButton = childNode(withName: "finishbutton") as? SKSpriteNode  else {
            fatalError("Sprite Nodes not loaded")
        }
        self.finishButton = finishButton
    }
    
    func updateCamera() {
        if let camera = camera {
            camera.position = CGPoint(x: horse!.position.x, y: horse!.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let touchNode = atPoint(location)
        print("\(touchNode.name)")
        
        if touchNode.name == finishButton.name {
            gameOver(didWin: true);
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        targetLocation = touch.location(in: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        updateCamera()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // 1. Create local variables for two physics bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2. Assign the two physics bodies so that the one with the lower category is always stored in firstBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 3. react to the contact between the two nodes
        if firstBody.categoryBitMask == horse?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == 3 {
            self.isPaused = true
        }
    }
    
    private func gameOver(didWin: Bool) {
        print("- - - Game Ended - - -")
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "quitPredictor"), object: nil)
        self.scene!.view?.viewController()?.dismiss(animated: true, completion: nil)
        /*let menuScene = MenuScene(size: self.size)
        menuScene.soundToPlay = didWin ? "fear_win.mp3" : "fear_lose.mp3"
        let transition = SKTransition.flipVerticalWithDuration(1.0)
        menuScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(menuScene, transition: transition)*/
    }
    
    // FB Delegate cells
    func childAdded(_ object: AnyObject, atIndex: Int) {
        if let runner = object as? Runner {
            NSLog("adding \(runner.name!)");
            /*let speed = Int(arc4random_uniform(100)) + 1;
            runner.speed = speed
            let spacing = Int(self.frame.height) / currentRace!.runners.count;
            NSLog("height \(self.frame.height) runners \(currentRace!.runners.count) space \(spacing)")
            let sprite = HorseSprite(runner: runner)
            let location = CGPoint(x: self.frame.minX + 50, y: self.frame.minY + CGFloat(atIndex * spacing))
            sprite.position = location
            self.addChild(sprite)*/
            //sprite.startRunning(self.frame.size.width)*/
        }
        else {
            NSLog("Not a runner \(object)")
        }
    }
    
    func childChanged(_ object: AnyObject, atIndex: Int) {
    }
    
    func childRemoved(_ object: AnyObject, atIndex: Int) {
    }
    
    func childMoved(_ object: AnyObject, fromIndex: Int, toIndex: Int) {
    }
    
    func cancelWithError(_ error: Error) {
        NSLog("user cancelled");
    }
    
}
