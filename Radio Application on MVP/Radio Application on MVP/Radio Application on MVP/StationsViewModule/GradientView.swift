





import UIKit

final class GradientView: UIView {

    // MARK: - Layers
    private let gradientLayer = CAGradientLayer()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup
    private func setup() {
        setupGradientLayer()
    }
    private func setupGradientLayer() {
        guard gradientLayer.superlayer == nil else { return }
        gradientLayer.colors = Constants.colors
        gradientLayer.startPoint = Constants.startPoint
        gradientLayer.endPoint = Constants.endPoint
        layer.insertSublayer(gradientLayer, at: 0)
        translatesAutoresizingMaskIntoConstraints = false
    }
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

// MARK: - Constants
private enum Constants {
    static let colors: [CGColor] = [
        UIColor(red: 54/255, green: 40/255, blue: 127/255, alpha: 1).cgColor,
        UIColor.black.cgColor,
        UIColor(red: 50/255, green: 40/255, blue: 80/255, alpha: 1).cgColor,
        UIColor(red: 81/255, green: 42/255, blue: 102/255, alpha: 1).cgColor
    ]
    static let startPoint = CGPoint(x: 1, y: 0)
    static let endPoint = CGPoint(x: 0.5, y: 1)
}
