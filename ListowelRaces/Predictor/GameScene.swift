//
//  GameScene.swift
//  HorseSwift
//
//  Created by Jack McAuliffe on 04/02/2016.
//  Copyright (c) 2016 Jack McAuliffe. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let horseCategory: UInt32 = 0x1 << 0
    let finishCategory: UInt32 = 0x1 << 1
    var finished:Bool = false
    
    override func didMoveToView(view: SKView) {
        // setup the physics engine
        // 1 Create a physics body that borders the screen
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        // 2 Set physicsBody of scene to borderBody
        self.physicsBody = borderBody;
        // 3 Set the friction of that physicsBody to 0
        self.physicsBody!.friction = 0.0
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.physicsWorld.contactDelegate = self;
        
        createGround()
        
        
        let finishNode = SKShapeNode(rectOfSize: CGSize(width: 100, height: self.frame.height - 20))
        finishNode.position = CGPoint(x:CGRectGetMaxX(self.frame) - 50, y:CGRectGetMidY(self.frame))
        finishNode.physicsBody = SKPhysicsBody(rectangleOfSize: finishNode.frame.size)
        finishNode.physicsBody!.categoryBitMask = finishCategory;
        self.addChild(finishNode)
        
    }
    
    func finishedAnimation() -> (Void) {
        // add a finish button
        let startGameBtn = SKLabelNode(fontNamed: "Copperplate-Light")
        startGameBtn.text = "Touch To Finish"
        startGameBtn.color = SKColor.whiteColor()
        startGameBtn.fontColor = SKColor.blackColor()
        startGameBtn.fontSize = 42
        startGameBtn.position = CGPointMake(frame.size.width/2, frame.size.height * 0.8)
        addChild(startGameBtn)
        finished = true
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if (finished) {
            NSNotificationCenter.defaultCenter().postNotificationName("quitPredictor", object: nil)
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let runner = Runner()
            runner.name = "KateO"
            let speed = Int(arc4random_uniform(100)) + 1;
            runner.speed = speed
            let sprite = HorseSprite(runner: runner)
            sprite.position = location
            self.addChild(sprite)
            sprite.startRunning(self.frame.size.width)
            
            beginBackgroundScroll()
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        endBackgroundScroll()
        self.enumerateChildNodesWithName("horse") { (node: SKNode, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
            if let horse = node as? HorseSprite {
                horse.stopRunning()
            }
        }
        finishedAnimation()
    }
    
    func createGround() {
        for i in 0 ... 1 {
            let bg = SKSpriteNode(imageNamed: "ListowelBackground")
            bg.size.height = self.size.height
            bg.size.width = self.size.width
            bg.zPosition = -10
            bg.position = CGPoint(x: i * Int(bg.size.width), y: 0)
            bg.anchorPoint = CGPointZero
            bg.name = "background"
            self.addChild(bg)
            
            let moveBgLeft = SKAction.moveByX(-bg.frame.width, y: 0, duration: 2)
            let moveBgReset = SKAction.moveByX(bg.frame.width, y: 0, duration: 0)
            let moveBgLoop = SKAction.sequence([moveBgLeft, moveBgReset])
            let moveBgForever = SKAction.repeatActionForever(moveBgLoop)
            
            bg.runAction(moveBgForever)
            bg.paused = true
        }
    }
    
    func beginBackgroundScroll() {
        self.enumerateChildNodesWithName("background") { (node: SKNode, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.paused = false
        }
    }
    
    func endBackgroundScroll() {
        self.enumerateChildNodesWithName("background") { (node: SKNode, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.paused = true
        }
    }
}
