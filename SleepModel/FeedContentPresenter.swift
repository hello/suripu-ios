//
//  FeedContentPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 12/7/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation
import SenseKit

class FeedContentPresenter: SlideContentPresenter {
    
    weak var deviceService: HEMDeviceService!
    fileprivate var versionBeforeUpdate: SENSenseHardware
    
    init?(controllers: Array<UIViewController>, deviceService: HEMDeviceService) {
        guard controllers.count == 2 else {
            return nil
        }
        self.deviceService = deviceService
        self.versionBeforeUpdate = deviceService.savedHardwareVersion()
        super.init(controllers: controllers)
    }
    
    // MARK: - Presenter events
    
    override func didAppear() {
        super.didAppear()
        self.updateContentIfNeeded()
    }
    
    // MARK: - Configuration
    
    override func configureContent(scrollView: UIScrollView) {
        switch  self.versionBeforeUpdate {
            case SENSenseHardware.one:
                let controller = self.contentControllers.first!
                self.configureScrollView(scrollView: scrollView, with: controller)
                break
            case SENSenseHardware.unknown:
                let controller = self.contentControllers.first!
                self.configureScrollView(scrollView: scrollView, with: controller)
                self.updateContentAfterRefresh()
                break
            case SENSenseHardware.voice:
                fallthrough
            default:
                super.configureContent(scrollView: scrollView)
                break
        }
    }
    
    override func configureNavigationTitleView(size: CGSize)
        -> SlidingNavigationTitleView? {
        switch  self.versionBeforeUpdate {
            case SENSenseHardware.one:
                fallthrough
            case SENSenseHardware.unknown:
                return nil
            case SENSenseHardware.voice:
                fallthrough
            default:
                return super.configureNavigationTitleView(size: size)
        }
    }
    
    fileprivate func configureScrollView(scrollView: UIScrollView,
                                         with controller: UIViewController) {
        self.visibilityDelegate?.addController(controller: controller,
                                               from: self)
        self.contentViews.append(controller.view)
    }
    
    // MARK: - Content Updates based on hardware version
    
    fileprivate func requireUpdate(updatedVersion: SENSenseHardware?) -> Bool {
        guard let updatedVersion = updatedVersion else {
            return false
        }
        
        switch updatedVersion {
            case SENSenseHardware.one:
                fallthrough
            case SENSenseHardware.unknown:
                return self.versionBeforeUpdate == SENSenseHardware.voice
            case SENSenseHardware.voice:
                fallthrough
            default:
                return self.versionBeforeUpdate != SENSenseHardware.voice
        }
    }
    
    fileprivate func updateContentIfNeeded() {
        let version = self.deviceService.savedHardwareVersion()
        guard self.requireUpdate(updatedVersion: version) else {
            return
        }
        self.updateContentAfterRefresh()
    }
    
    fileprivate func updateContentAfterRefresh() {
        self.activity?.start()
        self.activity?.isHidden = false
        self.deviceService.refreshMetadata ({ [weak self] (_: Any?, error: Error?) in
            let updatedVersion = self?.deviceService.savedHardwareVersion()
            guard let _ = self?.requireUpdate(updatedVersion: updatedVersion) else {
                return
            }
            
            self?.versionBeforeUpdate = updatedVersion!
            
            if updatedVersion == SENSenseHardware.voice {
                self?.updateToIncludeSecondTab()
            } else {
                self?.updateToExcludeSecondTab()
            }
            
            self?.activity?.stop()
            self?.activity?.isHidden = true
        })
    }
    
    fileprivate func updateToIncludeSecondTab() {
        // update is needed so update title view and content of scrollview
        let titleSize = self.navigationBar?.frame.size
        if titleSize != nil {
            let updatedTitleView = self.configureNavigationTitleView(size: titleSize!)
            updatedTitleView?.delegate = self
            self.slidingTitleView = updatedTitleView
            self.navigationBar?.topItem?.titleView = updatedTitleView
        }
        // because of requireUpdate(), this means we need to add a new view
        let controllerToAdd = self.contentControllers.last
        self.visibilityDelegate?.addController(controller: controllerToAdd!, from: self)
        self.contentViews.append(controllerToAdd!.view)
        
        // update content size
        self.updateContentSize(modifier: 1)
    }
    
    fileprivate func updateToExcludeSecondTab() {
        // update title
        self.navigationBar?.topItem?.titleView = nil
        self.navigationBar?.topItem?.title = self.contentTitles.first
        
        // update controller visibility
        let controllerToRemove = self.contentControllers.last
        self.visibilityDelegate?.removeController(controller: controllerToRemove!,
                                                   from: self)
        self.contentViews.removeLast()

        // update content size
        self.updateContentSize(modifier: -1)
    }
    
    fileprivate func updateContentSize(modifier: Int) {
        let adjustedWidth = self.contentScrollView.frame.size.width
        var contentSize = self.contentScrollView.contentSize
        contentSize.width += (CGFloat(modifier) * adjustedWidth)
        self.contentScrollView.contentSize = contentSize
    }
    
}
