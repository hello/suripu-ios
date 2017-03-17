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
    static let lineColorAlpha = CGFloat(0.8)
    static let topAlphaKey = "sense.top.alpha"
    static let botAlphaKey = "sense.bot.alpha"
    
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
        let gradientColor = SenseStyle.color(group: .chartGradient, property: .backgroundColor) ?? color
        let topAlphaNumber = SenseStyle.value(group: .chartGradient, propertyName: LineChartDataSet.topAlphaKey) as? NSNumber
        let botAlphaNumber = SenseStyle.value(group: .chartGradient, propertyName: LineChartDataSet.botAlphaKey) as? NSNumber
        return [gradientColor.withAlphaComponent(CGFloat(botAlphaNumber?.floatValue ?? 0)).cgColor,
                gradientColor.withAlphaComponent(CGFloat(topAlphaNumber?.floatValue ?? 0)).cgColor];
    }
    
    fileprivate func lineColor(color: UIColor) -> UIColor {
        return color.withAlphaComponent(LineChartDataSet.lineColorAlpha)
    }
    
}
