//
//  StatusMessageCell.swift
//  Sense
//
//  Created by Jimmy Lu on 12/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

class StatusMessageCell: UICollectionViewCell {
    
    static let imageTopPadding = CGFloat(72)
    static let imageHeight = CGFloat(104)
    static let textHorzPadding = CGFloat(24)
    static let titleTopPadding = CGFloat(36)
    static let titleBotPadding = CGFloat(4)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    static func titleAttributes() -> [String : Any] {
        let color = SenseStyle.color(aClass: StatusMessageCell.self, property: .titleColor)
        let font = SenseStyle.font(aClass: StatusMessageCell.self, property: .titleFont)
        let para = NSMutableParagraphStyle.senseStyle()
        para.alignment = NSTextAlignment.center
        return [NSFontAttributeName : font,
                NSForegroundColorAttributeName : color,
                NSParagraphStyleAttributeName : para]
    }
    
    static func messageAttributes() -> [String : Any] {
        let color = SenseStyle.color(aClass: StatusMessageCell.self, property: .textColor)
        let font = SenseStyle.font(aClass: StatusMessageCell.self, property: .textFont)
        let para = NSMutableParagraphStyle.senseStyle()
        para.alignment = NSTextAlignment.center
        return [NSFontAttributeName : font,
                NSForegroundColorAttributeName : color,
                NSParagraphStyleAttributeName : para]
    }
    
    static func boldMessageAttributes() -> [String : Any] {
        let color = SenseStyle.color(aClass: StatusMessageCell.self, property: .textHighlightedColor)
        var attributes = self.messageAttributes()
        attributes[NSForegroundColorAttributeName] = color
        return attributes
    }
    
    static func height(title: NSAttributedString!, message: NSAttributedString!, itemWidth: CGFloat) -> CGFloat {
        let maxTextWidth = itemWidth - (textHorzPadding * 2)
        let titleHeight = title.size(withWidth: maxTextWidth).height
        let messageHeight = message.size(withWidth: maxTextWidth).height
        return imageTopPadding
            + imageHeight
            + titleTopPadding
            + titleHeight
            + titleBotPadding
            + messageHeight
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.contentMode = UIViewContentMode.center
        self.messageLabel.numberOfLines = 0
    }
    
    func applyStyle() {
        self.backgroundColor = SenseStyle.color(aClass: StatusMessageCell.self, property: .backgroundColor)
    }
    
}
