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
    var background:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        loadSceneNodes()
    	physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        self.runners = context.getRunnersForRace(self.currentRace!, delegate: self)
        setCameraConstraints()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        setCameraConstraints();
    }
    
    func loadSceneNodes() {
        guard let background = self.childNode(withName: "background") as? SKSpriteNode,
            let horse = self.childNode(withName: "horse") as? SKSpriteNode,
            let finishButton = self.camera?.childNode(withName: "finishButton") as? SKSpriteNode,
            let finishLine = self.childNode(withName: "finishLine") as? SKSpriteNode
            else
        {
            fatalError("Sprite Nodes not loaded")
        }
        self.horse = horse
        self.finishButton = finishButton
        self.finishLine = finishLine
        self.background = background
        if let horseName = horse.childNode(withName: "name") as? SKLabelNode {
            horseName.text = "Kauto Star"
        }
        let wait = SKAction.wait(forDuration: 3)
        let force = CGVector(dx: 20, dy: 0)
        let go = SKAction.applyForce(force, duration: 1)
        self.horse.run(SKAction.sequence([wait, go]))
        
    }
    
    private func setCameraConstraints() {
        // Don't try to set up camera constraints if we don't yet have a camera.
        guard let camera = camera else { return }
        
        let displayRect: CGRect = (self.scene!.view?.bounds)!
        let centerPoint = CGPoint(x: displayRect.midX, y: displayRect.midY)
        let sceneCenterPoint = self.view!.convert(centerPoint, to: self)
        let bgPoint = self.background.position;
        let backgroundContentRect = background.calculateAccumulatedFrame()
        let offset = sceneCenterPoint.x
        print("displayRect \(displayRect) centerPoint \(centerPoint) backgroundSize \(backgroundContentRect) sceneCenterPoint \(sceneCenterPoint) bgPoint\(bgPoint)")
        // 160 for portrait, 520 for landscape but I have no idea why 160 cause its half of 560
        /*if UIDevice.current.orientation.isLandscape {
            let offset = displayRect.maxX
        } else {
            let offset = displayRect.midX
        }*/
        let xRange = SKRange(lowerLimit: offset, upperLimit: backgroundContentRect.maxX - offset)
        let levelEdgeConstraint = SKConstraint.positionX(xRange)
        
        
        // Constrain the camera to stay a constant distance of 0 points from the player node.
        let zeroRange = SKRange(constantValue: 0.0)
        let horseConstraint = SKConstraint.distance(zeroRange, to: horse)
        camera.constraints = [horseConstraint, levelEdgeConstraint]
    }
    
    func setOrientation(landscape: Bool) {
        if (landscape) {
            print("landscape")
        }
        else {
            print ("portrait")
        }
        setCameraConstraints();
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let touchNode = atPoint(location)
        print("\(touchNode.name)")
        
        if touchNode.name == finishButton.name {
            gameOver(didWin: true);
        }
        else {
            self.isPaused = !self.isPaused;
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        targetLocation = touch.location(in: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
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
            secondBody.categoryBitMask == finishLine?.physicsBody?.categoryBitMask {
            self.isPaused = true
        }
    }
    
    private func gameOver(didWin: Bool) {
        print("- - - Game Ended - - - \(camera?.position)")
        self.scene!.view?.viewController()?.dismiss(animated: true, completion: nil)
    }
    
    // FB Delegate cells
    func childAdded(_ object: AnyObject, atIndex: Int) {
        if let runner = object as? Runner {
            NSLog("adding \(runner.name!)");
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
