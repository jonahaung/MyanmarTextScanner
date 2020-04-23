//
//  VisionService.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 18/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import AVFoundation
import Vision
import MetalKit

protocol VisionServiceDelegate: class {
    func service(_ service: VisionService, didDetectRectangle quads: [Quadrilateral]?, isTracking: Bool)
    func service(_ service: VisionService, didOutput buffer: CVPixelBuffer, with description: CMFormatDescription, canPerformRequest: Bool)
}

final class VisionService: NSObject {
    
    weak var delegate: VisionServiceDelegate?
    private let sequenceHandler = VNSequenceRequestHandler()
    private var lastTimestamp = CMTime()
    private var fps = 10
    private var lastObservation: VNDetectedObjectObservation?
    
    // Track
    fileprivate func trackObject(_ observation: VNDetectedObjectObservation, _ buffer: CVPixelBuffer) {
        let request = VNTrackObjectRequest(detectedObjectObservation: observation)
        
        request.trackingLevel = .accurate
        do {
            try sequenceHandler.perform([request], on: buffer)
        }catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            guard let newObservation = request.results?.first as? VNDetectedObjectObservation else {
                self.lastObservation = nil
                return
            }
            self.lastObservation = newObservation
            let quad = Quadrilateral(newObservation)
            self.delegate?.service(self, didDetectRectangle: [quad], isTracking: true)
            
        }
    }
    
    // Rctangle
    fileprivate func detectRectangles(_ buffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer)
        let request = VNDetectRectanglesRequest()
        request.minimumConfidence = 0.8
        request.maximumObservations = 1
        request.minimumAspectRatio = 0.2
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        
        DispatchQueue.main.async {
            guard let results = request.results as? [VNRectangleObservation], !results.isEmpty else {
                return
            }
            
            let quads: [Quadrilateral] = results.map(Quadrilateral.init)
            self.delegate?.service(self, didDetectRectangle: quads, isTracking: false)
        }
    }
    // Objects
    fileprivate func detectObjects(_ buffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer)
        let request = VNGenerateObjectnessBasedSaliencyImageRequest()
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        
        DispatchQueue.main.async {
            guard let results = (request.results?.first as? VNSaliencyImageObservation)?.salientObjects else {
                return
            }
            let quads: [Quadrilateral] = results.map(Quadrilateral.init)

            self.delegate?.service(self, didDetectRectangle: quads, isTracking: false)
        }
    }
    
    func track(_ quad: Quadrilateral) {
        lastObservation = VNDetectedObjectObservation(boundingBox: quad.frame)
    }
    
    func reset() {
        lastObservation = nil
    }
    
}

extension VisionService: MTKViewDelegate {
    
    func draw(in view: MTKView) {
        
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        VideoService.videoSize = size
        if let view = view as? CustomMetalView {
            view.updateTransform()
        }
        
    }
}

extension VisionService: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - lastTimestamp
        let canPerformRequest = deltaTime >= CMTimeMake(value: 1, timescale: Int32(fps))
        
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let description = CMSampleBufferGetFormatDescription(sampleBuffer) {
            if canPerformRequest {
                lastTimestamp = timestamp
                if let observation = lastObservation {
                    trackObject(observation, imageBuffer)
                } else {
                    if DetectorType.current == .Object {
                        detectObjects(imageBuffer)
                    }else {
                        detectRectangles(imageBuffer)
                    }
                }
                delegate?.service(self, didOutput: imageBuffer, with: description, canPerformRequest: canPerformRequest)
            }
            
        }
        CMSampleBufferInvalidate(sampleBuffer)
        
    }
}
