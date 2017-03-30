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
        
        switch option {
            case .sunsetToSunrise:
                if self.locationService.requiresPermission() == true {
                    self.waitingOnPermission = true
                    self.locationService.requestPermission({ (status: HEMLocationAuthStatus) in
                        self.waitingOnPermission = false
                        switch status {
                        case .notEnabled:
                            fallthrough
                        case .denied:
                            let off = NightModeService.Option.off
                            self.selectedItemNames = [off.localizedDescription()]
                            self.tableView?.reloadData() // to disable the schedule cell
                        default:
                            self.scheduleNightModeFromLocation()
                        }
                    })
                } else {
                    self.scheduleNightModeFromLocation()
                }
            default:
                self.nightModeService.save(option: option)
        }
    }
    
    fileprivate func showLocationError() {
        // TODO: throw an alert
    }
    
    fileprivate func scheduleNightModeFromLocation() {
        var scheduled = false
        let service = self.locationService
        let error = service?.quickLocation({[weak self] (loc: HEMLocation?, err: Error?) in
            guard scheduled == false else {
                return
            }
            
            scheduled = true
            
            if loc != nil {
                self?.nightModeService.scheduleForSunset(latitude: Double(loc!.lat),
                                                         longitude: Double(loc!.lon))
            } else {
                self?.showLocationError()
            }
            
        })
        
        if error != nil {
            self.showLocationError()
        }
    }
    
}
