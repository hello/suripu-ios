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
        super.awakeFromNib()
        self.applyStyle()
    }
    
    @objc func applyStyle() {
        var historyImage = self.historyButton.image(for: UIControlState.normal)
        historyImage = historyImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.historyButton.setImage(historyImage, for: UIControlState.normal)
        
        var shareImage = self.shareButton.image(for: UIControlState.normal)
        shareImage = shareImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.shareButton.setImage(shareImage, for: UIControlState.normal)
        
        let aClass = UINavigationBar.self // this mimics the nav bar
        let tintColor = SenseStyle.color(aClass: aClass, property: .tintColor)
        self.backgroundColor = SenseStyle.color(aClass: aClass, property: .barTintColor)
        self.historyButton.tintColor = tintColor
        self.shareButton.tintColor = tintColor
        self.titleLabel.textColor = SenseStyle.color(aClass: aClass, property: .textColor)
        self.titleLabel.font = SenseStyle.font(aClass: aClass, property: .textFont)
    }
    
}
