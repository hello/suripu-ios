//
//  OtherGenderOptionsPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 2/21/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit

class OtherGenderOptionsPresenter: HEMListPresenter {
    
    static fileprivate let animationDuration = 0.3
    fileprivate weak var onboardingService: HEMOnboardingService!
    fileprivate weak var account: SENAccount?
    fileprivate var cancelItem: UIBarButtonItem?
    fileprivate var searchItem: UIBarButtonItem?
    fileprivate var searchBar: UISearchBar?
    fileprivate var cancelSearchItem: UIBarButtonItem?
    fileprivate var allOptions: [String]?
    fileprivate var searchTransitionView: UIView?
    fileprivate var originSearchIconFrame: CGRect?
    
    init(onboardingService: HEMOnboardingService!, account: SENAccount?) {
        self.onboardingService = onboardingService
        self.account = account
        let selectedGender = account?.customGender
        let selectedOptions = selectedGender != nil ? [selectedGender] : nil
        let title = NSLocalizedString("onboarding.gender.title", comment: "table title")
        super.init(title: title, items: [], selectedItemNames: selectedOptions)
    }
    
    override func bind(withDefaultNavigationBar navigationBar: UINavigationBar) {
        super.bind(withDefaultNavigationBar: navigationBar)
        navigationBar.shadowImage = nil
    }
    
    override func bind(with tableView: UITableView, bottomConstraint: NSLayoutConstraint) {
        super.bind(with: tableView, bottomConstraint: bottomConstraint)
        self.load()
    }
    
    override func bind(with navItem: UINavigationItem) {
        super.bind(with: navItem)
        let backImage = SenseStyle.navigationBackImage()
        var searchImage = UIImage(named: "iconSearch")
        searchImage = searchImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        let cancelAction = #selector(OtherGenderOptionsPresenter.cancel)
        let searchAction = #selector(OtherGenderOptionsPresenter.showSearch)
        let searchButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: searchImage!.size))
        searchButton.setImage(searchImage, for: UIControlState.normal)
        searchButton.addTarget(self, action: searchAction, for: UIControlEvents.touchUpInside)
        
        self.cancelItem = UIBarButtonItem.cancel(withTitle: nil, image: backImage, target: self, action: cancelAction)
        self.searchItem = UIBarButtonItem(customView: searchButton)
        
        navItem.title = NSLocalizedString("onboarding.other.gender.title", comment: "navigation title")
        navItem.leftBarButtonItem = self.cancelItem
        navItem.rightBarButtonItem = self.searchItem
    }
    
    fileprivate func load() {
        self.indicatorView?.start()
        self.indicatorView?.isHidden = false
        
        self.onboardingService.otherGenderOptions { [weak self] (options: [String]?) in
            self?.indicatorView?.stop()
            self?.indicatorView?.isHidden = true
            self?.items = options
            self?.allOptions = options
            self?.tableView?.reloadData()
        }
    }
    
    override func indexOfItem(withName name: String) -> Int {
        guard let options = self.items as? [String] else {
            return NSNotFound
        }
        return options.index(of: name) ?? NSNotFound
    }

    override func configureCell(_ cell: HEMListItemCell, forItem item: Any) {
        super.configureCell(cell, forItem: item)
        
        let text = item as? String
        cell.itemLabel?.text = text
        
        let currentSelection = self.account?.customGender ?? ""
        cell.isSelected = currentSelection == text
    }
    
    override func willNotifyDelegateOfSelection() {
        super.willNotifyDelegateOfSelection()
        if self.searchBar?.isFirstResponder == true {
            self.searchBar?.resignFirstResponder()
        }
    }
    
    //MARK: - Actions
    
    @objc fileprivate func cancel() {
        guard let delegate = self.delegate else {
            return
        }
        
        guard delegate.responds(to: #selector(HEMListDelegate.goBack(from:))) else {
            return
        }
        
        delegate.goBack!(from: self)
    }
    
    @objc fileprivate func showSearch() {
        if self.cancelSearchItem == nil {
            let cancel = NSLocalizedString("actions.cancel", comment: "cancel search text")
            let cancelSearch = #selector(OtherGenderOptionsPresenter.cancelSearch)
            self.cancelSearchItem = UIBarButtonItem.cancel(withTitle: cancel,
                                                           image: nil,
                                                           target: self,
                                                           action: cancelSearch)
        }

        let searchButton = self.searchItem?.customView as? UIButton
        let searchIconView = searchButton!.imageView
        let searchIconFrame = searchIconView!.convert(searchIconView!.bounds, to: self.mainNavBar)
        let searchIcon = searchIconView?.image
        let transitionView = UIImageView(image: searchIcon)
        transitionView.frame = searchIconFrame
        
        self.listenForKeyboardEvents()
        self.searchBar = UISearchBar()
        self.searchBar!.setImage(searchIcon, for: UISearchBarIcon.search, state: UIControlState.normal)
        self.searchBar!.isHidden = true
        self.searchBar!.delegate = self
        
        self.mainNavBar?.addSubview(transitionView)
        self.mainNavItem?.setRightBarButton(nil, animated: false)
        self.searchTransitionView = transitionView
        self.originSearchIconFrame = searchIconFrame
        
        UIView.animate(withDuration: OtherGenderOptionsPresenter.animationDuration, animations: {
            let rightMaxX = searchIconFrame.origin.x + searchIconFrame.size.width
            let navBarWidth = self.mainNavBar?.frame.size.width ?? 0.0
            var leftFrame = CGRect(origin: CGPoint.zero, size: searchIconFrame.size)
            leftFrame.origin.y = searchIconFrame.origin.y
            leftFrame.origin.x = navBarWidth - rightMaxX
            transitionView.frame = leftFrame
        }) { (finished: Bool) in
            self.searchBar!.changeFieldColor(color: self.mainNavBar?.barTintColor,
                                             textColor: self.mainNavBar?.tintColor)
            self.searchBar!.isHidden = false
            self.searchTransitionView?.removeFromSuperview()
        }
        
        self.mainNavItem?.titleView = self.searchBar
        self.mainNavItem?.setLeftBarButton(nil, animated: false)
        self.mainNavItem?.setRightBarButton(self.cancelSearchItem, animated: true)
        self.searchBar!.becomeFirstResponder()
    }
    
    @objc fileprivate func cancelSearch() {
        func done() {
            self.items = self.allOptions
            self.tableView?.reloadData()
            self.mainNavItem?.titleView = nil
            self.mainNavItem?.setLeftBarButton(self.cancelItem, animated: false)
            self.mainNavItem?.setRightBarButton(self.searchItem, animated: false)
        }
        
        if self.searchTransitionView != nil && self.originSearchIconFrame != nil {
            self.mainNavBar?.addSubview(self.searchTransitionView!)
            self.searchBar?.resignFirstResponder()
            self.mainNavItem?.titleView?.isHidden = true
            self.mainNavItem?.setRightBarButton(nil, animated: false)
            
            UIView.animate(withDuration: OtherGenderOptionsPresenter.animationDuration, animations: {
                self.searchTransitionView!.frame = self.originSearchIconFrame!
            }, completion: { (finished: Bool) in
                done()
                self.searchTransitionView?.removeFromSuperview()
                self.searchTransitionView = nil
            })
        } else {
             done()
        }
        
        self.stopListeningForKeyboardEvents()
    }
    
    //MARK: - Clean up
    deinit {
        self.stopListeningForKeyboardEvents()
    }
}

