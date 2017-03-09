//
//  NightModeSettingsPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 3/7/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit

class NightModeSettingsPresenter: HEMListPresenter {
    
    fileprivate weak var nightModeService: NightModeService!
    
    init(nightModeService: NightModeService) {
        let optionsTitle = NSLocalizedString("settings.night-mode.options.title", comment: "table options title")
        let selectedOption = nightModeService.savedOption()
        let items = NightModeService.Option.all().map{ $0.localizedDescription() }
        self.nightModeService = nightModeService
        super.init(title: optionsTitle, items: items, selectedItemNames: [selectedOption.localizedDescription()])
    }
    
    override func bind(with navItem: UINavigationItem) {
        super.bind(with: navItem)
        navItem.title = NSLocalizedString("settings.night-mode", comment: "night mode")
    }
    
    //MARK: List Presenter configuration
    
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
        cell.itemLabel.text = option?.localizedDescription()
        cell.isSelected = selectedOption == option
    }
    
    override func willNotifyDelegateOfSelection() {
        super.willNotifyDelegateOfSelection()
        let selectedName = self.selectedItemNames?.last as? String ?? ""
        guard let option = NightModeService.Option.fromDescription(description: selectedName) else {
            return
        }
        self.nightModeService.save(option: option)
    }
    
}
