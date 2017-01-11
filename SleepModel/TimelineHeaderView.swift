//
//  TimelineHeaderView.swift
//  Sense
//
//  Created by Jimmy Lu on 1/6/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

@objc class TimelineHeaderView : UICollectionReusableView {
    
    @objc @IBOutlet weak var historyButton: UIButton!
    @objc @IBOutlet weak var titleLabel: UILabel!
    @objc @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        let titleAttributes = NavTitleAttributes() as NSDictionary
        self.titleLabel.font = titleAttributes.object(forKey: NSFontAttributeName) as! UIFont!
        self.titleLabel.textColor = titleAttributes.object(forKey: NSForegroundColorAttributeName) as! UIColor!
    }
    
}
