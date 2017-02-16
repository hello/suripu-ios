//
//  GenderSelectorPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 2/15/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit

@objc class GenderSelectorPresenter: HEMPresenter {
    
    fileprivate let account: SENAccount!
    fileprivate var titleLabel: UILabel?
    fileprivate var descriptionLabel: UILabel?
    fileprivate var optionsTable: UITableView?
    fileprivate var skipButton: UIButton?
    fileprivate var nextButton: UIButton?
    
    init(account: SENAccount!) {
        self.account = account
        super.init()
    }
    
    @objc func bind(titleLabel: UILabel?) {
        titleLabel?.text = NSLocalizedString("onboarding.gender.title", comment: "gender confirmation")
        self.titleLabel = titleLabel
    }
    
    @objc func bind(descriptionLabel: UILabel?) {
        descriptionLabel?.text = NSLocalizedString("onboarding.gender.description", comment: "why we need gender")
        self.descriptionLabel = descriptionLabel
    }
    
    @objc func bind(optionsTable: UITableView?) {
        self.optionsTable = optionsTable
    }
    
    @objc func bind(skipButton: UIButton?) {
        self.skipButton = skipButton
    }
    
    @objc func bind(nextButton: UIButton?) {
        self.nextButton = nextButton
    }
    
}

extension GenderSelectorPresenter: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate static let rowCount = 3
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GenderSelectorPresenter.rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return nil
    }
    
}
