//
//  UIViewController+Delay.swift
//  Sense
//
//  Created by Jimmy Lu on 12/14/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

extension UIViewController {

    func dismiss(delay: Double, animated: Bool, completion: ((Void) -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {[weak self] (Void) in
            self?.dismiss(animated: animated, completion: completion)
        })
    }
    
}
