//
//  NSBundle+JSON.swift
//  Sense
//
//  Created by Jimmy Lu on 3/6/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension Bundle {
    
    fileprivate static let jsonExtension = "json"
    
    static func read(jsonFileName: String) -> Any? {
        let bundle = Bundle.main
        guard let path = bundle.path(forResource: jsonFileName, ofType: Bundle.jsonExtension) else {
            return nil
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        return try! JSONSerialization.jsonObject(with: data, options: [])
    }
    
}
