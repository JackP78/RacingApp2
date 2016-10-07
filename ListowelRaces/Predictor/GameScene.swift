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
    
    override func didMove(to view: SKView) {
        // setup the physics engine
        // 1 Create a physics body that borders the screen
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        // 2 Set physicsBody of scene to borderBody
        self.physicsBody = borderBody;
        // 3 Set the friction of that physicsBody to 0
        self.physicsBody!.friction = 0.0
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0);
        self.physicsWorld.contactDelegate = self;
        
        createGround()
        
        
        let finishNode = SKShapeNode(rectOf: CGSize(width: 100, height: self.frame.height - 20))
        finishNode.position = CGPoint(x:self.frame.maxX - 50, y:self.frame.midY)
        finishNode.physicsBody = SKPhysicsBody(rectangleOf: finishNode.frame.size)
        finishNode.physicsBody!.categoryBitMask = finishCategory;
        self.addChild(finishNode)
        
    }
    
    func finishedAnimation() -> (Void) {
        // add a finish button
        let startGameBtn = SKLabelNode(fontNamed: "Copperplate-Light")
        startGameBtn.text = "Touch To Finish"
        startGameBtn.color = SKColor.white
        startGameBtn.fontColor = SKColor.black
        startGameBtn.fontSize = 42
        startGameBtn.position = CGPoint(x: frame.size.width/2, y: frame.size.height * 0.8)
        addChild(startGameBtn)
        finished = true
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        if (finished) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "quitPredictor"), object: nil)
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
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
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        endBackgroundScroll()
        self.enumerateChildNodes(withName: "horse") { (node: SKNode, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
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
            bg.anchorPoint = CGPoint.zero
            bg.name = "background"
            self.addChild(bg)
            
            let moveBgLeft = SKAction.moveBy(x: -bg.frame.width, y: 0, duration: 2)
            let moveBgReset = SKAction.moveBy(x: bg.frame.width, y: 0, duration: 0)
            let moveBgLoop = SKAction.sequence([moveBgLeft, moveBgReset])
            let moveBgForever = SKAction.repeatForever(moveBgLoop)
            
            bg.run(moveBgForever)
            bg.isPaused = true
        }
    }
    
    func beginBackgroundScroll() {
        self.enumerateChildNodes(withName: "background") { (node: SKNode, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.isPaused = false
        }
    }
    
    func endBackgroundScroll() {
        self.enumerateChildNodes(withName: "background") { (node: SKNode, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.isPaused = true
        }
    }
}
