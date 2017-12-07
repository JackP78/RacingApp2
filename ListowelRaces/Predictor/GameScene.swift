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
    
    // horse nodes
    var horses: [SKSpriteNode] = []
    var currentHorse: Int = 0
    var horseMask: UInt32?
    
    var finishButton:SKSpriteNode!
    var finishLine:SKSpriteNode!
    var targetLocation: CGPoint = .zero
    var background:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        loadSceneNodes()
    	physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
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
            let finishLine = self.childNode(withName: "finishLine") as? SKSpriteNode
            else
        {
            fatalError("Sprite Nodes not loaded")
        }
        self.enumerateChildNodes(withName: "horse") {
            node, stop in
            if let horse = node as? SKSpriteNode {
                self.horseMask = horse.physicsBody?.categoryBitMask
                self.horses.append(horse)
            }
        }
        self.finishButton = finishButton
        self.finishLine = finishLine
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
        let levelEdgeConstraint = SKConstraint.positionX(xRange)
        
        
        // Constrain the camera to stay a constant distance of 0 points from the player node.
        let zeroRange = SKRange(constantValue: 0.0)
        let horseConstraint = SKConstraint.distance(zeroRange, to: horses[0])
        camera.constraints = [horseConstraint, levelEdgeConstraint]
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
        if let runner = object as? Runner, currentHorse < horses.count {
            let horse = self.horses[self.currentHorse];
            self.currentHorse = self.currentHorse + 1;
            if let horseName = horse.childNode(withName: "name") as? SKLabelNode {
                horseName.text = runner.name!
            }
            let wait = SKAction.wait(forDuration: 3)
            let go = SKAction.moveTo(x: self.finishLine.position.x, duration: 5)
            horse.run(SKAction.sequence([wait, go]))
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
