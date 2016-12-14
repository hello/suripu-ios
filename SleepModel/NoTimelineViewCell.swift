//
//  NoTimelineView.swift
//  Sense
//
//  Created by Jimmy Lu on 12/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

@objc class NoTimelineViewCell: UICollectionViewCell {
    
    static fileprivate let imageHeight = CGFloat(162.0)
    static fileprivate let imageTopMargin = CGFloat(12.0)
    static fileprivate let imageBottomMargin = CGFloat(23.0)
    static fileprivate let titleBottomMargin = CGFloat(18.0)
    static fileprivate let messageBottomMargin = CGFloat(25.0)
    static fileprivate let buttonHeight = CGFloat(40.0)
    static fileprivate let buttonBottomMargin = CGFloat(12.0)
    static fileprivate let textSideMargins = CGFloat(48.0)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var moreButton: HEMActionButton!
    
    @objc static func height(title: NSAttributedString!,
                             message: NSAttributedString!,
                             cellWidth: CGFloat) -> CGFloat {
        let maxWidth = cellWidth - textSideMargins
        let titleHeight = title.size(withWidth: maxWidth).height
        let messageHeight = message.size(withWidth: maxWidth).height
        return imageHeight
             + imageTopMargin
             + imageBottomMargin
             + titleHeight
             + titleBottomMargin
             + messageHeight
             + messageBottomMargin
             + buttonHeight
             + buttonBottomMargin
    }
    
}
