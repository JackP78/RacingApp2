//
//  HorseSprite.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 14/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import SpriteKit

func loadTextureAtlas(_ atlasName : String) -> [SKTexture] {
    var textureArea = [SKTexture]()
    let textureAtlas = SKTextureAtlas(named: atlasName)
    let numImages = textureAtlas.textureNames.count;
    for i in 1...numImages {
        textureArea.append(textureAtlas.textureNamed("Move\(i).png"))
    }
    return textureArea
}

private var brownTexture = loadTextureAtlas("Horse1")
private var lightBrownTexture = loadTextureAtlas("Horse2")
private var greyTexture = loadTextureAtlas("Horse3")
private var blackTexture = loadTextureAtlas("Horse4")

class HorseSprite: SKSpriteNode {
    static fileprivate var brownTexture = [SKTexture]()
    static fileprivate var lightBrownTexture = [SKTexture]()
    static fileprivate var greyTexture = [SKTexture]()
    static fileprivate var blackTexture = [SKTexture]()
    let horseCategory: UInt32 = 0x1 << 0
    let finishCategory: UInt32 = 0x1 << 1
    var myTexture : [SKTexture]
    fileprivate var myRunner : Runner
    
    func startRunning(_ screenWidth : CGFloat) {
        
        
        
        let animateAction = SKAction.animate(with: self.myTexture, timePerFrame: 0.05)
        let repeatAnimation = SKAction.repeatForever(animateAction)
        let timeToTravel : CGFloat = 2.5 + ((100.0 - CGFloat(myRunner.speed))/100.0 * 10.0)
        //NSLog("screenWidth is \(screenWidth) runner speed is \(myRunner.speed) time to travel is \(timeToTravel)")
        let moveAction = SKAction.moveBy(x: screenWidth, y: 0, duration: TimeInterval(timeToTravel))
        moveAction.timingMode = .easeInEaseOut
        let combinedAction = SKAction.group([repeatAnimation,moveAction])
        self.run(combinedAction)
    }
    
    func stopRunning() {
        self.removeAllActions()
        let nameLabel = SKLabelNode(fontNamed: "Arial")
        nameLabel.text = self.myRunner.name
        nameLabel.fontSize = 28
        nameLabel.horizontalAlignmentMode = .right;
        nameLabel.position = CGPoint(x: self.frame.minX, y: self.frame.midY);
        self.scene?.addChild(nameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
