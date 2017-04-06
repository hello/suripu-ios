//
//  NightModeSettingsPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 3/7/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import Solar
import SenseKit

class NightModeSettingsPresenter: HEMListPresenter {
    
    fileprivate weak var nightModeService: NightModeService!
    fileprivate weak var locationService: HEMLocationService!
    fileprivate var footer: UIView?
    fileprivate var waitingOnPermission: Bool
    fileprivate weak var transitionView: UIView?
    
    init(nightModeService: NightModeService, locationService: HEMLocationService) {
        let optionsTitle = NSLocalizedString("settings.night-mode.options.title", comment: "table options title")
        let selectedOption = nightModeService.savedOption()
        let items = NightModeService.Option.all().map{ $0.localizedDescription() }
        self.nightModeService = nightModeService
        self.locationService = locationService
        self.waitingOnPermission = false
        super.init(title: optionsTitle,
                   items: items,
                   selectedItemNames: [selectedOption.localizedDescription()])
    }
    
    override func bind(with tableView: UITableView, bottomConstraint: NSLayoutConstraint) {
        super.bind(with: tableView, bottomConstraint: bottomConstraint)
        self.footer = self.locationFooter()
    }
    
    override func bind(with navItem: UINavigationItem) {
        super.bind(with: navItem)
        navItem.title = NSLocalizedString("settings.night-mode", comment: "night mode")
    }
    
    // MARK: - Presenter events
    
    override func didChange(_ theme: Theme, auto automatically: Bool) {
        super.didChange(theme, auto: automatically)
        self.footer = self.locationFooter() // recreate it
        self.tableView?.reloadData()
    }
    
    override func didComeBackFromBackground() {
        super.didComeBackFromBackground()
        if (self.waitingOnPermission == false) {
            self.tableView?.reloadData()
        }
    }
    
    //MARK: - Footer
    
    fileprivate func locationFooter() -> UIView {
        let font = SenseStyle.font(group: .settingsFooter, property: .textFont)
        let color = SenseStyle.color(group: .settingsFooter, property: .textColor)
        let linkColor = SenseStyle.color(group: .settingsFooter, property: .linkColor)
        let attributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : color]
        let textFormat = NSLocalizedString("settings.night-mode.no-location.message.format", comment: "message format")
        
        let linkText = NSLocalizedString("settings.night-mode.location.service", comment: "location service")
        let attributedLink = NSAttributedString(string: linkText).hyperlink(UIApplicationOpenSettingsURLString)!
        let text = NSMutableAttributedString(format: textFormat, args: [attributedLink], attributes: attributes)
        let textView = UITextView()
        textView.attributedText = text
        textView.isEditable = false
        textView.linkTextAttributes = [NSForegroundColorAttributeName : linkColor, NSFontAttributeName : font]
        textView.isScrollEnabled = false
        textView.backgroundColor = self.tableView!.backgroundColor
        
        let footer = UIView()
        footer.addSubview(textView)
        footer.isHidden = self.locationService.hasDeniedPermission() == false
        
