//
//  CircularLoadingView.swift
//  ProgressView
//
//  Created by Vasil Nunev on 23/07/2017.
//  Copyright © 2017 nunev. All rights reserved.
//

import UIKit

class CircularLoadingView: UIView, CAAnimationDelegate {
    let circlePathLayer = CAShapeLayer()
    let circleRadius: CGFloat = 20
    
    var progress: CGFloat {
        get{
            return circlePathLayer.strokeEnd
        }
        set{
            if newValue > 1 {
                circlePathLayer.strokeEnd = 1
            }else if newValue < 0 {
                circlePathLayer.strokeEnd = 0
            }else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        progress = 0 //Add this later on
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 2
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = UIColor.red.cgColor
        layer.addSublayer(circlePathLayer)
        backgroundColor = .white
    }
    
    //Create a rectangle frame that will give us a circle path
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        circleFrame.origin.x = circlePathLayer.bounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathLayer.bounds.midY - circleFrame.midY
        return circleFrame
    }
    //get the circle path
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    //Since layers don’t have an autoresizingMask property, you’ll need to update the circlePathLayer’s frame in layoutSubviews to respond appropriately to changes in the view’s size.
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
    }
    
    func reveal() {
        backgroundColor = .clear
        progress = 1
        circlePathLayer.removeAnimation(forKey: "strokeEnd")
        circlePathLayer.removeFromSuperlayer()
        superview?.layer.mask = circlePathLayer
        
        // Determine the radius of the circle that can fully circumscribe the image view, then calculate the CGRect that would fully bound this circle. toPath represents the final shape of the CAShapeLayer mask like so:
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
        let radiusInset = finalRadius - circleRadius
        let outerRect = circleFrame().insetBy(dx: -radiusInset, dy: -radiusInset)
        let toPath = UIBezierPath(ovalIn: outerRect).cgPath
        
        // Set the initial values of lineWidth and path to match the current values of the layer.
        let fromPath = circlePathLayer.path
        let fromLineWidth = circlePathLayer.lineWidth
        
        // Set lineWidth and path to their final values; this prevents them from jumping back to their original values when the animation completes. Wrapping this in a CATransaction with kCATransactionDisableActions set to true disables the layer’s implicit animations.
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        circlePathLayer.lineWidth = 2*finalRadius
        circlePathLayer.path = toPath
        CATransaction.commit()
        
        // Create two instances of CABasicAnimation, one for path and the other for lineWidth. lineWidth has to increase twice as fast as the radius increases in order for the circle to expand inward as well as outward.
        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.fromValue = fromLineWidth
        lineWidthAnimation.toValue = 2*finalRadius
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = fromPath
        pathAnimation.toValue = toPath
        
        // Add both animations to a CAAnimationGroup, and add the animation group to the layer. You also assign self as the delegate, as you'll use this in just a moment.
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 1
        groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        groupAnimation.animations = [pathAnimation, lineWidthAnimation]
        groupAnimation.delegate = self
        circlePathLayer.add(groupAnimation, forKey: "strokeWidth")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        superview?.layer.mask = nil
    }
}
