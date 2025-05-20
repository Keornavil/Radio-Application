





import UIKit

class StationsViewComponents {
    
    func setupTableView(sourse: UITableViewDataSource, delegate: UITableViewDelegate) -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = sourse
        tableView.delegate = delegate
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(RadioStationCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }
    
    let playerView: UIView = {
        let playerView = UIView()
        playerView.backgroundColor = UIColor(red: 54/255, green: 40/255, blue: 127/255, alpha: 1)
        playerView.clipsToBounds = false
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()
    
    var imageOfTrack: UIImageView = {
       let imageOfTrack = UIImageView()
        imageOfTrack.contentMode = .scaleAspectFill
        imageOfTrack.clipsToBounds = true
        imageOfTrack.layer.cornerRadius = 15
        imageOfTrack.layer.masksToBounds = true
        imageOfTrack.translatesAutoresizingMaskIntoConstraints = false
        return imageOfTrack
    }()
    
    func setupButton(systemName: String, action: Selector, target: Any) -> UIButton {
        let button = UIButton(type: .system)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        button.setImage(UIImage(systemName: systemName, withConfiguration: imageConfig), for: .normal)
        button.tintColor = .white
        button.addTarget(target, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func setupLabel(text: String,color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
