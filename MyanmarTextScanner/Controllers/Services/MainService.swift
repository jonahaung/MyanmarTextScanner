//
//  MainService.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 17/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import UIKit
import AVFoundation
import MetalKit

final class MainService: ObservableObject {
    
    let metalView: CustomMetalView
    private let overlayLayer: OverlayLayer
    private let videoService = VideoService()
    private let filterService = FilterService()
    private let visionService = VisionService()
    init() {
        metalView = CustomMetalView()
        overlayLayer = metalView.overlayLayer
        visionService.delegate = self
        metalView.delegate = visionService
    }

    deinit {
        stop()
    }
}

// Actions
extension MainService {
    
    func start() {
        videoService.start()
        videoService.setVideoOutputDelegate(delegate: visionService)
    }
    func stop() {
        
    }
    
    func updateFilter(_ filterType: FilterType) {
        filterService.updateFilter(filterType)
    }
    
    func track() {
        visionService.reset()
        if let quad = overlayLayer.quad?.applying(overlayLayer.cameraTransform.inverted()) {
            let rect = quad.frame
            visionService.track(Quadrilateral(rect))
        }
    }
}

extension MainService: VisionServiceDelegate {
    
    func service(_ service: VisionService, didDetectRectangle quads: [Quadrilateral]?, isTracking: Bool) {
        overlayLayer.isTracking = isTracking
        overlayLayer.quad = quads?.first?.applying(overlayLayer.cameraTransform)
    }
    
    
    func service(_ service: VisionService, didOutput buffer: CVPixelBuffer, with description: CMFormatDescription, canPerformRequest: Bool) {
        metalView.pixelBuffer = filterService.filter(buffer, with: description)
    }
    
    func service(_ service: VisionService, didDetectRectangle quad: Quadrilateral?, isTracking: Bool) {
        overlayLayer.isTracking = isTracking
        overlayLayer.quad = quad?.applying(overlayLayer.cameraTransform)
    }
}
