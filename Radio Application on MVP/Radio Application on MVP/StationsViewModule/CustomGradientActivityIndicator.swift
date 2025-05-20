





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
        backgroundColor = .clear
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        setupGradientIndicator()
    }
    
    private func setupGradientIndicator() {
        gradientLayer.colors = [
            UIColor.black.cgColor,
            UIColor.systemPurple.cgColor,
            UIColor.systemBlue.cgColor,
            UIColor.systemTeal.cgColor,
            UIColor.gray.cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
        layer.cornerRadius = 30
    }
    
    private func startRotationAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = 1
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false
        
        gradientLayer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func stopRotationAnimation() {
        gradientLayer.removeAnimation(forKey: "rotationAnimation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        
        let lineWidth: CGFloat = 15
        shapeLayer.lineWidth = lineWidth
        
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let adjustedRadius = radius - lineWidth / 2
        
        let circularPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: adjustedRadius,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0.3
        shapeLayer.lineCap = .round
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
