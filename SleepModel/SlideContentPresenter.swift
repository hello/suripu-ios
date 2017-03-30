//
//  SlideContentPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 12/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

protocol SlideContentVisibilityDelegate: class {
    
    func addController(controller: UIViewController, from: SlideContentPresenter?)
    func removeController(controller: UIViewController, from: SlideContentPresenter?)
    func update(viewAtIndex: Int, visible: Bool, from: SlideContentPresenter?)
    
}

class SlideContentPresenter: HEMPresenter {
    
    weak var visibilityDelegate: SlideContentVisibilityDelegate?
    fileprivate(set) weak var navigationBar: UINavigationBar?
    weak var slidingTitleView: SlidingNavigationTitleView?
    fileprivate(set) weak var contentScrollView: UIScrollView!
    var contentViews: Array<UIView>!
    fileprivate(set) var contentTitles: Array<String>!
    fileprivate(set) var contentControllers: Array<UIViewController>!
    fileprivate(set) var contentVisibility: Array<Bool>!
    fileprivate(set) var activity: HEMActivityIndicatorView?
    
    init?(controllers: Array<UIViewController>!) {
        super.init()
        guard controllers.count > 0 else {
            return nil
        }
        self.contentControllers = controllers
        self.contentTitles = self.titles(controllers: controllers)
        self.contentViews = Array<UIView>()
        self.contentVisibility = Array(repeating: false, count: controllers.count)
    }
    
    func titles(controllers: Array<UIViewController>!) -> Array<String> {
        var titles = Array<String>()
        for controller in controllers {
            titles.append(self.title(controller: controller))
        }
        return titles
    }
    
    // MARK: - Convenience
    
    fileprivate func title(controller: UIViewController!) -> String! {
        var controllerTitle: String!
        if controller.title != nil  {
            controllerTitle = controller.title
        } else if controller is HEMBaseController {
            controllerTitle = (controller as! HEMBaseController).tabTitle
        } else {
            controllerTitle = NSStringFromClass(object_getClass(controller))
        }
        return controllerTitle
    }
    
    /**
        Configure the content for the scrollview.  This is made in to it's only
        function to allow subclasses to override it
    **/
    func configureContent(scrollView: UIScrollView) {
        for controller in self.contentControllers {
            self.visibilityDelegate?.addController(controller: controller,
                                                   from: self)
            self.contentViews.append(controller.view)
        }
        
        scrollView.backgroundColor = SenseStyle.color(aClass: UIScrollView.self, property: .backgroundColor)
        var contentSize = scrollView.contentSize
        contentSize.width = CGFloat(self.contentViews.count) * scrollView.frame.size.width
        scrollView.contentSize = contentSize
    }
    
    /**
        Instantiate and configure the title view.  This is made in to it's only
        function to allow subclasses to override it
     **/
    func configureNavigationTitleView(size: CGSize) -> SlidingNavigationTitleView? {
        let titleView = SlidingNavigationTitleView(titles: self.contentTitles,
                                                   size: size)
        titleView.highlight(title: self.contentTitles.first!)
        titleView.delegate = self
        titleView.applyStyle()
        return titleView
    }
    
    func show(controllerIndex: NSInteger) {
        let index = min(max(controllerIndex, 0), self.contentControllers.count - 1)
        let x = CGFloat(index) * self.contentScrollView.bounds.width
        let offset = CGPoint(x: x, y: 0)
        self.contentScrollView.setContentOffset(offset, animated: false)
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
    }
    
    fileprivate func insertContentViewIfNeeded(index: Int) {
        guard index < self.contentViews.count else {
            return
        }
        
        let view = self.contentViews[index]
        guard !self.contentScrollView.subviews.contains(view) else {
            return
        }
        
        let scrollFrame = self.contentScrollView.frame
        var frame = view.frame
        frame.size = scrollFrame.size
        frame.origin.y = 0.0
        frame.origin.x = CGFloat(index) * frame.size.width
        view.frame = frame
        self.contentScrollView.addSubview(view)
    }
    
    fileprivate func updateContentVisibility() {
        let scrollFrame = self.contentScrollView.frame
        let scrollOffset = self.contentScrollView.contentOffset
        let visibleRect = CGRect(x: scrollOffset.x,
                                 y: scrollOffset.y,
                                 width: scrollFrame.size.width,
                                 height: scrollFrame.size.height)
        
        let window = self.contentScrollView.window
        for (index, view) in self.contentViews.enumerated() {
            let wasVisible = self.contentVisibility[index]
            let inFrame = visibleRect.contains(view.frame)
            let inScrollView = self.contentScrollView.subviews.contains(view)
            let visibleNow = window != nil && inFrame && inScrollView
            self.contentVisibility[index] = visibleNow
            
            if (wasVisible != visibleNow) {
                self.visibilityDelegate?.update(viewAtIndex: index,
                                                visible: visibleNow,
                                                from: self)
            }
        }
    }
    
    func applyStyle() {
        let bgColor = SenseStyle.color(aClass: UIScrollView.self, property: .backgroundColor)
        self.contentScrollView.backgroundColor = bgColor
        self.slidingTitleView?.applyStyle()
    }
    
    // MARK: Presenter Events
    
    override func didChange(_ theme: Theme, auto automatically: Bool) {
        super.didChange(theme, auto: automatically)
        self.applyStyle()
    }
    
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
    
    // MARK: Clean Up
    
    deinit {
        if self.contentScrollView != nil {
            self.contentScrollView.delegate = nil
        }
    }
    
}

extension SlideContentPresenter {
    
    func bind(activity: HEMActivityIndicatorView?) {
        activity?.stop()
        activity?.isHidden = true
        activity?.isUserInteractionEnabled = false
        self.activity = activity
    }
    
    func bind(navigationBar: UINavigationBar?) {
        guard navigationBar != nil else {
            return
        }
        
        let size = navigationBar?.frame.size
        let navSize = size ?? CGSize.zero
        let titleView = self.configureNavigationTitleView(size: navSize)
        let firstController = self.contentControllers.first!
        
        if titleView != nil {
            navigationBar?.topItem?.titleView = titleView
            self.slidingTitleView = titleView
        } else {
            navigationBar?.topItem?.title = self.title(controller: firstController)
        }
        
        navigationBar?.topItem?.leftBarButtonItem = nil
        self.navigationBar = navigationBar
    }
    
    func bind(scrollView: UIScrollView!) {
        self.configureContent(scrollView: scrollView)
        scrollView.delegate = self
        self.contentScrollView = scrollView
        self.applyStyle()
    }
    
}

extension SlideContentPresenter: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentXOffset = scrollView.contentOffset.x
        let pageWidth = scrollView.frame.size.width
        let pagePercentage = contentXOffset / pageWidth
        let pageIndex = Int(ceil(pagePercentage))
        self.insertContentViewIfNeeded(index: pageIndex)
        self.updateContentVisibility()
        self.slidingTitleView?.higlight(index: pagePercentage)
    }
    
}

extension SlideContentPresenter: SlidingNavigationDelegate {
    
    func didTapOn(title: String, from: SlidingNavigationTitleView) {
        guard let index = self.contentTitles.index(of: title) else {
            return
        }
        
        guard index < self.contentViews.count else {
            return
        }
        
        let x = CGFloat(index) * self.contentScrollView.frame.size.width
        let offset = CGPoint(x: x, y: 0.0)
        self.contentScrollView.setContentOffset(offset, animated: true)
    }
    
}
