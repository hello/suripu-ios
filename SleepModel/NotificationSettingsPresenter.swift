//
//  NotificationSettingsPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 2/2/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit

@objc class NotificationSettingsPresenter: HEMPresenter {
    
    fileprivate enum Section: Int {
        case setting
        
        static func count() -> Int {
            return 1
        }
    }
    
    fileprivate weak var service: PushNotificationService!
    fileprivate weak var activityIndicator: HEMActivityIndicatorView!
    fileprivate weak var tableView: UITableView!
    fileprivate weak var navigationItem: UINavigationItem?
    fileprivate var settings: [SENNotificationSetting]?
    fileprivate var sleepReminderSetting: SENNotificationSetting?
    fileprivate var error: Error?
    fileprivate var warningHeader: WarningView?
    
    init(service: PushNotificationService!) {
        super.init()
        self.service = service
    }
    
    func bind(activityIndicator: HEMActivityIndicatorView!) {
        self.activityIndicator = activityIndicator
        self.activityIndicator.start()
        self.activityIndicator.isHidden = false
        self.activityIndicator.isUserInteractionEnabled = false
    }
    
    func bind(tableView: UITableView!) {
        tableView.tableFooterView = HEMSettingsHeaderFooterView(topBorder: false, bottomBorder: false)
        tableView.isHidden = true // hide first, then show after settings loaded
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        self.warningHeader = tableView.tableHeaderView as? WarningView
        self.load()
    }
    
    func bind(navigationItem: UINavigationItem?) {
        let action = #selector(NotificationSettingsPresenter.save)
        let saveButton = UIBarButtonItem.saveButton(withTarget: self, action: action)
        saveButton.isEnabled = false
        navigationItem?.rightBarButtonItem = saveButton
        self.navigationItem = navigationItem
    }
    
    // MARK: Presenter overrides
    
    override func didComeBackFromBackground() {
        super.didComeBackFromBackground()
        self.reloadUI()
    }
    
    // MARK:
    
    fileprivate func load() {
        if  self.settings?.count == 0 {
            self.activityIndicator.start()
            self.activityIndicator.isHidden = false
        }
        
        self.service.getSettings { [weak self] (settings: [SENNotificationSetting]?, error: Error?) in
            self?.settings = self?.filterSettings(settings: settings)
            self?.error = error
            self?.reloadUI()
        }
    }
    
    fileprivate func filterSettings(settings: [SENNotificationSetting]?) -> [SENNotificationSetting]? {
        return settings?.filter({ (setting: SENNotificationSetting) -> Bool in
            switch setting.type {
            case .sleepReminder:
                self.sleepReminderSetting = setting
                return false
            default:
                return true
            }
        })
    }
    
    fileprivate func reloadUI() {
        self.reloadTableHeader()
        self.activityIndicator?.isHidden = true
        self.activityIndicator?.stop()
        self.tableView?.isHidden = false
        self.tableView?.reloadData()
    }
    
    fileprivate func attributedWarningMessage() -> NSAttributedString {
        let message = NSLocalizedString("settings.notification.warning.message.not-enabled",
                                        comment: "enable notification message")
        let attributes: [String: Any] = [NSFontAttributeName : UIFont.body(),
                                         NSForegroundColorAttributeName : UIColor.grey5(),
                                         NSParagraphStyleAttributeName: DefaultBodyParagraphStyle()]
        return NSAttributedString(string: message, attributes: attributes)
    }
    
    fileprivate func reloadTableHeader() {
        if UIApplication.shared.canSendNotifications() {
            self.tableView.tableHeaderView = HEMSettingsHeaderFooterView(topBorder: false, bottomBorder: false)
        } else if let warningView = self.warningHeader {
            // update the custom table warning header view
            warningView.titleLabel?.text = NSLocalizedString("settings.notification.warning.title.not-enabled",
                                                             comment: "title for warning")
            warningView.messageLabel?.attributedText = self.attributedWarningMessage()
            warningView.actionButton?.setTitle(NSLocalizedString("settings.notification.warning.button.enable",
                                                                 comment: "enable notification button title"),
                                               for: UIControlState.normal)
            warningView.actionButton?.addTarget(self,
                                                action: #selector(NotificationSettingsPresenter.setPermission),
                                                for: UIControlEvents.touchUpInside)
            warningView.frame.size = warningView.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
            
            self.tableView?.tableHeaderView = warningView // adjust size
        }
    }
    
    fileprivate func title(indexPath: NSIndexPath) -> String? {
        guard let section = Section.init(rawValue: indexPath.section) else {
            return nil
        }
        
        switch section {
            case .setting:
                return self.settings?[indexPath.row].localizedName
        }
    }
    
    // MARK: - Actions
    
    func setPermission() {
        let app = UIApplication.shared
        app.askForPermissionToSendPushNotifications(goToSettingsIfDenied: true)
    }
    
    @objc fileprivate func toggle(enableSwitch: UISwitch) {
        guard let setting = self.settings?[enableSwitch.tag] else {
            return
        }
        self.navigationItem?.rightBarButtonItem?.isEnabled = true
        setting.isEnabled = enableSwitch.isOn
    }
    
    @objc fileprivate func save() {
        // do something
        let container = self.activityDelegate?.activityContainer(from: self)
        let activityView = HEMActivityCoverView()
        let statusMessage = NSLocalizedString("activity.saving.changes", comment: "message to show with activity")
        
        activityView.show(in: container, withText: statusMessage, activity: true, completion: { [weak self] () in
            self?.service.updateSettings(settings: self?.settings, completion: { [weak self] (error: Error?) in
                var message: String?
                let success = error == nil
                
                if success == true {
                    message = NSLocalizedString("actions.saved", comment: "message shown when saved")
                    self?.navigationItem?.rightBarButtonItem?.isEnabled = false
                }
                
                activityView.dismiss(withResultText: message, showSuccessMark: success, remove: true, completion: { [weak self] () in
                    if error != nil {
                        self?.showSaveError()
                    }
                })
            })
        })
    }
    
    fileprivate func showSaveError() {
        let title = NSLocalizedString("settings.notification.error.title", comment: "title in error dialog")
        let message = NSLocalizedString("settings.notification.error.update-failed-message", comment: "error message")
        self.errorDelegate?.showError(withTitle: title, andMessage: message, withHelpPage: nil, from: self)
    }
    
    // MARK: - Clean up
    
    deinit {
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
    }
}

extension NotificationSettingsPresenter: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = Section.init(rawValue: section) else {
            return 0
        }
        
        switch type {
            case .setting:
                return self.settings?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = HEMSettingsStoryboard.preferenceReuseIdentifier()
        return tableView.dequeueReusableCell(withIdentifier: identifier!, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let section = Section.init(rawValue: indexPath.section) else {
            return
        }
        
        guard section == Section.setting else {
            return
        }
        
        guard let setting = self.settings?[indexPath.row] else {
            return
        }
        
        let enableSwitch = UISwitch()
        enableSwitch.isOn = setting.isEnabled
        enableSwitch.tag = indexPath.row
        enableSwitch.onTintColor = UIColor.tint()
        enableSwitch.addTarget(self,
                               action: #selector(NotificationSettingsPresenter.toggle(enableSwitch:)),
                               for: UIControlEvents.valueChanged)
        
        cell.backgroundColor = UIColor.white
        cell.accessoryView = enableSwitch
        cell.textLabel?.text = setting.localizedName
        cell.textLabel?.textColor = UIColor.grey6()
        cell.textLabel?.font = UIFont.body()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        self.shadowView?.updateVisibility(withContentOffset: offset)
    }
    
}
