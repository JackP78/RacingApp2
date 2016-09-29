//
//  CircleView.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 27/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import SVGPath

class SplashView: UIView {
    
    var animatedShapes = [CAShapeLayer]()
    var topText : CATextLayer?
    var bottomText : CATextLayer?
    let greenColor = UIColor(red: 0.024, green: 0.244, blue: 0.165, alpha: 1)
    let brownColor = UIColor(red: 0.608, green: 0.472, blue: 0.394, alpha: 1)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createHorseShoe()
        createHorseHead()
        topText = addText("LISTOWEL", color: greenColor, top: true)
        bottomText = addText("RACES", color: brownColor, top: false)
        self.layer.addSublayer(topText!)
        self.layer.addSublayer(bottomText!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    func animateLogoWithCompletion(duration: NSTimeInterval, onComplete : (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock { 
            onComplete?()
        }
        
        let keyTimes = [0, 0.4, 1];
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1, 0.9, 300];
        animation.keyTimes = keyTimes;
        animation.duration = duration;
        animation.removedOnCompletion = false;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut), CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn)]
        
        for layer in animatedShapes {
            layer.addAnimation(animation, forKey: "GrowLogo")
        }
        
        let textAnimate = CAKeyframeAnimation(keyPath: "position.y")
        textAnimate.values = [topText!.position.y, topText!.position.y + 5, topText!.position.y - self.bounds.height];
        textAnimate.keyTimes = keyTimes;
        textAnimate.duration = duration;
        textAnimate.removedOnCompletion = false;
        textAnimate.fillMode = kCAFillModeForwards;
        textAnimate.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut), CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn)]
        topText?.addAnimation(textAnimate, forKey: "TopText")
        
        let textAnimate2 = CAKeyframeAnimation(keyPath: "position.y")
        textAnimate2.values = [bottomText!.position.y, bottomText!.position.y - 5, bottomText!.position.y + self.bounds.height];
        textAnimate2.keyTimes = keyTimes;
        textAnimate2.duration = duration;
        textAnimate2.removedOnCompletion = false;
        textAnimate2.fillMode = kCAFillModeForwards;
        textAnimate2.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut), CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn)]
        bottomText?.addAnimation(textAnimate2, forKey: "BottoText")
        
        CATransaction.commit()
    }
    
    func createHorseHead() {
        let horseHeadPath = UIBezierPath(svgPath: "M74.6,8.4c7.8,6.5,26.7,22.6,26.7,35c0,2.3,0,2.3,0,2.3s-13.7,33.5-5.7,39.2c7-6.2,5.9-5.9,9.8-8.5" +
            "c0.9-0.6,0,0,0,0c-0.5,0.9,4.2,9-24.5,30c0,0-3.8,4.2-3,16.2c-4,13-11.3,11.2-16.1,33.6c1.5,1.8,3.6,0,8.5-1" +
            "c1.7,1.2,1.3,13.7,6.8,16.7s25.7-35.3,22.7-53.8c-5.2-6.3-6.3-1.3-10.8-7c5.5-6.8,11.5,1.2,19-25c4.7,5,0,16.3,0,16.5" +
            "s-1.8,13.7,3,17.2c4.8,3.5,29.3-4,6.5-64.5c6.7,2.8,20.7,43.7,20.3,53.5c-0.3,9.8-1.5,10.8-5.8,18.3c-4.3,7.5-16.2,9.2-33.2,33.3" +
            "c-2,7.3-8.7,19.8-12.3,24.7c-3.7,4.8-0.8,1.8-6.7,6s-31.3,0.5-32.7-25c4.8-10.3,26.5-41.7,7.7-70.7c-0.7-4.3,16.9-37.9-0.3-60.7" +
            "c-6-7.9-10.5-17.2-5-13s14.5,17.5,20,14.5c2.2-1.2,4.1,2.3,4.2-26C73.6,8.4,74.6,8.4,74.6,8.4z")
        
        let horseHeadPath2 = UIBezierPath(svgPath: "M144.1,93.6c0,2.7-18.8-30.7-18.3-37c2.2,0.3,5,0.5,17.3,7.8C143.1,64.4,143.7,70.4,144.1,93.6z")
        
        let headlayer = createShapeLayerFrom([horseHeadPath, horseHeadPath2], color: greenColor, lineWidth: 1)
        self.layer.addSublayer(headlayer)
        animatedShapes.append(headlayer)
    }
    
    func addText(text: String, color : UIColor, top : Bool) -> CATextLayer{
        let listowelTextLayer = CATextLayer()
        let height = CGFloat(75)
        listowelTextLayer.font = CTFontCreateWithName("AromaNo2LTW01-ExtraBold", 40, nil)
        listowelTextLayer.foregroundColor = color.CGColor
        listowelTextLayer.alignmentMode = kCAAlignmentCenter
        listowelTextLayer.contentsScale = UIScreen.mainScreen().scale
        listowelTextLayer.string = text
        listowelTextLayer.fontSize = 60
        let yPos = (top) ? 10 : (CGRectGetMaxY(self.bounds) - 10 - height)
        listowelTextLayer.frame = CGRectMake(0, yPos, CGRectGetWidth(self.bounds), height)
        return listowelTextLayer
    }
    
    
    func createHorseShoe() {
        
        let greenHorseShoe = UIBezierPath(svgPath: "M110.2,210.3c0,0,4.9,0.2,5.2-4.3c96-32.3,54.1-159.5,43.8-181.8l6-3.2c-0.2-13.5-0.9-13.3-2.9-14.6" +
            "s-23.4,2.4-23.8,4.1c-1.1,4-0.3,13.4-0.3,13.4s3,2.1,3.3,3c1.3,4.2,28,141-48.7,143.8h-2.7C13.6,167.8,40.2,31,41.6,26.8" +
            "c0.3-0.9,3.3-3,3.3-3s0.7-9.5-0.3-13.4C44.1,8.7,22.7,5,20.7,6.3s-2.6,1.1-2.9,14.6l6,3.2C13.7,46.5-28.3,173.6,67.7,205.9" +
            "c0.2,4.5,5.2,4.3,5.2,4.3H110.2z")
        
        /*let brownHorseShoe = UIBezierPath(svgPath: "M72.8,214.3c-3.4,0-7-1.7-8.5-5.3c-25.2-9-43-25.3-53-48.4C-9.1,113.4,9,49.4,18.8,25.9l-5-2.7l0-2.4" +
            "C14.1,8.1,14.5,5.4,18.4,3l0.2-0.1c1-0.6,2.1-0.9,4-0.9c3.6,0,9.6,0.9,13.7,1.7c9.4,1.8,11.4,3,12.1,5.6" +
            "c1.2,4.3,0.6,13.1,0.5,14.8L48.7,26l-1.6,1.1c-0.7,0.5-1.5,1.1-1.9,1.5c-0.9,3.8-4.6,23.9-5.2,47.7c-0.5,22.5,1.7,53.3,15.6,72.4" +
            "c8.4,11.5,19.7,17.4,34.7,18h2.5c15-0.6,26.3-6.5,34.7-18c13.8-19.1,16.1-49.9,15.6-72.4c-0.6-23.7-4.3-43.7-5.2-47.7" +
            "c-0.4-0.4-1.2-1-1.9-1.5l-1.6-1.1l-0.2-1.9c-0.1-1-0.8-10.2,0.5-14.7c0.7-2.6,2.6-3.8,12.1-5.6c4.1-0.8,10.1-1.7,13.7-1.7" +
            "c1.9,0,3,0.2,4,0.9l0.2,0.1c3.9,2.4,4.3,5.1,4.6,17.8l0,2.4l-5,2.7c9.7,23.5,27.9,87.5,7.4,134.7c-10,23.1-27.8,39.4-53,48.4" +
            "c-1.4,3.6-5.1,5.3-8.5,5.3C110.3,214.3,72.8,214.3,72.8,214.3z")*/
        
        let horseShoe1 = createShapeLayerFrom([greenHorseShoe], color: greenColor, lineWidth: 4)
        horseShoe1.strokeColor = greenColor.CGColor
        horseShoe1.fillColor = brownColor.CGColor
        self.layer.addSublayer(horseShoe1)
        animatedShapes.append(horseShoe1)
        
        /*let horseShoe2 = createShapeLayerFrom([brownHorseShoe], color: brownColor, lineWidth: 1)
        horseShoe1.strokeColor = UIColor.whiteColor().CGColor
        horseShoe1.fillColor = brownColor.CGColor
        self.layer.addSublayer(horseShoe2)*/
    }
    
    
    func createShapeLayerFrom(strokes: [UIBezierPath], color : UIColor, lineWidth : CGFloat) -> CAShapeLayer {
        let combinedPath = CGPathCreateMutableCopy(strokes[0].CGPath);
        var shapeBounds = strokes[0].bounds
        if (strokes.count > 1) {
            for index in 1...(strokes.count - 1) {
                CGPathAddPath(combinedPath, nil, strokes[index].CGPath);
                shapeBounds = CGRectUnion(shapeBounds, strokes[index].bounds)
            }
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = combinedPath
        NSLog("combined path bounds \(combinedPath)")
        shapeLayer.bounds = shapeBounds
        shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        shapeLayer.anchorPoint = CGPointMake(0.5, 0.5);
        shapeLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        shapeLayer.fillColor = color.CGColor
        shapeLayer.lineWidth = lineWidth
        return shapeLayer
    }

}
