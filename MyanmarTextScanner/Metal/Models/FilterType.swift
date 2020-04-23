//
//  FilterType.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 18/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import Foundation

enum FilterType {
    
    case Crystal, Chrome, EdgesWork, Noir, HighlightShadowAdjust, None
    
    var description: String {
        switch self {
        case .Crystal:
            return "Crystal"
        case .Chrome:
            return "Chome"
        case .EdgesWork:
            return "Edges"
        case .HighlightShadowAdjust:
            return "Clear"
        case .Noir:
            return "Noir"
        case .None:
            return "No Filter"
        }
    }
    
    var ciFilterName: String {
        switch self {
        case .Crystal:
            return "CICrystallize"
        case .Chrome:
            return "CIPhotoEffectChrome"
        case .EdgesWork:
            return "CIEdges"
        case .HighlightShadowAdjust:
            return "CIHighlightShadowAdjust"
        case .Noir:
            return "CIPhotoEffectNoir"
        case .None:
            return ""
        }
    }
    
}

extension FilterType: CaseIterable {
}
