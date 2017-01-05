//
//  UITableViewCell+Accessory.swift
//  Sense
//
//  Created by Jimmy Lu on 1/4/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UITableViewCell {
    
    @objc func styledAccessoryView() -> UIView {
        let image = UIImage(named: "accessory")?.withRenderingMode(.alwaysTemplate)
        let size = image?.size ?? CGSize.zero
        let view = UIImageView(image: image)
        view.frame = CGRect(origin: CGPoint.zero, size: size)
        view.tintColor = UIColor.grey4()
        return view
    }
    
    @objc func showStyledAccessoryViewIfNone() {
        guard self.accessoryView == nil else {
            return
        }
        self.accessoryView = self.styledAccessoryView()
    }
}
