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
    fileprivate var locationActivity: HEMLocationActivity?
    
    init(nightModeService: NightModeService, locationService: HEMLocationService) {
        let optionsTitle = NSLocalizedString("settings.night-mode.options.title", comment: "table options title")
        let selectedOption = nightModeService.savedOption()
        let items = NightModeService.Option.all().map{ $0.localizedDescription() }
        self.nightModeService = nightModeService
        self.locationService = locationService
        super.init(title: optionsTitle, items: items, selectedItemNames: [selectedOption.localizedDescription()])
    }
    
    override func bind(with navItem: UINavigationItem) {
        super.bind(with: navItem)
        navItem.title = NSLocalizedString("settings.night-mode", comment: "night mode")
    }
    
    //MARK: List Presenter configuration
    
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
        let disableCell = option == .sunsetToSunrise && self.locationService.hasDeniedPermission()
        cell.itemLabel?.text = option?.localizedDescription()
        cell.isSelected = selectedOption == option
        cell.descriptionLabel?.text = self.detail(forItem: item)
        cell.enable(disableCell == false)
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
                    self.locationService.requestPermission({ (status: HEMLocationAuthStatus) in
                        switch status {
                        case .notEnabled:
                            fallthrough
                        case .denied:
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
    
    fileprivate func off() {
        let offOption = NightModeService.Option.off
        let index = self.indexOfItem(withName: offOption.localizedDescription())
        let path = IndexPath(item: index, section: 0)
        self.tableView?.selectRow(at: path, animated: true, scrollPosition: UITableViewScrollPosition.top)
    }
    
    fileprivate func failScheduling() {
        self.off()
        
        // show some alert
        
        if self.locationActivity != nil {
            self.locationService.stop(self.locationActivity!)
        }
    }
    
    fileprivate func failScheduling(errorMessage: String) {
        self.failScheduling()
        SENAnalytics.trackWarning(withMessage: errorMessage)
    }
    
    fileprivate func failScheduling(error: Error) {
        self.failScheduling()
        SENAnalytics.trackError(error)
    }
    
    fileprivate func scheduleNightModeFromLocation() {
        do  {
            try self.locationActivity = self.locationService.startLocationActivity({[weak self] (location: HEMLocation?, error: Error?) in
                if location != nil {
                    self?.nightModeService.scheduleForSunset(latitude: Double(location!.lat),
                                                             longitude: Double(location!.lon))
                    if self?.locationActivity != nil {
                        self?.locationService.stop((self?.locationActivity!)!)
                    }
                } else if error != nil {
                    self?.failScheduling()
                } else {
                    self?.failScheduling(errorMessage: "no location was determined!")
                }
            })
        } catch _ {
            // called if an error occurred trying to start the location service
            if self.locationActivity != nil {
                self.locationService.stop(self.locationActivity!)
            }
            self.off()
            SENAnalytics.trackWarning(withMessage: "failed to determine location for night mode")
        }
    }
    
    deinit {
        if self.locationActivity != nil && self.locationService != nil {
            self.locationService.stop(self.locationActivity!)
        }
    }
    
}
