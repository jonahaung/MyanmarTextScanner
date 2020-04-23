//
//  DetectorType.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 23/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import Foundation

enum DetectorType {
    case Rectangle, Object, Attention, Text
    
    var description: String {
        switch self {
        case .Rectangle:
            return "Rectangel"
        case .Object:
            return "Object"
        case .Attention:
            return "Attention"
        case .Text:
            return "Text"
        }
    }
    
    static var current = DetectorType.Object
}

extension DetectorType: CaseIterable { }
