
import Foundation
import UIKit

final class NowPlayingViewUIComponents {

    func makeTopView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    func makeBottomView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 90
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    func makeLabelsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    func makeButton(systemName: String, action: Selector,target: Any) -> UIButton {
        let button = UIButton(type: .system)
        let imageConfig = UIImage.SymbolConfiguration(
            pointSize: 70,
            weight: .ultraLight
        )
        button.setImage(
            UIImage(systemName: systemName, withConfiguration: imageConfig),
            for: .normal
        )
        button.tintColor = .white
        button.addTarget(target, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    func makeLabel(text: String,color: UIColor, in view: UIStackView) -> UILabel {
            let label = UILabel()
            label.text = text
            label.textColor = color
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addArrangedSubview(label)
            return label
        }
}
