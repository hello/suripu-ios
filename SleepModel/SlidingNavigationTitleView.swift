//
//  SlidingNavigationTitleView.swift
//  Sense
//
//  Created by Jimmy Lu on 12/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

protocol SlidingNavigationDelegate: class {
    func didTapOn(title: String, from: SlidingNavigationTitleView)
}

class SlidingNavigationTitleView: UIView {
    
    static let lineHeight = CGFloat(1)
    
    fileprivate var titles: Array<String>!
    fileprivate var highlightLine: UIView!
    fileprivate var controls: Array<UIControl>!
    
    weak var delegate: SlidingNavigationDelegate?
    
    var selectedIndex: Int!
    
    init(titles: Array<String>!, size: CGSize) {
        super.init(frame: CGRect(origin: CGPoint.zero, size: size))
        self.configureSubviews(titles: titles)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureSubviews(titles: [])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let controlCount = self.controls.count
        if controlCount > 0 {
            let controlWidth = self.frame.size.width / CGFloat(controlCount)
            let fullHeight = self.frame.size.height
            for (index, control) in self.controls.enumerated() {
                var controlFrame = control.frame
                controlFrame.size.width = controlWidth
                controlFrame.origin.x = CGFloat(index) * controlWidth
                controlFrame.size.height = fullHeight
                control.frame = controlFrame
            }
            
            if self.highlightLine != nil {
                var lineFrame = self.highlightLine.frame
                lineFrame.size.width = controlWidth
                lineFrame.origin.y = fullHeight
                self.highlightLine.frame = lineFrame
            }
        }
    }
    
    // MARK: - Controls
    
    fileprivate func configureSubviews(titles: Array<String>!) {
        self.titles = titles
        self.controls = Array<UIControl>()
        let needed = titles.count
        for (index, title) in titles.enumerated() {
            self.addControl(title: title, index: index, total: needed)
        }
        
        if titles.count > 1 {
            self.addHighlightLine()
        }
    }
    
    fileprivate func addControl(title: String!, index: Int, total: Int) {
        let width = self.frame.size.width / CGFloat(max(1, total))
        let height = self.frame.size.height
        let xOrigin = CGFloat(index) * width
        let control = UIButton(type: UIButtonType.custom)
        
        control.backgroundColor = UIColor.white
        control.titleLabel?.font = UIFont.body()
        control.setTitle(title, for: UIControlState.normal)
        control.setTitleColor(UIColor.grey4(), for: UIControlState.normal)
        control.setTitleColor(UIColor.tint(), for: UIControlState.selected)
        control.setTitleColor(UIColor.tint(), for: UIControlState.highlighted)
        control.frame = CGRect(origin: CGPoint(x: xOrigin, y: CGFloat(0)),
                               size: CGSize(width: width, height: height))
        control.addTarget(self,
                          action: #selector(SlidingNavigationTitleView.tap(control:)),
                          for: UIControlEvents.touchUpInside)
        
        self.controls.append(control)
        self.addSubview(control)
    }
    
    func tap(control: UIButton) {
        let title = control.title(for: UIControlState.normal)!
        self.delegate?.didTapOn(title: title, from: self)
    }
    
    // MARK: - Highlight
    
    fileprivate func addHighlightLine() {
        let width = self.frame.size.width / CGFloat(max(self.titles.count, 1))
        let height = self.frame.size.height
        let lineHeight = SlidingNavigationTitleView.lineHeight
        let yOrigin = height
        let frame = CGRect(origin: CGPoint(x: CGFloat(0), y: yOrigin),
                           size: CGSize(width: width, height: lineHeight))
        let lineView = UIView(frame: frame)
        
        lineView.backgroundColor = UIColor.tint()
        
        self.highlightLine = lineView
        self.addSubview(lineView)
    }
    
    func highlight(title: String!) {
        let index = self.titles.index(of: title)
        if index != nil {
            for (controlIndex, control) in self.controls.enumerated() {
                control.isHighlighted = controlIndex == index
            }
            self.selectedIndex = index
        }
    }
    
    func higlight(index: CGFloat) {
        let indexPercentage: CGFloat
        if index < CGFloat(self.selectedIndex) {
            indexPercentage = ceil(index)
        } else {
            indexPercentage = floor(index)
        }
        
        let controlHighlightIndex = Int(indexPercentage)
        for (index, control) in self.controls.enumerated() {
            control.isHighlighted = controlHighlightIndex == index
        }

        var frame = self.highlightLine.frame
        frame.origin.x = index * frame.size.width
        self.highlightLine.frame = frame
        
        self.selectedIndex = controlHighlightIndex
    }
    
}