        return footer
    }
    
    //MARK: - List Presenter configuration
    
    override func heightForFooter(inSection section: Int) -> CGFloat {
        guard let textView = self.footer?.subviews.first as? UITextView else {
            return 0.0
        }
        
        let horzMargins = CGFloat(24)
        let origin = CGPoint(x: horzMargins, y: 0.0)
        let maxWidth = self.tableView!.bounds.size.width - (2*horzMargins)
        var size = CGSize(width: maxWidth, height: CGFloat(MAXFLOAT))
        size.height = textView.sizeThatFits(size).height
        textView.frame = CGRect(origin: origin, size: size)
        return textView.sizeThatFits(size).height
    }
    
    override func viewForFooter(inSection section: Int) -> UIView? {
        return self.footer
    }
    
    override func detail(forItem item: Any) -> String? {
        guard let description = item as? String else {
            return nil
        }
        
        let option = NightModeService.Option.fromDescription(description: description)!
        switch option {
            case .sunsetToSunrise:
                return NSLocalizedString("settings.night-mode.option.scheduled.description",
                                         comment: "sunset to sunrise description")
            default:
                return nil
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
        
        let description = item as! String
        let option = NightModeService.Option.fromDescription(description: description)
        let selectedOption = self.nightModeService.savedOption()
        cell.itemLabel?.text = option?.localizedDescription()
        cell.isSelected = selectedOption == option
        cell.descriptionLabel?.text = self.detail(forItem: item)
        
        if option == .sunsetToSunrise {
            self.footer?.isHidden = self.locationService.hasDeniedPermission() == false
            cell.enable(self.footer?.isHidden == true)
        } else {
            cell.enable(true)
        }
    }
    
    override func didNotifyDelegateOfSelection() {
        super.didNotifyDelegateOfSelection()
        
        let selectedName = self.selectedItemNames?.last as? String ?? ""
        guard let option = NightModeService.Option.fromDescription(description: selectedName) else {
            return
        }
        
        // snapshot the screen
        if self.activityContainerView != nil {
            if let snapshot = self.activityContainerView!.snapshotView(afterScreenUpdates: false) {
                snapshot.frame = self.activityContainerView!.bounds
                self.activityContainerView!.addSubview(snapshot)
                self.transitionView = snapshot
            }
        }
        
        switch option {
            case .sunsetToSunrise:
                if self.locationService.requiresPermission() == true {
                    self.waitingOnPermission = true
                    self.requestLocationPermission()
                } else {
                    self.scheduleNightModeFromLocation()
                }
            case .alwaysOn:
                SENAnalytics.trackNightModeChange(withSetting: kHEMAnalyticsPropNightModeValueOn)
                self.nightModeService.save(option: option)
                self.removeTransitionView(animate: true)
            case .off:
                SENAnalytics.trackNightModeChange(withSetting: kHEMAnalyticsPropNightModeValueOff)
                self.nightModeService.save(option: option)
                self.removeTransitionView(animate: true)
        }

    }
    
    fileprivate func requestLocationPermission() {
        self.locationService.requestPermission({ (status: HEMLocationAuthStatus) in
            self.waitingOnPermission = false
            switch status {
            case .notEnabled:
                fallthrough
            case .denied:
                self.revertSelection(error: nil)
            default:
                self.scheduleNightModeFromLocation()
            }
        })
    }
    
    fileprivate func revertSelection(error: Error?) {
        let savedOption = self.nightModeService.savedOption()
        self.selectedItemNames = [savedOption.localizedDescription()]
        self.tableView?.reloadData() // to disable the schedule cell
        
        if error != nil {
            self.removeTransitionView(animate: false)
            // show error
            let title = NSLocalizedString("settings.night-mode", comment: "title, same as screen title")
            let message = NSLocalizedString("settings.night-mode.error.no-location", comment: "no location error")
            self.presenterDelegate?.presentError(withTitle: title, message: message, from: self)
        } else {
            self.removeTransitionView(animate: true)
        }
    }
    
    fileprivate func removeTransitionView(animate: Bool) {
        guard let view = self.transitionView else {
            SENAnalytics.trackWarning(withMessage: "snapshot already removed in night mode settings")
            return
        }
        
        guard animate == true else {
            SENAnalytics.trackWarning(withMessage: "animation disabled when removing snapshot in night mode settings")
            view.removeFromSuperview()
            return
        }
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .beginFromCurrentState, animations: {
            view.alpha = 0.0
        }) { (finished: Bool) in
            view.removeFromSuperview()
        }
    }
    
    fileprivate func scheduleNightModeFromLocation() {
        var scheduled = false
        let service = self.locationService
        let error = service?.quickLocation({[weak self] (loc: HEMLocation?, err: Error?) in
            // to ensure only 1 location is used and to not call it too many times
            guard scheduled == false else {
                return
            }

            scheduled = true
            
            if loc != nil {
                SENAnalytics.trackNightModeChange(withSetting: kHEMAnalyticsPropNightModeValueAuto)
                self?.nightModeService.scheduleForSunset(latitude: Double(loc!.lat), longitude: Double(loc!.lon))
                self?.removeTransitionView(animate: true)
            } else if err != nil {
                self?.revertSelection(error: err)
            } else {
                SENAnalytics.trackWarning(withMessage: "could not determine location to schedule night mode")
                self?.revertSelection(error: nil)
            }
            
        })
        
        if error != nil {
            self.revertSelection(error: error)
        }
    }
    
}
