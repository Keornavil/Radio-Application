
import UIKit

final class StationsViewUIComponents {
    
    func makeTableView(sourсe: UITableViewDataSource, delegate: UITableViewDelegate) -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = sourсe
        tableView.delegate = delegate
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(RadioStationCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }
    func makePlayerView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(
            red: 54/255,
            green: 40/255,
            blue: 127/255,
            alpha: 1
        )
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    func makeStationImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    func makeButton(systemName: String, action: Selector, target: Any) -> UIButton {
        let button = UIButton(type: .system)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        button.setImage(UIImage(systemName: systemName, withConfiguration: imageConfig), for: .normal)
        button.tintColor = .white
        button.addTarget(target, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    func makeLabel(text: String,color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
