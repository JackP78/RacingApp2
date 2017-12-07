//
//  GameScene.swift
//  HorseSwift
//
//  Created by Jack McAuliffe on 04/02/2016.
//  Copyright (c) 2016 Jack McAuliffe. All rights reserved.
//

import SpriteKit

func loadTextureAtlas(_ atlasName : String) -> [SKTexture] {
    var textureArea = [SKTexture]()
    let textureAtlas = SKTextureAtlas(named: atlasName)
    let numImages = textureAtlas.textureNames.count;
    for i in 1...numImages {
        textureArea.append(textureAtlas.textureNamed(String(format: "\(atlasName)%02d.png", i)))
    }
    return textureArea
}

private var brownTexture = loadTextureAtlas("BrownHorse")
private var tanTexture = loadTextureAtlas("TanHorse")
private var greyTexture = loadTextureAtlas("GreyHorse")
private var blackTexture = loadTextureAtlas("BlackHorse")

class GameScene: SKScene, SKPhysicsContactDelegate, FBDelegate {
    var currentRace: Race?
    var runners: FBArray<Runner>?
    let context = ObjectContext()
    
    // horse nodes
    var topHorse: SKSpriteNode!
    var bottomHorse: SKSpriteNode!
    var horses: [SKSpriteNode] = []
    var numRunners: Int = 0
    var fieldWidth: CGFloat = 0
    var horseMask: UInt32 = 0x1 << 0
    
