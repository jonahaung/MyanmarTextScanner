//
//  BoundingBox.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 24/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import UIKit

class BoundingBox {
    
    private var rect: CGRect = .zero {
        didSet {
            guard oldValue != rect else {
                return
            }
            path.addRect(rect)
            layer.path = path
        }
    }
    private var path = CGMutablePath()
    private let layer: CAShapeLayer = {
        $0.fillColor = nil
        $0.lineWidth = 2
        $0.strokeColor = UIColor.systemBlue.cgColor
        return $0
    }(CAShapeLayer())
    
    
    
    func addto(_layer: CALayer) {
        _layer.addSublayer(layer)
    }
    
    func display(_rect: CGRect, with animation: CABasicAnimation) {
        rect = _rect
    }
    
    func removeLayer() {
        layer.removeFromSuperlayer()
    }
    
}
