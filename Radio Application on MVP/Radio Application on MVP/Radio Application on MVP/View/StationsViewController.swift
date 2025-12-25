//
//  ViewController.swift
//  Radio Application on MVP
//
//  Created by Василий Максимов on 11.02.2025.
//

import UIKit

class StationsViewController: UIViewController {
    
    var presenter: StationViewPresenterProtocol!
    var tableView = UITableView()
    let gradientView: UIView = {
        let gradientView = UIView(frame: UIScreen.main.bounds)
        gradientView.alpha = 1
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        let topColor = UIColor(red: 54/255, green: 40/255, blue: 127/255, alpha: 1).cgColor
        let topCentralColor = UIColor.black.cgColor
        let bottomCentralColor = UIColor(red: 50/255, green: 40/255, blue: 80/255, alpha: 1).cgColor
        let bottomColor = UIColor(red: 81/255, green: 42/255, blue: 102/255, alpha: 1).cgColor
        gradientLayer.colors = [topColor,topCentralColor,bottomCentralColor, bottomColor]
        
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.0) // Вверху
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0) // Внизу
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        return gradientView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(gradientView)
        tableView = setupTableView(in: view)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard self.presenter.isConnected() else {
            print("Нет подключения к интернету")
            showAlert()
            return
        }
        print("Есть интернет")
        self.presenter.getComments()
    }
    func showAlert() {
        let alertController = UIAlertController(title: "Подключение к интернету", message: "Нет подключения к интернету", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            guard self.presenter.isConnected() else {
                self.showAlert()
                return
            }
            print("Теперь есть подключение к интернету")
            self.presenter.getComments()
        })
        present(alertController, animated: true, completion: nil)
    }
    
}

extension StationsViewController: StationsViewProtocol {
    func succes() {
        tableView.reloadData()
    }
    
    func failure(error: any Error) {
        print(error.localizedDescription)
        print("Ничего")
    }
    
    func setGreeting(greeting: String) {

    }
}

extension StationsViewController: UITableViewDelegate, UITableViewDataSource {

    func setupTableView(in view: UIView) -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(RadioStationCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.radioStations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? RadioStationCell else {
            //
            return UITableViewCell()
            }

        let radioStations = presenter.radioStations[indexPath.row]
        let imageStation = presenter.radioStationsImages[indexPath.row]
        cell.nameRadioLabel.text = radioStations.title
        cell.imageStation.image = imageStation
        
        cell.isUserInteractionEnabled = true
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let comment = presenter.radioStations[indexPath.row]
        let image = presenter.radioStationsImages[indexPath.row]
        let transferData = TransferData(title: comment.title, link: comment.link, image: image)
        presenter.setupURL(url: comment.link)
        presenter.play()
        presenter.tapOnTheCellOfRadio(transferData: transferData)
        

    }
}


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
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18)
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
            nameRadioLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameRadioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            nameRadioLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -20)
        ])
    }
}

