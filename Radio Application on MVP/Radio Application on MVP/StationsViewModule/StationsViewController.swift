





import UIKit

class StationsViewController: UIViewController {
    
    var presenter: StationViewPresenterProtocol!
    var tableView = UITableView()
    let activityIndicator = CustomGradientActivityIndicator()
    let gradientView = GradientView()
    let stationViewComponents = StationsViewComponents()
    var tableViewBottomConstraint: NSLayoutConstraint?
    
    lazy var playerView = stationViewComponents.playerView
    var radioNameLabel = UILabel()
    var imageOfTrack = UIImageView()
    var playOrPauseButton = UIButton()
    var closePlayerViewButton = UIButton()
    var openNowPlayingViewButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = stationViewComponents.setupTableView(sourse: self, delegate: self)
        view.addSubview(gradientView)
        view.addSubview(playerView)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        imageOfTrack = stationViewComponents.imageOfTrack
        radioNameLabel = stationViewComponents.setupLabel(text: "", color: .white)
        playOrPauseButton = stationViewComponents.setupButton(systemName: "pause.circle", action: #selector(playButtonAction), target: self)
        closePlayerViewButton = stationViewComponents.setupButton(systemName: "xmark.circle", action: #selector(stopButtonAction), target: self)
        openNowPlayingViewButton = stationViewComponents.setupButton(systemName: "", action: #selector(openNowPlayingViewButtonAction), target: self)
        
        playerView.addSubview(playOrPauseButton)
        playerView.addSubview(closePlayerViewButton)
        playerView.addSubview(imageOfTrack)
        playerView.addSubview(radioNameLabel)
        playerView.addSubview(openNowPlayingViewButton)
        
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: presenter.constraintPlayerView)
        
        NSLayoutConstraint.activate([
            
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableViewBottomConstraint!,
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            playerView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.heightAnchor.constraint(equalToConstant: 70),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 100),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            
            playOrPauseButton.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 15),
            playOrPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playOrPauseButton.heightAnchor.constraint(equalToConstant: 40),
            playOrPauseButton.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 15),
            
            closePlayerViewButton.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: -15),
            closePlayerViewButton.widthAnchor.constraint(equalToConstant: 40),
            closePlayerViewButton.heightAnchor.constraint(equalToConstant: 40),
            closePlayerViewButton.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 15),
            
            imageOfTrack.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 10),
            imageOfTrack.leadingAnchor.constraint(equalTo: playOrPauseButton.trailingAnchor, constant: 10),
            imageOfTrack.widthAnchor.constraint(equalToConstant: 50),
            imageOfTrack.heightAnchor.constraint(equalTo: imageOfTrack.widthAnchor),
            
            radioNameLabel.leadingAnchor.constraint(equalTo: imageOfTrack.trailingAnchor, constant: 10),
            radioNameLabel.trailingAnchor.constraint(equalTo: closePlayerViewButton.leadingAnchor, constant: -10),
            radioNameLabel.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            radioNameLabel.topAnchor.constraint(equalTo: playerView.topAnchor),
            
            openNowPlayingViewButton.topAnchor.constraint(equalTo: playerView.topAnchor),
            openNowPlayingViewButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor),
            openNowPlayingViewButton.leadingAnchor.constraint(equalTo: imageOfTrack.leadingAnchor),
            openNowPlayingViewButton.trailingAnchor.constraint(equalTo: radioNameLabel.trailingAnchor)
            
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
        activityIndicator.startAnimating()
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
            self.activityIndicator.startAnimating()
            self.presenter.getComments()
        })
        present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func playButtonAction(_ sender: UIButton) {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let imageName = presenter.playerStatus()
        playOrPauseButton.setImage(UIImage(systemName: imageName, withConfiguration: imageConfig), for: .normal)
        
    }
    
    @objc func stopButtonAction(_ sender: UIButton) {
        presenter.unvisiblePlayerView()
    }
    
    @objc func openNowPlayingViewButtonAction(_ sender: UIButton) {
        presenter.tapNowPlayingViewButton()
    }
}

extension StationsViewController: StationsViewProtocol {
    
    func succes() {
        tableView.reloadData()
        activityIndicator.stopAnimating()
    }
    
    func failure(error: any Error) {
        print(error.localizedDescription)
        print("Ничего")
    }
    
    func viewPlayerView(constPlayerView: CGFloat) {
        
        tableViewBottomConstraint?.constant = constPlayerView
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
}

extension StationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.radioStationsCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? RadioStationCell else {
    
            fatalError("Could not dequeue RadioStationCell")
        }
        
        let data = presenter.dataForView(index: indexPath.row)
        cell.nameRadioLabel.text = data.title
        cell.imageStation.image = data.image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.tapOnTheCellOfRadio(cellIndex: indexPath.row)
        presenter.visiblePlayerView()
        
        let data = presenter.dataForView(index: indexPath.row)
        imageOfTrack.image = data.image
        radioNameLabel.text = data.title
        
    }
}
