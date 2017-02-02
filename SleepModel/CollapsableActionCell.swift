//
//  CollapsableActionCell.swift
//  Sense
//
//  Created by Jimmy Lu on 2/1/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

@objc protocol CollapsableActionLinkDelegate: class {
    @objc func showLink(url: URL!, from cell:CollapsableActionCell!)
}

@objc class CollapsableActionCell: UICollectionViewCell {
    
    @objc enum ViewState: Int {
        case collapse = 1
        case expand
    }
    
    static let baseHeight = CGFloat(56.0)
    static let buttonHeight = CGFloat(56.0)
    static let bottomSpacing = CGFloat(21.0)
    static let bodyTopSpacing = CGFloat(10.0)
    static let bodyBottomSpacing = CGFloat(14.0)
    static let bodyHorzMargin = CGFloat(24.0)
    static let bodyLeftInset = CGFloat(-4.0)
    static let bodyTopInset = CGFloat(-8.0)
    static let accessoryCollapsedAngle = 90.0
    static let accessoryExpandedAngle = -90.0
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet fileprivate weak var bodyView: UITextView?
    @IBOutlet weak var actionButton: HEMActionButton?
    @IBOutlet fileprivate var accessoryView: UIImageView?
    
    weak var linkDelegate: CollapsableActionLinkDelegate?
    
    @objc static func height(body: NSAttributedString!,
                             collapsed: Bool,
                             cellWidth: CGFloat) -> CGFloat {
        guard collapsed == false else {
            return CollapsableActionCell.baseHeight
        }
        
        let margins = CollapsableActionCell.bodyHorzMargin * 2
        let maxWidth = cellWidth - margins + bodyLeftInset
        let bodyHeight = body.size(withWidth: maxWidth).height
        
        return baseHeight
            + bodyTopSpacing
            + bodyHeight
            + bodyBottomSpacing
            + buttonHeight
            + bottomSpacing
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.font = UIFont.body()
        self.titleLabel?.textColor = UIColor.grey6()
        self.bodyView?.isEditable = false
        self.bodyView?.isScrollEnabled = false
        self.bodyView?.textContainerInset = UIEdgeInsets(top: CollapsableActionCell.bodyTopInset,
                                                         left: CollapsableActionCell.bodyLeftInset,
                                                         bottom: CGFloat(0),
                                                         right: CGFloat(0))
        self.bodyView?.delegate = self
        self.collapse()
    }
    
    @objc func isCollapsed() -> Bool {
        return self.bodyView?.isHidden == true
    }
    
    @objc func set(body: NSAttributedString!) {
        self.bodyView?.attributedText = body
    }
    
    @objc func set(state: ViewState) {
        switch state {
            case .collapse:
                self.collapse()
            case .expand:
                self.expand()
        }
    }
    
    fileprivate func collapse() {
        if self.isCollapsed() == false {
            let radians = HEMDegreesToRadians(CollapsableActionCell.accessoryCollapsedAngle)
            self.accessoryView?.transform = CGAffineTransform(rotationAngle: CGFloat(radians))
        }
        self.bodyView?.isHidden = true
        self.actionButton?.isHidden = true
    }
    
    fileprivate func expand() {
        if self.isCollapsed() == true {
            let radians = HEMDegreesToRadians(CollapsableActionCell.accessoryExpandedAngle)
            self.accessoryView?.transform = CGAffineTransform(rotationAngle: CGFloat(radians))
        }
        self.bodyView?.isHidden = false
        self.actionButton?.isHidden = false
    }
    
}

extension CollapsableActionCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.linkDelegate?.showLink(url: URL, from: self)
        return false
    }
    
}
