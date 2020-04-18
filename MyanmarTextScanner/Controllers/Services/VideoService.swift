//
//  SwiftyTesseract.swift
//  Myanmar Lens
//
//  Created by Aung Ko Min on 20/11/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//


import AVFoundation
import UIKit

protocol VideoServiceDelegate: class {
    func videoService(_ service: VideoService, didOutput buffer: CVPixelBuffer, with description: CMFormatDescription)
}

final class VideoService: NSObject {
    
    weak var delegate: VideoServiceDelegate?
    private var canOutputBuffer = false
    private var lastTimestamp = CMTime()
    var fps = 10
    static var videoSize = CGSize.zero
    private var captureSession = AVCaptureSession()
    private let dataOutputQueue = DispatchQueue(queueLabel: .videoOutput)
    private let captureDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
    private let videoOutput: AVCaptureVideoDataOutput = {
        $0.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        return $0
    }(AVCaptureVideoDataOutput())
    

    deinit {
        captureSession.stopRunning()
        print("Video Service")
    }
    
    
    
}

// Configurations
extension VideoService {
    
    func configure() {
        captureSession = AVCaptureSession()
        guard
            isAuthorized(for: .video),
            let device = self.captureDevice,
            let captureDeviceInput = try? AVCaptureDeviceInput(device: device), captureSession.canAddInput(captureDeviceInput) else {
                return
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        captureSession.addInput(captureDeviceInput)
        
        configureVideoOutput()
        captureSession.commitConfiguration()
        
        try? device.lockForConfiguration()
        device.isSubjectAreaChangeMonitoringEnabled = true
        device.unlockForConfiguration()
    }
    
    private func suspendQueueAndConfigureSession() {
        dataOutputQueue.suspend()
        
        captureSession.sessionPreset = .photo
        dataOutputQueue.resume()
    }
    
    private func configureVideoOutput() {
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        
        
        let connection = videoOutput.connection(with: .video)
        if connection?.isVideoStabilizationSupported == true {
            connection?.preferredVideoStabilizationMode = .auto
        }else {
            connection?.preferredVideoStabilizationMode = .off
        }
        connection?.videoOrientation = .portrait
       
    }
    
    private func isAuthorized(for mediaType: AVMediaType) -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            return true
        case .notDetermined:
            requestPermission(for: mediaType)
            return false
        default:
            return false
        }
    }
    
    private func requestPermission(for mediaType: AVMediaType) {
        
        dataOutputQueue.suspend()
        AVCaptureDevice.requestAccess(for: mediaType) { [weak self] granted in
            guard let self = self else { return }
            if granted {
                self.configure()
                self.dataOutputQueue.resume()
            }
        }
    }
}

extension VideoService {
    
    func  perform(_ block: @escaping (()->Void)) {
        dataOutputQueue.async(execute: block)
    }
    func start() {
        perform { [unowned self] in
            self.canOutputBuffer = true
            self.captureSession.startRunning()
        }
    }
    func sliderValueDidChange(_ value: Float) {
        do {
            try captureDevice?.lockForConfiguration()
            var zoomScale = CGFloat(value * 10.0)
            let zoomFactor = captureDevice?.activeFormat.videoMaxZoomFactor
            
            if zoomScale < 1 {
                zoomScale = 1
            } else if zoomScale > zoomFactor! {
                zoomScale = zoomFactor!
            }
            captureDevice?.videoZoomFactor = zoomScale
            captureDevice?.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
            captureDevice?.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
            captureDevice?.unlockForConfiguration()
        } catch {
            print("captureDevice?.lockForConfiguration() denied")
        }
    }
    
    
}
extension VideoService: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard canOutputBuffer else { return }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - self.lastTimestamp
        if  deltaTime >= CMTimeMake(value: 1, timescale: Int32(self.fps)), let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let description = CMSampleBufferGetFormatDescription(sampleBuffer) {
            self.lastTimestamp = timestamp
            if VideoService.videoSize == .zero {
                VideoService.videoSize = CGSize(width: CVPixelBufferGetWidth(imageBuffer), height: CVPixelBufferGetHeight(imageBuffer))
            }
            self.delegate?.videoService(self, didOutput: imageBuffer, with: description)
            
        }
        CMSampleBufferInvalidate(sampleBuffer)
        
    }
}

