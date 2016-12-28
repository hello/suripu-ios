//
//  LineChartDataSet+Sensor.swift
//  Sense
//
//  Created by Jimmy Lu on 12/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation
import Charts

extension LineChartDataSet {
    
    static let gradientAngle = CGFloat(90.0)
    static let gradientTopAlpha = CGFloat(0.2)
    static let gradientBotAlpha = CGFloat(0.8)
    static let lineColorAlpha = CGFloat(0.8)
    
    @objc convenience init(data: [ChartDataEntry]?, color: UIColor) {
        self.init(values: data, label: nil)
        
        self.drawCirclesEnabled = false
        self.drawFilledEnabled = true
        self.drawValuesEnabled = false
        self.highlightColor = color
        self.label = nil
        self.drawHorizontalHighlightIndicatorEnabled = false
        self.mode = LineChartDataSet.Mode.horizontalBezier
        self.setColor(self.lineColor(color: color))
        
        let gradientColors = self.gradient(color: color)
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil);
        self.fill = Fill.fillWithLinearGradient(gradient!, angle: LineChartDataSet.gradientAngle)
    }
    
    fileprivate func gradient(color: UIColor) -> [CGColor] {
        return [color.withAlphaComponent(LineChartDataSet.gradientTopAlpha).cgColor,
                color.withAlphaComponent(LineChartDataSet.gradientBotAlpha).cgColor];
    }
    
    fileprivate func lineColor(color: UIColor) -> UIColor {
        return color.withAlphaComponent(LineChartDataSet.lineColorAlpha)
    }
    
}
