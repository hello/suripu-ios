//
//  SENSensorDataCollection+Filter.swift
//  Sense
//
//  Created by Jimmy Lu on 12/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation
import SenseKit

extension SENSensorDataCollection {
    
    static let sentinel = -1
    
    @objc func filteredDataPoints(type: SENSensorType) -> [NSNumber]? {
        var points = self.dataPoints(for: type)
        let lastPoint = points?.last
        if lastPoint?.intValue == SENSensorDataCollection.sentinel {
            points?.removeLast()
        }
        return points
    }
    
}
