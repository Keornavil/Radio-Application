//
//  CustomActivityIndicator.swift
//  Radio Application on MVP
//
//  Created by Василий Максимов on 16.04.2025.
//

//import Foundation
import UIKit

class CustomGradientActivityIndicator: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(red: 167/255, green: 112/255, blue: 223/255, alpha: 0.7)
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        setupGradientIndicator()
        
    }
    
    private func setupGradientIndicator() {
        let radius: CGFloat = 20
        let lineWidth: CGFloat = 5
        
        gradientLayer.frame = bounds
        
        gradientLayer.colors = [
            UIColor.systemPink.cgColor,
            UIColor.systemPurple.cgColor,
            UIColor.systemBlue.cgColor,
            UIColor.systemTeal.cgColor,
            UIColor.systemPink.cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.minY)
        let circularPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi / 2 * 3,
            clockwise: true
        )
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0.7
        self.shapeLayer.lineCap = .round
        
        
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
    }
    
    private func startRotationAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 1
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false
        
        gradientLayer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func stopRotationAnimation() {
        layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
                
                let radius: CGFloat = min(bounds.width, bounds.height) / 2 - shapeLayer.lineWidth
                let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
                
                let circularPath = UIBezierPath(
                    arcCenter: centerPoint,
                    radius: radius,
                    startAngle: -.pi / 2,
                    endAngle: 3 * .pi / 2,
                    clockwise: true)
                
                shapeLayer.path = circularPath.cgPath
    }
    
    func startAnimating() {
        
        self.isHidden = false
        startRotationAnimation()
    }
    
    func stopAnimating() {
        
        self.isHidden = true
        stopRotationAnimation()
    }
    
}