    var finishButton:SKSpriteNode!
    var finishLine:SKSpriteNode!
    var targetLocation: CGPoint = .zero
    var background:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        loadSceneNodes()
    	physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        self.numRunners = (currentRace?.runners.count)!
        print("number of runners \(self.numRunners)")
        self.runners = context.getRunnersForRace(self.currentRace!, delegate: self)
        setCameraConstraints(viewSize: (self.scene!.view?.bounds.size)!)
    }
    
    //Returns a CGRect that has the dimensions and position for any device with respect to any specified scene. This will result in a boundary that can be utilised for positioning nodes on a scene so that they are always visible
    func getVisibleScreen( sceneBounds: CGRect, viewBounds: CGSize) -> CGRect {
        var sceneHeight = sceneBounds.height
        var sceneWidth = sceneBounds.width
        let viewHeight = viewBounds.height
        let viewWidth = viewBounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        let deviceAspectRatio = viewWidth/viewHeight
        let sceneAspectRatio = sceneWidth/sceneHeight
        
        //If the the device's aspect ratio is smaller than the aspect ratio of the preset scene dimensions, then that would mean that the visible width will need to be calculated
        //as the scene's height has been scaled to match the height of the device's screen. To keep the aspect ratio of the scene this will mean that the width of the scene will extend
        //out from what is visible.
        //The opposite will happen in the device's aspect ratio is larger.
        if deviceAspectRatio < sceneAspectRatio {
            let newSceneWidth: CGFloat = (sceneWidth * viewHeight) / sceneHeight
            let sceneWidthDifference: CGFloat = (newSceneWidth - viewWidth)/2
            let diffPercentageWidth: CGFloat = sceneWidthDifference / (newSceneWidth)
            
            //Increase the x-offset by what isn't visible from the lrft of the scene
            x = diffPercentageWidth * sceneWidth
            //Multipled by 2 because the diffPercentageHeight is only accounts for one side(e.g right or left) not both
            sceneWidth = sceneWidth - (diffPercentageWidth * 2 * sceneWidth)
        } else {
            let newSceneHeight: CGFloat = (sceneHeight * viewWidth) / sceneWidth
            let sceneHeightDifference: CGFloat = (newSceneHeight - viewHeight)/2
            let diffPercentageHeight: CGFloat = fabs(sceneHeightDifference / (newSceneHeight))
            
            //Increase the y-offset by what isn't visible from the bottom of the scene
            y = diffPercentageHeight * sceneHeight
            //Multipled by 2 because the diffPercentageHeight is only accounts for one side(e.g top or bottom) not both
            sceneHeight = sceneHeight - (diffPercentageHeight * 2 * sceneHeight)
        }
        
        let visibleScreenOffset = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(sceneWidth), height: CGFloat(sceneHeight))
        return visibleScreenOffset
    }
    
    func loadSceneNodes() {
        guard let background = self.childNode(withName: "background") as? SKSpriteNode,
            let finishButton = self.camera?.childNode(withName: "finishButton") as? SKSpriteNode,
            let finishLine = self.childNode(withName: "finishLine") as? SKSpriteNode,
            let topHorse = self.childNode(withName: "tophorse") as? SKSpriteNode,
            let bottomHorse = self.childNode(withName: "bottomhorse") as? SKSpriteNode
            else
        {
            fatalError("Sprite Nodes not loaded")
        }
        self.topHorse = topHorse;
        self.bottomHorse = bottomHorse;
        self.finishButton = finishButton
        self.finishLine = finishLine
        self.fieldWidth = abs(topHorse.position.y - bottomHorse.position.y)
        self.background = background
        
    }
    
    private func setCameraConstraints(viewSize: CGSize) {
        // Don't try to set up camera constraints if we don't yet have a camera.
        guard let camera = camera else { return }
        
        let sceneRect = background.calculateAccumulatedFrame()
        let visibleRect = self.getVisibleScreen(sceneBounds: sceneRect, viewBounds: viewSize)
        let offset = visibleRect.width / 2;
        print("viewRect \(viewSize) sceneRect \(sceneRect) visibleRect\(visibleRect) offset \(offset)")
        let xRange = SKRange(lowerLimit: offset, upperLimit: sceneRect.maxX - offset)
        let yRange = SKRange(lowerLimit: 0, upperLimit: 0)
        let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        
        // Constrain the camera to stay a constant distance of 0 points from the player node.
        //let zeroRange = SKRange(constantValue: 0.0)
        //let horseConstraint = SKConstraint.distance(zeroRange, to: topHorse)
        camera.constraints = [levelEdgeConstraint]
    }
    
    func viewWillTransition(to size: CGSize) {
        setCameraConstraints(viewSize: size);
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
    
    func updateCamera() {
        if #available(iOS 9.0, *) {
            if let camera = camera, (horses.count > 0) {
                let leadHorse = horses.sorted(by: { $0.position.x > $1.position.x })[0];
                camera.position = CGPoint(x: leadHorse.position.x, y: 0)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
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
        if firstBody.categoryBitMask == self.horseMask &&
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
        if let runner = object as? Runner,
        let newHorseSprite = bottomHorse.copy() as? SKSpriteNode
        {
            let myMultiplier = CGFloat(atIndex)
            //newHorseSprite.texture = SKTexture(imageNamed: "TanHorse01")
            let timeToFinish: Double = Double(arc4random_uniform(60) + 40) / 10.0;
            let horseColor = arc4random_uniform(5) + 1;
            var textureAtlas = brownTexture
            switch(horseColor) {
            case 1:
                newHorseSprite.texture = SKTexture(imageNamed: "TanHorse01.png");
                textureAtlas = tanTexture
                break;
            case 2:
                newHorseSprite.texture = SKTexture(imageNamed: "BlackHorse01.png");
                textureAtlas = blackTexture
                break;
            case 3:
                newHorseSprite.texture = SKTexture(imageNamed: "GreyHorse01.png");
                textureAtlas = greyTexture
                break;
            default:
                newHorseSprite.texture = SKTexture(imageNamed: "BrownHorse01.png");
                textureAtlas = brownTexture
                break;
            }
            newHorseSprite.zPosition -= myMultiplier;
            let newY:  CGFloat = newHorseSprite.position.y + (fieldWidth / CGFloat(numRunners)) * myMultiplier
            newHorseSprite.position = CGPoint(x: newHorseSprite.position.x, y: newY)
            print("adding \(runner.name!) at \(newHorseSprite.position)")
            if let horseName = newHorseSprite.childNode(withName: "name") as? SKLabelNode {
                horseName.text = runner.name!
            }
            let wait = SKAction.wait(forDuration: 3)
            let animateAction = SKAction.animate(with: textureAtlas, timePerFrame: 0.05)
            let repeatAnimation = SKAction.repeatForever(animateAction)
            let moveToFinish = SKAction.moveTo(x: self.finishLine.position.x, duration: timeToFinish)
            let combinedMovement = SKAction.group([repeatAnimation,moveToFinish])
            newHorseSprite.run(SKAction.sequence([wait, combinedMovement]))
            horses.append(newHorseSprite);
            self.addChild(newHorseSprite);
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
