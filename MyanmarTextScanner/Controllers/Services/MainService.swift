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
    private let rectFunnel = RectFunnel()
    private var canDetectFinalText = false
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
        DetectorType.current = DetectorType.current == .Object ? .TextRectangle : .Object
        rectFunnel.reset()

    }
}

extension MainService: VisionServiceDelegate {
    
    func service(_ service: VisionService, didDetectRectangle quads: [Quadrilateral], isTracking: Bool) {
        overlayLayer.isTracking = isTracking
        if quads.isEmpty {
            overlayLayer.path = nil
            rectFunnel.reset()
            visionService.reset()
        }else {
            overlayLayer.apply(quads)
            if DetectorType.current == .TextRectangle {
                if rectFunnel.filter(quads) != nil {
                     canDetectFinalText = true
                }
            }
            
        }
        
    }
    
    
    func service(_ service: VisionService, didOutput buffer: CVPixelBuffer, with description: CMFormatDescription, canPerformRequest: Bool) {
        guard let filter = filterService.filter(buffer, with: description) else { return }
        metalView.pixelBuffer = filter
        guard canPerformRequest else { return }
        if canDetectFinalText {
            canDetectFinalText = false
            DetectorType.current = .None
            ObjectDetector.text(for: filter) {[weak self] (quad) in
                guard let self = self, let quad = quad else { return }
                DispatchQueue.main.async {
                    let roi = quad.frame
                    let rect = roi.applying(self.overlayLayer.cameraTransform)
                    ObjectDetector.text(for: filter, roi: roi) { [weak self] textRects in
                        guard let self = self, let textRects = textRects else { return }
                        var results = [(String, CGRect)]()
                        textRects.forEach {
                            let text = $0.0
                            var box = $0.1
                            box.origin.y = (1 - box.origin.y-box.height)
                            let r = box.viewRect(for: rect.size)
                            results.append((text, r))
                        }
                        DispatchQueue.main.async {
                            self.visionService.toggleTrack(quad)
                            self.overlayLayer.apply(results)
                        }
                    }
                }
            }
        }
        
    }

}
