//
//  WarningView.swift
//  Sense
//
//  Created by Jimmy Lu on 2/2/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

@objc class WarningView: UIView {
    
    @IBOutlet fileprivate weak var contentView: UIView?
    @IBOutlet fileprivate weak var iconView: UIImageView?
    @IBOutlet fileprivate(set) weak var titleLabel: UILabel?
    @IBOutlet fileprivate weak var separator: UIView?
    @IBOutlet fileprivate(set) weak var messageLabel: UILabel?
    @IBOutlet fileprivate(set) weak var actionButton: HEMActionButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconView?.image = UIImage(named: "warning")
        self.messageLabel?.numberOfLines = 0
        self.applyStyle()
    }
    
}

extension WarningView {
    
    static func messageAttributes() -> [String : Any] {
        let detailFont = SenseStyle.font(group: .warningView, property: .detailFont)
        let detailColor = SenseStyle.color(group: .warningView, property: .detailColor)
        return [NSFontAttributeName : detailFont,
                NSForegroundColorAttributeName : detailColor,
                NSParagraphStyleAttributeName : NSMutableParagraphStyle.senseStyle()]
    }
    
    func applyStyle() {
        let separatorColor = SenseStyle.color(group: .warningView, property: .separatorColor)
        let bgColor = SenseStyle.color(group: .warningView, property: .backgroundColor)
        let textColor = SenseStyle.color(group: .warningView, property: .textColor)
        let detailColor = SenseStyle.color(group: .warningView, property: .detailColor)
        let textFont = SenseStyle.font(group: .warningView, property: .textFont)
        let detailFont = SenseStyle.font(group: .warningView, property: .detailFont)
        self.contentView?.backgroundColor = bgColor
        self.titleLabel?.textColor = textColor
        self.titleLabel?.font = textFont
        self.messageLabel?.textColor = detailColor
        self.messageLabel?.font = detailFont
        self.separator?.backgroundColor = separatorColor
    }
    
}
