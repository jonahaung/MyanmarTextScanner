//
//  DetectorType.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 23/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import UIKit

enum DetectorType {
    case Rectangle, Object, Attention, Text, TextRectangle, None
    
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
        case .TextRectangle:
            return "Text Rect"
        case .None:
            return "None"
        }
    }
    
    var color: CGColor {
        switch self {
        case .Attention:
            return UIColor.systemYellow.cgColor
        case .None:
            return UIColor.clear.cgColor
        case .Object:
            return UIColor.systemPink.cgColor
        case .Rectangle:
            return UIColor.white.cgColor
        case .Text:
            return UIColor.systemOrange.cgColor
        case .TextRectangle:
            return UIColor.systemGreen.cgColor
        }
    }
    
    static var current = DetectorType.Object
}

extension DetectorType: CaseIterable { }
