//
//  GeneralExtensions.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 17/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import Foundation
extension DispatchQueue {
   
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
    
    convenience init(queueLabel: DispatchQueue.Label) {
        if queueLabel == .ocr {
            self.init(label: queueLabel.rawValue, attributes: [], autoreleaseFrequency: .workItem)
        }else {
            self.init(label: queueLabel.rawValue, qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        }
        
    }
    
    enum Label: String {
        case session, videoOutput, ocr
    }
}
