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
    @IBOutlet fileprivate weak var actionButton: HEMActionButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView?.backgroundColor = UIColor.white
        self.iconView?.image = UIImage(named: "warning")
        self.titleLabel?.textColor = UIColor.grey6()
        self.titleLabel?.font = UIFont.body()
        self.messageLabel?.textColor = UIColor.grey5()
        self.messageLabel?.font = UIFont.body()
        self.separator?.backgroundColor = UIColor.separator()
    }
    
}
