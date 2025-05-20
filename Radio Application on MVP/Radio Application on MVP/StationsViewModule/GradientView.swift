





import UIKit

class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        let topColor = UIColor(red: 54/255, green: 40/255, blue: 127/255, alpha: 1).cgColor
        let topCentralColor = UIColor.black.cgColor
        let bottomCentralColor = UIColor(red: 50/255, green: 40/255, blue: 80/255, alpha: 1).cgColor
        let bottomColor = UIColor(red: 81/255, green: 42/255, blue: 102/255, alpha: 1).cgColor
        
        gradientLayer.colors = [topColor, topCentralColor, bottomCentralColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        translatesAutoresizingMaskIntoConstraints = false
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
