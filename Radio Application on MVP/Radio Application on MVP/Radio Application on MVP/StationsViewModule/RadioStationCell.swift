
import UIKit

final class RadioStationCell: UITableViewCell {
    
    // MARK: - UI
    private let stationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let stationNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.titleFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        setupViewHierarchy()
        setupConstraints()
        setupAppearance()
    }
    private func setupViewHierarchy() {
        contentView.addSubview(stationImageView)
        contentView.addSubview(stationNameLabel)
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stationImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.horizontalInset
            ),
            stationImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stationImageView.widthAnchor.constraint(
                equalTo: contentView.heightAnchor,
                constant: -Constants.imageVerticalInset
            ),
            stationImageView.heightAnchor.constraint(
                equalTo: contentView.heightAnchor,
                constant: -Constants.imageVerticalInset
            ),
            
            stationNameLabel.leadingAnchor.constraint(
                equalTo: stationImageView.trailingAnchor,
                constant: Constants.horizontalSpacing
            ),
            stationNameLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.horizontalInset
            ),
            stationNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    private func setupAppearance() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    func configure(title: String, image: UIImage?) {
        stationNameLabel.text = title
        stationImageView.image = image
    }
}

// MARK: - Constants
private enum Constants {
    static let horizontalInset: CGFloat = 15
    static let horizontalSpacing: CGFloat = 15
    static let imageVerticalInset: CGFloat = 18
    static let titleFontSize: CGFloat = 20
    static let imageCornerRadius: CGFloat = 20
}
