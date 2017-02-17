//
//  GenderSelectorPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 2/15/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit

@objc protocol GenderUpdateDelegate: class {
    
    /**
        Notifies delegate that the selection has been made
     
        - Parameter account: the account that was initialized with, updated
        - Parameter presenter: instance of the presenter calling this method
    */
    func didUpdate(account: SENAccount, from presenter: GenderSelectorPresenter)
    
    /**
        Notifies delegate that no selection has been made
        
        - Parameter presenter: instance of the presenter calling this method
    */
    func didSkip(from presenter: GenderSelectorPresenter)
    
}

@objc class GenderSelectorPresenter: HEMPresenter {
    
    fileprivate let account: SENAccount!
    fileprivate var titleLabel: UILabel?
    fileprivate var descriptionLabel: UILabel?
    fileprivate var optionsTable: UITableView?
    fileprivate var skipButton: UIButton?
    fileprivate var nextButton: UIButton?
    
    var updateDelegate: GenderUpdateDelegate?
    
    init(account: SENAccount!) {
        self.account = account
        super.init()
    }
    
    //MARK: - Bindings
    
    @objc func bind(titleLabel: UILabel?) {
        titleLabel?.text = NSLocalizedString("onboarding.gender.title",
                                             comment: "gender confirmation")
        self.titleLabel = titleLabel
    }
    
    @objc func bind(descriptionLabel: UILabel?) {
        descriptionLabel?.text = NSLocalizedString("onboarding.gender.description",
                                                   comment: "why we need gender")
        self.descriptionLabel = descriptionLabel
    }
    
    @objc func bind(optionsTable: UITableView?) {
        optionsTable?.delegate = self
        optionsTable?.dataSource = self
        optionsTable?.tableFooterView = UIView()
        self.optionsTable = optionsTable
    }
    
    @objc func bind(skipButton: UIButton?) {
        skipButton?.addTarget(self,
                              action: #selector(GenderSelectorPresenter.skip),
                              for: UIControlEvents.touchUpInside)
        self.skipButton = skipButton
    }
    
    @objc func bind(nextButton: UIButton?) {
        nextButton?.addTarget(self,
                              action: #selector(GenderSelectorPresenter.done),
                              for: UIControlEvents.touchUpInside)
        self.nextButton = nextButton
    }
    
    //MARK: - Actions
    
    @objc fileprivate func skip() {
        self.updateDelegate?.didSkip(from: self)
    }
    
    @objc fileprivate func done() {
        self.updateDelegate?.didUpdate(account: self.account, from: self)
    }
    
    //MARK: Clean up
    deinit {
        self.optionsTable?.delegate = nil
        self.optionsTable?.dataSource = nil
    }
}

extension GenderSelectorPresenter: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate static let rowCount = 3
    fileprivate static let rowSize = CGFloat(56)
    
    enum Row: Int {
        case male = 0
        case female
        case other
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GenderSelectorPresenter.rowCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GenderSelectorPresenter.rowSize
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = HEMOnboardingStoryboard.genderReuseIdentifier()!
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        var title: String? = nil
        var icon: UIImage? = nil
        let customCell = cell as? HEMBasicTableViewCell
        let row = Row(rawValue: indexPath.row)!
        switch row {
            case .male:
                icon = UIImage(named: "male")
                title = NSLocalizedString("account.gender.male", comment: "male")
            case .female:
                icon = UIImage(named: "female")
                title = NSLocalizedString("account.gender.female", comment: "male")
            case .other:
                icon = UIImage(named: "addIcon")
                title = NSLocalizedString("account.gender.other", comment: "other")
        }
        icon = icon?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        customCell?.customTitleLabel.font = UIFont.body()
        customCell?.customTitleLabel.textColor = UIColor.grey6()
        customCell?.customTitleLabel.text = title
        customCell?.remoteImageView.image = icon
        customCell?.remoteImageView.tintColor = UIColor.tint()
    }
    
}
