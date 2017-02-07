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
        case sleepReminder
        
        static func count() -> Int {
            return 3
        }
    }
    
    fileprivate weak var service: PushNotificationService!
    fileprivate weak var activityIndicator: HEMActivityIndicatorView!
    fileprivate weak var tableView: UITableView!
    fileprivate var settings: [SENNotificationSetting]?
    fileprivate var sleepReminderSetting: SENNotificationSetting?
    fileprivate var error: Error?
    
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
        self.load()
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
        } else if let warningView = self.tableView.tableHeaderView as? WarningView {
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
            case .sleepReminder:
                return self.sleepReminderSetting?.localizedName
        }
    }
    
    func setPermission() {
        guard UIApplication.shared.hasDeniedNotificationPermission() == false else {
            let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
            let _ = UIApplication.shared.openURL(settingsURL)
            return
        }
        UIApplication.shared.askForPermissionToSendPushNotifications()
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
            case .sleepReminder:
                return self.sleepReminderSetting != nil ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEMSettingsHeaderFooterHeightWithTitle
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = HEMSettingsStoryboard.preferenceReuseIdentifier()
        return tableView.dequeueReusableCell(withIdentifier: identifier!, for: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        self.shadowView?.updateVisibility(withContentOffset: offset)
    }
    
}
