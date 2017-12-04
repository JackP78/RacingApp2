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
    var background:SKTileMapNode!
    
    override func didMove(to view: SKView) {
        loadSceneNodes()
    	physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        self.runners = context.getRunnersForRace(self.currentRace!, delegate: self)
        setCameraConstraints()
    }
    
    func loadSceneNodes() {
        guard let horse = childNode(withName: "horse") as? SKSpriteNode,
            let finishButton = self.camera?.childNode(withName: "finishButton") as? SKSpriteNode,
            let finishLine = self.childNode(withName: "finishLine") as? SKSpriteNode
            else
        {
            fatalError("Sprite Nodes not loaded")
        }
        guard let background = self.childNode(withName: "background") as? SKTileMapNode
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
        //horse.physicsBody!.velocity = CGVector(dx: 300, dy: 0)
        
    }
    
    private func setCameraConstraints() {
        // Don't try to set up camera constraints if we don't yet have a camera.
        guard let camera = camera else { return }
        
        // Constrain the camera to stay a constant distance of 0 points from the player node.
        let zeroRange = SKRange(constantValue: 0.0)
        let horseConstraint = SKConstraint.distance(zeroRange, to: horse)
        
        if UIDevice.current.orientation.isLandscape {
            /*
             Also constrain the camera to avoid it moving to the very edges of the scene.
             First, work out the scaled size of the scene. Its scaled height will always be
             the original height of the scene, but its scaled width will vary based on
             the window's current aspect ratio.
             */
            let scaledSize = CGSize(width: size.width * camera.xScale, height: size.height * camera.yScale)
            NSLog("scaled size \(scaledSize)")
            
            /*
             Calculate the accumulated frame of this node.
             The accumulated frame of a node is the outer bounds of all of the node's
             child nodes, i.e. the total size of the entire contents of the node.
             This gives us the bounding rectangle for the level's environment.
             */
            let backgroundContentRect = background.calculateAccumulatedFrame()
            NSLog("background rect \( backgroundContentRect)");
            
            /*
             Work out how far within this rectangle to constrain the camera.
             We want to stop the camera when we get within 100pts of the edge of the screen,
             unless the level is so small that this inset would be outside of the level.
             */
            let xInset = min((scaledSize.width / 2), backgroundContentRect.width / 2)
            let yInset = min((scaledSize.height / 2), backgroundContentRect.height / 2)
            
            // Use these insets to create a smaller inset rectangle within which the camera must stay.
            let insetContentRect = backgroundContentRect.insetBy(dx: xInset, dy: yInset)
            NSLog("inset rect \( insetContentRect)");
            
            // Define an `SKRange` for each of the x and y axes to stay within the inset rectangle.
            let xRange = SKRange(lowerLimit: insetContentRect.minX, upperLimit: insetContentRect.maxX)
            let yRange = SKRange(lowerLimit: insetContentRect.minY, upperLimit: insetContentRect.maxY)
            
            // Constrain the camera within the inset rectangle.
            let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
            levelEdgeConstraint.referenceNode = background
            
            /*
             Add both constraints to the camera. The scene edge constraint is added
             second, so that it takes precedence over following the `PlayerBot`.
             The result is that the camera will follow the player, unless this would mean
             moving too close to the edge of the level.
             */
            camera.constraints = [horseConstraint, levelEdgeConstraint]
        }
        else {
            camera.constraints = [horseConstraint]
        }
    }
    
    func updateCamera() {
        //camera.position = CGPoint(x: horse!.position.x, y: horse!.position.y)
        /*if (camera?.contains(finishLine))! {
            NSLog("position of camera \( camera?.calculateAccumulatedFrame())")
            NSLog("position of bk \( background?.calculateAccumulatedFrame())")
        }*/
    }
    
    func setOrientation(landscape: Bool) {
        if (landscape) {
            print("landscape")
        }
        else {
            print ("portrait")
            if let camera = camera {
                camera.position = CGPoint(x: horse!.position.x, y: horse!.position.y)
            }
        }
        setCameraConstraints()
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
            secondBody.categoryBitMask == finishLine?.physicsBody?.categoryBitMask {
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
