//
//  FilterService.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 18/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import Foundation
import AVFoundation

struct FilterService {
    
    private let filter = VideoFilterRenderer()
    
    init() {
        filter.filterType = .HighlightShadowAdjust
    }
    
    
    func filter(_ buffer: CVPixelBuffer, with description: CMFormatDescription) -> CVPixelBuffer? {
        guard filter.filterType != .None else {
            return buffer
        }
        
        if !filter.isPrepared {
            filter.prepare(with: description, retainHint: 3)
        }
        return filter.render(pixelBuffer: buffer)
    }
    
    func updateFilter(_ filterType: FilterType) {
        filter.reset()
        filter.filterType = filterType
    }
}
