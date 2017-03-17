//
//  UISearchBar+Color.swift
//  Sense
//
//  Created by Jimmy Lu on 3/16/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UISearchBar {
    
    /**
        This is not a recommended approach, but there is currently no way to
        update the background color of the text field inside of a search bar,
        besides using a background image
    */
    func changeFieldColor(color : UIColor?) {
        guard color != nil else {
            return
        }
        
        for subView in self.subviews {
            for subSubView in subView.subviews {
                if let _ = subSubView as? UITextInputTraits {
                    let textField = subSubView as! UITextField
                    textField.backgroundColor = color
                    break
                }
            }
        }
    }
    
}
