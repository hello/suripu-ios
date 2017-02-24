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
    
    fileprivate weak var onboardingService: HEMOnboardingService!
    fileprivate weak var account: SENAccount?
    fileprivate var cancelItem: UIBarButtonItem?
    fileprivate var searchItem: UIBarButtonItem?
    fileprivate var searchBarItem: UIBarButtonItem?
    fileprivate var cancelSearchItem: UIBarButtonItem?
    
    init(onboardingService: HEMOnboardingService!, account: SENAccount?) {
        self.onboardingService = onboardingService
        self.account = account
        let selectedGender = account?.customGender
        let selectedOptions = selectedGender != nil ? [selectedGender] : nil
        let title = NSLocalizedString("onboarding.gender.title", comment: "table title")
        super.init(title: title, items: [], selectedItemNames: selectedOptions)
    }
    
    fileprivate func load() {
        self.indicatorView?.start()
        self.indicatorView?.isHidden = false
        
        self.onboardingService.otherGenderOptions { [weak self] (options: [String]?) in
            self?.indicatorView?.stop()
            self?.indicatorView?.isHidden = true
            self?.items = options
            self?.tableView?.reloadData()
        }
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
        let backImage = UIImage(named: "backIcon")
        var searchImage = UIImage(named: "iconSearch")
        searchImage = searchImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let cancelAction = #selector(OtherGenderOptionsPresenter.cancel)
        let searchAction = #selector(OtherGenderOptionsPresenter.search)
        
        self.cancelItem = UIBarButtonItem.cancel(withTitle: nil, image: backImage, target: self, action: cancelAction)
        self.searchItem = UIBarButtonItem(image: searchImage, style: UIBarButtonItemStyle.plain, target: self, action: searchAction)
        
        navItem.title = NSLocalizedString("onboarding.other.gender.title", comment: "navigation title")
        navItem.leftBarButtonItem = self.cancelItem
        navItem.rightBarButtonItem = self.searchItem
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
        cell.itemLabel.text = text
        
        let currentSelection = self.account?.customGender ?? ""
        cell.isSelected = currentSelection == text
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
    
    @objc fileprivate func search() {
        if self.cancelSearchItem == nil {
            let cancel = NSLocalizedString("actions.cancel", comment: "cancel search text")
            let cancelSearch = #selector(OtherGenderOptionsPresenter.cancelSearch)
            self.cancelSearchItem = UIBarButtonItem.cancel(withTitle: cancel,
                                                           image: nil,
                                                           target: self,
                                                           action: cancelSearch)
        }

        let searchBar = UISearchBar()
        self.mainNavItem?.titleView = searchBar
        self.mainNavItem?.setLeftBarButton(nil, animated: true)
        self.mainNavItem?.setRightBarButton(self.cancelSearchItem, animated: true)
        searchBar.becomeFirstResponder()
    }
    
    @objc fileprivate func cancelSearch() {
        self.mainNavItem?.titleView = nil
        self.mainNavItem?.setLeftBarButton(self.cancelItem, animated: true)
        self.mainNavItem?.setRightBarButton(self.searchItem, animated: true)
    }
    
    //MARK: - Clean up
    deinit {
        self.stopListeningForKeyboardEvents()
    }
}

// Extension to handle keyboard events
extension OtherGenderOptionsPresenter {
    
    fileprivate func listenForKeyboardEvents() {
        let center = NotificationCenter.default
        let showAction = #selector(OtherGenderOptionsPresenter.keyboard(willShow:))
        let showName = NSNotification.Name.UIKeyboardWillShow
        let hideName = NSNotification.Name.UIKeyboardWillHide
        center.addObserver(self, selector: showAction, name: showName, object: nil)
        center.addObserver(self, selector: showAction, name: hideName, object: nil)
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
        let duration = info[UIKeyboardAnimationDurationUserInfoKey]
        let rawCurve = info[UIKeyboardAnimationCurveUserInfoKey]
        let frame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let height = frame.size.height
        
    }
    
    
}
