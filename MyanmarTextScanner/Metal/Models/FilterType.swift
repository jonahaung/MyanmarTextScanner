//
//  FilterType.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 18/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import Foundation
enum FilterType {
    case HexagonalPixellate, HeightFieldFromMask, Crystal, Chrome, EdgesWork, NoiceReduce, Custom
    
    var ciFilterName: String {
        switch self {
        case .HexagonalPixellate:
            return "CIHexagonalPixellate"
        case .HeightFieldFromMask:
            return "CIHeightFieldFromMask"
        case .Crystal:
            return "CICrystallize"
        case .Chrome:
            return "CIPhotoEffectChrome"
        case .EdgesWork:
            return "CIEdges"
        case .NoiceReduce:
            return "CINoiseReduction"
        case .Custom:
            return "CISharpenLuminance"
        }
        
    }
    
}
