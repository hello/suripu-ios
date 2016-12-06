//
//  SleepScoreIcon.swift
//  Sense
//
//  Created by Jimmy Lu on 12/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

extension UIImage {
    
    static let iconSize = CGFloat(24)
    static let textPadding = CGFloat(2)
    static let borderWidth = CGFloat(1)
    
    @objc static func iconFromSleepScore(sleepScore: Int, highlighted: Bool) -> UIImage! {
        let scale = UIScreen.main.scale
        let size = CGSize(width: UIImage.iconSize, height: UIImage.iconSize)
        let color = highlighted ? UIColor.tint()! : UIColor.grey4()!
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        // draw a circle
        let ctx = UIGraphicsGetCurrentContext()!
        let radius = (size.width - (borderWidth * 2))/2
        let center = CGPoint(x: size.width/2, y: size.height/2)
        ctx.saveGState()
        
        if highlighted {
            let circleSize = CGSize(width: size.width - borderWidth,
                                    height: size.height - borderWidth)
            let circleRect = CGRect(origin: CGPoint.zero, size: circleSize)
            ctx.setFillColor(UIColor.blue2().cgColor)
            ctx.fillEllipse(in: circleRect)
        }
        
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(borderWidth)
        ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: 2 * CGFloat(M_PI), clockwise: true)
        ctx.drawPath(using: CGPathDrawingMode.stroke)
        ctx.restoreGState()
        
        // draw the text, with default being --
        let text: NSString
        if (sleepScore == 0) {
            text = NSLocalizedString("empty-data", comment: "text when sleep score is 0") as NSString
        } else {
            text = NSString(format: "%ld", sleepScore)
        }
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.h8(),
                                                NSParagraphStyleAttributeName: style,
                                                NSForegroundColorAttributeName : color]
        let textSize = text.sizeBounded(byWidth: size.width, attriburtes: attributes)
        let textRect = CGRect(x: (size.width - textSize.width) / 2,
                              y: (size.height - textSize.height) / 2,
                              width: textSize.width,
                              height: textSize.height)
        text.draw(in: textRect, withAttributes: attributes)
        
        // generate the image
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
    
}
