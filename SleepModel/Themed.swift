//
//  Themed.swift
//  Sense
//
//  Created by Jimmy Lu on 3/7/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

@objc protocol Themed: class {
    /**
        Called when the Theme for the application has been changed. Implementations
        should take the Theme object and apply changes to objects it manages.
        
        - Parameter theme: the current Theme selected
     */
    func didChange(theme: Theme)
}

extension Themed where Self: UIViewController {}