extension OtherGenderOptionsPresenter: UISearchBarDelegate {

    fileprivate func search(input: String?) -> [String]? {
        guard self.allOptions?.count ?? 0 > 0 else {
            return self.allOptions
        }
        
        guard input != nil && input?.isEmpty == false else {
            return self.allOptions
        }
        
        return self.allOptions!.filter { (option: String) -> Bool in
            let lowerInput = input!.lowercased()
            return option.lowercased().range(of: lowerInput) != nil
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.items = self.search(input: searchText)
        self.tableView?.reloadData()
    }
    
}

// Extension to handle keyboard events
extension OtherGenderOptionsPresenter {
    
    fileprivate func listenForKeyboardEvents() {
        let center = NotificationCenter.default
        let showAction = #selector(OtherGenderOptionsPresenter.keyboard(willShow:))
        let hideAction = #selector(OtherGenderOptionsPresenter.keyboard(willHide:))
        let showName = NSNotification.Name.UIKeyboardWillShow
        let hideName = NSNotification.Name.UIKeyboardWillHide
        center.addObserver(self, selector: showAction, name: showName, object: nil)
        center.addObserver(self, selector: hideAction, name: hideName, object: nil)
    }
    
    fileprivate func stopListeningForKeyboardEvents() {
        let center = NotificationCenter.default
        let showName = NSNotification.Name.UIKeyboardWillShow
        let hideName = NSNotification.Name.UIKeyboardWillHide
        center.removeObserver(self, name: showName, object: nil)
        center.removeObserver(self, name: hideName, object: nil)
    }
    
    @objc fileprivate func keyboard(willShow notification: NSNotification) {
        let info = notification.userInfo!
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let rawCurve = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16
        let curve = UIViewAnimationOptions(rawValue: UInt(rawCurve))
        let frame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.tableViewBottomConstraint?.constant = frame.size.height
        self.tableView?.layoutIfNeeded()
        UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: curve, animations: {
            self.tableView?.superview?.layoutIfNeeded()
        }, completion:nil)
    }
    
    @objc fileprivate func keyboard(willHide notification: NSNotification) {
        self.tableViewBottomConstraint?.constant = 0.0
    }
    
    
}
