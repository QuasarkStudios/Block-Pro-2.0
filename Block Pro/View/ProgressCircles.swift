//
//  ProgressCircles.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ProgressCircles: UIView {
    
    let trackLayer = CAShapeLayer()
    let shapeLayer = CAShapeLayer()
    
    var radius: CGFloat
    var lineWidth: CGFloat
    var trackLayerStrokeColor: CGColor
    var strokeColor: CGColor
    var strokeEnd: CGFloat
    
    init (radius: CGFloat, lineWidth: CGFloat, trackLayerStrokeColor: CGColor = UIColor(hexString: "F1F1F1")!.cgColor, strokeColor: CGColor, strokeEnd: CGFloat) {
        
        self.radius = radius
        self.lineWidth = lineWidth
        self.trackLayerStrokeColor = trackLayerStrokeColor
        self.strokeColor = strokeColor
        self.strokeEnd = strokeEnd
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureCircles()
    }
    
    private func configureCircles () {
        
        let center: CGPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let circularPath: UIBezierPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: (-CGFloat.pi) / 2, endAngle: -(2.5 * CGFloat.pi), clockwise: false)
        
        trackLayer.lineWidth = lineWidth + 2
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackLayerStrokeColor//UIColor(hexString: "F1F1F1")?.cgColor
        
        self.layer.addSublayer(trackLayer)
        
        shapeLayer.lineWidth = lineWidth
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = strokeEnd
        
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        self.layer.addSublayer(shapeLayer)
    }
}
