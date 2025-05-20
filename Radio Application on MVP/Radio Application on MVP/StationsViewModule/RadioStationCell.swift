





import UIKit

class RadioStationCell: UITableViewCell {
    
    let imageStation: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let nameRadioLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupViews() {
        contentView.addSubview(imageStation)
        contentView.addSubview(nameRadioLabel)
        
        NSLayoutConstraint.activate([
            imageStation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            imageStation.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageStation.widthAnchor.constraint(equalTo: contentView.heightAnchor, constant: -18),
            imageStation.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -18),
            
            nameRadioLabel.leadingAnchor.constraint(equalTo: imageStation.trailingAnchor, constant: 15),
            nameRadioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            nameRadioLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        backgroundColor = .clear
        selectionStyle = .none
        isUserInteractionEnabled = true
    }
}

