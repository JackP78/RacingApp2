//
//  HorseSprite.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 14/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import SpriteKit

func loadTextureAtlas(atlasName : String) -> [SKTexture] {
    var textureArea = [SKTexture]()
    let textureAtlas = SKTextureAtlas(named: atlasName)
    let numImages = textureAtlas.textureNames.count;
    for i in 1...numImages {
        textureArea.append(textureAtlas.textureNamed("Move\(i).png"))
    }
    return textureArea
}

class HorseSprite: SKSpriteNode {
    static private var brownTexture = [SKTexture]()
    static private var lightBrownTexture = [SKTexture]()
    static private var greyTexture = [SKTexture]()
    static private var blackTexture = [SKTexture]()
    let horseCategory: UInt32 = 0x1 << 0
    let finishCategory: UInt32 = 0x1 << 1
    var myTexture : [SKTexture]
    private var myRunner : Runner
    
    init(runner: Runner) {
        myRunner = runner
        if (HorseSprite.brownTexture.count == 0) {
            HorseSprite.brownTexture = loadTextureAtlas("Horse1")
        }
        
        if (HorseSprite.lightBrownTexture.count == 0) {
            HorseSprite.lightBrownTexture = loadTextureAtlas("Horse2")
        }
        
        if (HorseSprite.greyTexture.count == 0) {
            HorseSprite.greyTexture = loadTextureAtlas("Horse3")
        }
        
        if (HorseSprite.blackTexture.count == 0) {
            HorseSprite.blackTexture = loadTextureAtlas("Horse4")
        }
        
        let dice1 = arc4random_uniform(4) + 1;
        switch (dice1) {
        case 1 :
            myTexture = HorseSprite.blackTexture
            break
        case 2:
            myTexture = HorseSprite.greyTexture
            break
        case 3:
            myTexture = HorseSprite.lightBrownTexture
            break
        default:
            myTexture = HorseSprite.brownTexture
            break
        }
        
        let color = UIColor()
        let size = myTexture[0].size()
        super.init(texture: myTexture[0], color: color, size: size)
        
        self.xScale = 0.5
        self.yScale = 0.5
        self.xScale = abs(self.xScale) * -1
        self.physicsBody = SKPhysicsBody(circleOfRadius: 2)
        self.physicsBody!.categoryBitMask = horseCategory
        self.physicsBody!.contactTestBitMask = finishCategory;
        self.name = "horse";
        
        
    }
    
    func startRunning(screenWidth : CGFloat) {
        let animateAction = SKAction.animateWithTextures(self.myTexture, timePerFrame: 0.05)
        let repeatAnimation = SKAction.repeatActionForever(animateAction)
        let timeToTravel : CGFloat = 2.5 + ((100.0 - CGFloat(myRunner.speed))/100.0 * 10.0)
        NSLog("screenWidth is \(screenWidth) runner speed is \(myRunner.speed) time to travel is \(timeToTravel)")
        let moveAction = SKAction.moveByX(screenWidth, y: 0, duration: NSTimeInterval(timeToTravel))
        moveAction.timingMode = .EaseInEaseOut
        let combinedAction = SKAction.group([repeatAnimation,moveAction])
        self.runAction(combinedAction)
    }
    
    func stopRunning() {
        self.removeAllActions()
        let nameLabel = SKLabelNode(fontNamed: "Arial")
        nameLabel.text = self.myRunner.name
        nameLabel.fontSize = 28
        nameLabel.horizontalAlignmentMode = .Right;
        nameLabel.position = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMidY(self.frame));
        self.scene?.addChild(nameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
