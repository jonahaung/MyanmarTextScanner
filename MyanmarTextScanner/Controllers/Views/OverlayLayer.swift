//
//  OverlayLayer.swift
//  MyanmarTextScanner
//
//  Created by Aung Ko Min on 18/4/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import UIKit
final class OverlayLayer: CAShapeLayer {
    

    var cameraTransform = CGAffineTransform.identity
    
    var isTracking = false {
        didSet {
            guard oldValue != isTracking else {
                return
            }
            strokeColor = isTracking ? UIColor.systemGreen.cgColor : UIColor.systemOrange.cgColor
        }
    }
    var quad: Quadrilateral? {
        didSet {
            guard oldValue != quad else { return }
            path = quad?.rectanglePath.cgPath
            add(pathAnimation, forKey: "path")
        }
    }
    
    private let pathAnimation: CABasicAnimation = {
        $0.duration = 0.2
        return $0
    }(CABasicAnimation(keyPath: "path"))
    
    func animate(){
        add(pathAnimation, forKey: "path")
    }
}
