
import UIKit

final class CustomGradientActivityIndicator: UIView {

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
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = Constants.cornerRadius

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
    }

    private func startRotationAnimation() {
        gradientLayer.removeAnimation(forKey: Constants.rotationKey)
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = Constants.rotationDuration
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false

        gradientLayer.add(rotationAnimation, forKey: Constants.rotationKey)
    }

    private func stopRotationAnimation() {
        gradientLayer.removeAnimation(forKey: Constants.rotationKey)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
        let lineWidth = Constants.lineWidth
        shapeLayer.lineWidth = lineWidth
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let adjustedRadius = radius - lineWidth / 2
        let circularPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: adjustedRadius,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = Constants.strokeEnd
        shapeLayer.lineCap = .round
    }
    func startAnimating() {
        isHidden = false
        startRotationAnimation()
    }
    func stopAnimating() {
        isHidden = true
        stopRotationAnimation()
    }
}

// MARK: - Constants
private enum Constants {
    static let borderWidth: CGFloat = 2
    static let cornerRadius: CGFloat = 30 // как было раньше
    static let lineWidth: CGFloat = 15
    static let strokeEnd: CGFloat = 0.3
    static let rotationDuration: CFTimeInterval = 1
    static let rotationKey = "rotationAnimation"
}
