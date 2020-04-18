//
//  FilterService.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 18/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import Foundation
import AVFoundation

final class FilterService {
    
    private let filter = VideoFilterRenderer()
    
    init() {
        filter.filterType = .Crystal
    }
    
    
    func filter(_ buffer: CVPixelBuffer, with description: CMFormatDescription) -> CVPixelBuffer? {
        if !filter.isPrepared {
            filter.prepare(with: description, retainHint: 3)
        }
        return filter.render(pixelBuffer: buffer)
    }
}
