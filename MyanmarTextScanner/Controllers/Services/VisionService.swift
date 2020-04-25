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
    func service(_ service: VisionService, didDetectRectangle quads: [Quadrilateral], isTracking: Bool)
    func service(_ service: VisionService, didOutput buffer: CVPixelBuffer, with description: CMFormatDescription, canPerformRequest: Bool)
}

final class VisionService: NSObject {
    
    weak var delegate: VisionServiceDelegate?
    private let sequenceHandler = VNSequenceRequestHandler()
    private var lastTimestamp = CMTime()
    private var fps = 5
    private var lastObservation: VNDetectedObjectObservation?
    
}

// Actions
extension VisionService {
    
    func toggleTrack(_ quad: Quadrilateral) {
        lastObservation = VNDetectedObjectObservation(boundingBox: quad.frame)
    }
    func reset() {
        lastObservation = nil
    }
}

// Detections
extension VisionService {
    // Tracking Objects
    private func trackObject(_ observation: VNDetectedObjectObservation, _ buffer: CVPixelBuffer) {
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
    
    // Detecting Rectangles
    private func detectRectangles(_ buffer: CVPixelBuffer) {
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
                self.delegate?.service(self, didDetectRectangle: [], isTracking: false)
                return
            }
            
            let quads: [Quadrilateral] = results.map(Quadrilateral.init)
            self.delegate?.service(self, didDetectRectangle: quads, isTracking: false)
        }
    }
    
    // Detecting Objects
    private func detectObjects(_ buffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer)
        let request = VNGenerateObjectnessBasedSaliencyImageRequest()
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        
        DispatchQueue.main.async {
            guard let results = (request.results?.first as? VNSaliencyImageObservation)?.salientObjects else {
                self.delegate?.service(self, didDetectRectangle: [], isTracking: false)
                return
            }
            let quads: [Quadrilateral] = results.map(Quadrilateral.init)
            
            self.delegate?.service(self, didDetectRectangle: quads, isTracking: false)
        }
    }
    // Attention
    private func detectAttention(_ buffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer)
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        
        DispatchQueue.main.async {
            guard let results = (request.results?.first as? VNSaliencyImageObservation)?.salientObjects else {
                self.delegate?.service(self, didDetectRectangle: [], isTracking: false)
                return
            }
            let quads: [Quadrilateral] = results.map(Quadrilateral.init)
            
            self.delegate?.service(self, didDetectRectangle: quads, isTracking: false)
        }
    }
    private func detectTexts(_ buffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer)
        let request = TextRequest()

        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        guard request.results != nil else { return }
        
        guard var results = request.results as? [VNRecognizedTextObservation], results.count > 0 else {
            DispatchQueue.main.async {
                 self.delegate?.service(self, didDetectRectangle: [], isTracking: false)
            }
            return
        }
        results = results.filter{ $0.confidence > 0.3 }
        let textRects: [(String, CGRect)] = {
           var x = [(String, CGRect)]()
            results.forEach {
                if let top = $0.topCandidates(1).first {
                    x.append((top.string, $0.boundingBox))
                }
            }
            return x
        }()
        let quads = textRects.map { (x) -> Quadrilateral in
            var quad = Quadrilateral(x.1)
            quad.text = x.0
            return quad
        }
        DispatchQueue.main.async {
             self.delegate?.service(self, didDetectRectangle: quads, isTracking: false)
        }
       
    }
    private func detectTextRects(_ buffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer)
        let request = VNDetectTextRectanglesRequest()

        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        guard request.results != nil else { return }
        
        guard let results = request.results as? [VNTextObservation], results.count > 0 else {
            DispatchQueue.main.async {
                 self.delegate?.service(self, didDetectRectangle: [], isTracking: false)
            }
            return
        }
        let quads: [Quadrilateral] = results.map( Quadrilateral.init )
        DispatchQueue.main.async {
             self.delegate?.service(self, didDetectRectangle: quads, isTracking: false)
        }
       
    }
}


// MTKView Delegate
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

// AVCaptureVideoDataOutputSampleBufferDelegate
extension VisionService: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer), let description = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            return
        }
    
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - lastTimestamp
        let canPerformRequest = deltaTime >= CMTimeMake(value: 1, timescale: Int32(fps))
    
        delegate?.service(self, didOutput: buffer, with: description, canPerformRequest: canPerformRequest)
        detect(buffer: buffer, canPerformRequest: canPerformRequest)
        if canPerformRequest {
            lastTimestamp = timestamp
        }
        
    }
    func detect(buffer: CVPixelBuffer, canPerformRequest: Bool) {
        if let observation = lastObservation {
            trackObject(observation, buffer)
        } else if canPerformRequest {
            switch DetectorType.current {
            case .Rectangle:
                detectRectangles(buffer)
            case .Object:
                detectObjects(buffer)
            case .Attention:
                detectAttention(buffer)
            case .Text:
                detectTexts(buffer)
            case .None:
                break
            case .TextRectangle:
                detectTextRects(buffer)
            }
        }
    }
}
