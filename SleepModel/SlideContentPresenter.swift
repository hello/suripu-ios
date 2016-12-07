//
//  SlideContentPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 12/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

protocol SlideContentVisibilityDelegate: class {
    
    func update(viewAtIndex: Int, visible: Bool, from: SlideContentPresenter)
    
}

class SlideContentPresenter: HEMPresenter, UIScrollViewDelegate, SlidingNavigationDelegate {
    
    weak var visibilityDelegate: SlideContentVisibilityDelegate?
    
    fileprivate weak var navigationBar: UINavigationBar?
    fileprivate weak var slidingTitleView: SlidingNavigationTitleView?
    fileprivate weak var contentScrollView: UIScrollView!
    fileprivate var contentViews: Array<UIView>!
    fileprivate var contentTitles: Array<String>!
    fileprivate var contentVisibility: Array<Bool>!
    
    init?(views: Array<UIView>!, titles: Array<String>!) {
        super.init()
        
        if views.count != titles.count {
            return nil
        } else {
            self.contentViews = views
            self.contentTitles = titles
            self.contentVisibility = Array(repeating: false, count: views.count)
        }
    }
    
    // MARK: - Bindings
    
    func bind(navigationBar: UINavigationBar?) {
        let size = navigationBar?.frame.size
        let navSize = size != nil ? size! : CGSize.zero
        let titleView = SlidingNavigationTitleView(titles: self.contentTitles,
                                                   size: navSize)
        
        titleView.highlight(title: self.contentTitles.first!)
        titleView.delegate = self
        navigationBar?.topItem?.titleView = titleView
        navigationBar?.topItem?.leftBarButtonItem = nil
        
        self.navigationBar = navigationBar
        self.slidingTitleView = titleView
    }
    
    func bind(scrollView: UIScrollView!) {
        var contentSize = scrollView.contentSize
        contentSize.width = CGFloat(self.contentViews.count) * scrollView.frame.size.width
        scrollView.contentSize = contentSize
        scrollView.backgroundColor = UIColor.background()
        scrollView.delegate = self
        self.contentScrollView = scrollView
    }
    
    fileprivate func layoutContent() {
        if self.contentScrollView.subviews.count > 0 {
            let scrollFrame = self.contentScrollView.frame
            let viewWidth = scrollFrame.size.width
            
            for (index, view) in self.contentScrollView.subviews.enumerated() {
                if self.contentViews.contains(view) {
                    var contentFrame = view.frame
                    contentFrame.size.width = viewWidth
                    contentFrame.size.height = scrollFrame.size.height
                    contentFrame.origin.x = CGFloat(index) * contentFrame.size.width
                    view.frame = contentFrame
                }
            }
            
            // content size should always reflect number of content views,
            // regardless of the number of views actually in the scroll view
            // to allow for lazy loading on scroll
            var contentSize = self.contentScrollView.contentSize
            contentSize.width = CGFloat(self.contentViews.count) * viewWidth
            self.contentScrollView.contentSize = contentSize
        }
        
        if self.slidingTitleView != nil && self.navigationBar != nil {
            var titleFrame = self.slidingTitleView!.frame
            titleFrame.size = self.navigationBar!.frame.size
            self.slidingTitleView!.frame = titleFrame
        }
    }
    
    fileprivate func insertContentViewIfNeeded(index: Int) {
        if index < self.contentViews.count {
            let view = self.contentViews[index]
            let scrollFrame = self.contentScrollView.frame
            
            if !self.contentScrollView.subviews.contains(view) {
                var frame = view.frame
                frame.size = scrollFrame.size
                frame.origin.y = 0.0
                frame.origin.x = CGFloat(index) * frame.size.width
                view.frame = frame
                self.contentScrollView.addSubview(view)
            }
        }
    }
    
    fileprivate func updateContentVisibility() {
        let scrollFrame = self.contentScrollView.bounds
        for (index, view) in self.contentViews.enumerated() {
            let wasVisible = self.contentVisibility[index]
            let intersects = scrollFrame.intersects(view.frame)
            let inScrollView = self.contentScrollView.subviews.contains(view)
            let visibleNow = intersects && inScrollView
            self.contentVisibility[index] = visibleNow
            
            if (wasVisible != visibleNow) {
                self.visibilityDelegate?.update(viewAtIndex: index,
                                                visible: visibleNow,
                                                from: self)
            }
        }
    }
    
    // MARK: Presenter Events
    
    override func willAppear() {
        super.willAppear()
        self.insertContentViewIfNeeded(index: 0)
    }
    
    override func didAppear() {
        super.didAppear()
        self.updateContentVisibility()
    }
    
    override func didDisappear() {
        super.didDisappear()
        self.updateContentVisibility()
    }
    
    override func didRelayout() {
        super.didRelayout()
        self.layoutContent()
    }
    
    // MARK: Content Scroll View Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentXOffset = scrollView.contentOffset.x
        let pageWidth = scrollView.frame.size.width
        let pagePercentage = contentXOffset / pageWidth
        let pageIndex = Int(ceil(pagePercentage))
        self.insertContentViewIfNeeded(index: pageIndex)
        self.updateContentVisibility()
        self.slidingTitleView?.higlight(index: pagePercentage)
    }
    
    // MARK: Nav Delegate
    
    func didTapOn(title: String, from: SlidingNavigationTitleView) {
        let index = self.contentTitles.index(of: title)
        if index != nil && index! < self.contentViews.count {
            let x = CGFloat(index!) * self.contentScrollView.frame.size.width
            let offset = CGPoint(x: x, y: 0.0)
            self.contentScrollView.setContentOffset(offset, animated: true)
        }
    }
    
    // MARK: Clean Up
    
    deinit {
        if self.contentScrollView != nil {
            self.contentScrollView.delegate = nil
        }
    }
    
}
