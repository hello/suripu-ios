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
    fileprivate weak var titleLabel: UILabel?
    fileprivate weak var descriptionLabel: UILabel?
    fileprivate weak var optionsTable: UITableView?
    fileprivate weak var skipButton: UIButton?
    fileprivate weak var nextButton: UIButton?
    fileprivate weak var onboardingService: HEMOnboardingService!
    
    fileprivate var selectedGender: SENAccountGender?
    var updateDelegate: GenderUpdateDelegate?
    
    init(account: SENAccount!, onboardingService: HEMOnboardingService!) {
        self.account = account
        self.onboardingService = onboardingService
        if account.gender != SENAccountGender.other {
            self.selectedGender = account.gender
        }
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
        optionsTable?.separatorColor = UIColor.separator()
        self.optionsTable = optionsTable
    }
    
    @objc func bind(skipButton: UIButton?) {
        let stillOnboarding = self.onboardingService.hasFinishedOnboarding() == false
        let skipTitle = NSLocalizedString("actions.skip-for-now", comment: "skip")
        let cancelTitle = NSLocalizedString("actions.cancel", comment: "cancel")
        let title = stillOnboarding ? skipTitle : cancelTitle
        
        skipButton?.setTitleColor(UIColor.grey3(), for: UIControlState.disabled)
        skipButton?.titleLabel?.font = UIFont.button()
        skipButton?.setTitle(title, for: UIControlState.normal)
        skipButton?.addTarget(self,
                              action: #selector(GenderSelectorPresenter.skip),
                              for: UIControlEvents.touchUpInside)
        
        self.skipButton = skipButton
    }
    
    @objc func bind(nextButton: UIButton?) {
        let nextTitle = NSLocalizedString("actions.next", comment: "next")
        let doneTitle = NSLocalizedString("actions.done", comment: "done")
        let stillOnboarding = self.onboardingService.hasFinishedOnboarding() == false
        let title = stillOnboarding ? nextTitle : doneTitle
        
        nextButton?.setTitle(title.uppercased(), for: UIControlState.normal)
        nextButton?.isEnabled = false
        nextButton?.addTarget(self,
                              action: #selector(GenderSelectorPresenter.done),
                              for: UIControlEvents.touchUpInside)
        self.nextButton = nextButton
    }
    
    @objc func isSelected(indexPath: IndexPath) -> Bool {
        let row = Row(rawValue: indexPath.row)!
        switch row {
            case .female :
                return self.selectedGender == SENAccountGender.female
            case .male:
                return self.selectedGender == SENAccountGender.male
            case .other:
                return self.selectedGender == SENAccountGender.other
        }
    }
    
    //MARK: - Actions
    
    @objc fileprivate func skip() {
        self.updateDelegate?.didSkip(from: self)
    }
    
    @objc fileprivate func done() {
        if self.selectedGender != nil {
            self.account.gender = self.selectedGender!
        }
        self.nextButton?.isEnabled = false
        self.skipButton?.isEnabled = false
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
        let customCell = cell as? HEMBasicTableViewCell
        let accessoryImageView = customCell?.customAccessoryView as? UIImageView
        let selected = self.isSelected(indexPath: indexPath)
        var radio = selected ? UIImage(named: "radioSelected") : UIImage(named: "radio")
        let selectionTint = selected ? UIColor.tint() : UIColor.grey2()
        var title: String? = nil
        var icon: UIImage? = nil
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
        
        radio = radio?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        icon = icon?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        customCell?.customTitleLabel.font = UIFont.body()
        customCell?.customTitleLabel.textColor = UIColor.grey6()
        customCell?.customTitleLabel.text = title
        customCell?.remoteImageView.image = icon
        customCell?.remoteImageView.tintColor = UIColor.tint()
        customCell?.selectionStyle = UITableViewCellSelectionStyle.none
        accessoryImageView?.image = radio
        accessoryImageView?.tintColor = selectionTint
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = Row(rawValue: indexPath.row)!
        switch row {
            case .female:
                self.selectedGender = SENAccountGender.female
            case .male:
                self.selectedGender = SENAccountGender.male
            case .other:
                self.selectedGender = SENAccountGender.other
        }
        self.nextButton?.isEnabled = true
        tableView.reloadData()
    }
    
}
