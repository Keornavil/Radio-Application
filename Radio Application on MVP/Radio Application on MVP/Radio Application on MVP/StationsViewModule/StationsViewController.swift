
import UIKit

final class StationsViewController: UIViewController {
    
    private let presenter: StationViewPresenterProtocol
    
    // MARK: - UI
    private let stationViewUIComponents = StationsViewUIComponents()
    private let gradientView = GradientView()
    private lazy var tableView: UITableView = stationViewUIComponents.makeTableView(sourсe: self, delegate: self)
    private lazy var playerView = stationViewUIComponents.makePlayerView()
    private let activityIndicator = CustomGradientActivityIndicator()
    private var tableViewBottomConstraint: NSLayoutConstraint?
    private lazy var radioNameLabel = stationViewUIComponents.makeLabel(
        text: "", color: .white)
    private lazy var imageOfStation = stationViewUIComponents.makeStationImageView()
    private lazy var playOrPauseButton = stationViewUIComponents.makeButton(
        systemName: "pause.circle", action: #selector(playButtonAction),
        target: self
    )
    private lazy var closePlayerViewButton = stationViewUIComponents.makeButton(
        systemName: "xmark.circle", action: #selector(stopButtonAction),
        target: self
    )
    private lazy var openNowPlayingViewButton = stationViewUIComponents.makeButton(
        systemName: "", action: #selector(openNowPlayingViewButtonAction),
        target: self
    )
    
    // MARK: - Init
    init(presenter: StationViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.checkOnlineStatus()
    }
}

// MARK: - Setup
private extension StationsViewController {
    
    func setupUI() {
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        view.addSubview(playerView)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        playerView.addSubview(playOrPauseButton)
        playerView.addSubview(closePlayerViewButton)
        playerView.addSubview(imageOfStation)
        playerView.addSubview(radioNameLabel)
        playerView.addSubview(openNowPlayingViewButton)
    }
    func setupConstraints() {
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: presenter.constraintPlayerView
        )
        guard let tableViewBottomConstraint else { return }
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableViewBottomConstraint,
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
            
            imageOfStation.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 10),
            imageOfStation.leadingAnchor.constraint(equalTo: playOrPauseButton.trailingAnchor, constant: 10),
            imageOfStation.widthAnchor.constraint(equalToConstant: 50),
            imageOfStation.heightAnchor.constraint(equalTo: imageOfStation.widthAnchor),
            
            radioNameLabel.leadingAnchor.constraint(equalTo: imageOfStation.trailingAnchor, constant: 10),
            radioNameLabel.trailingAnchor.constraint(equalTo: closePlayerViewButton.leadingAnchor, constant: -10),
            radioNameLabel.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            radioNameLabel.topAnchor.constraint(equalTo: playerView.topAnchor),
            
            openNowPlayingViewButton.topAnchor.constraint(equalTo: playerView.topAnchor),
            openNowPlayingViewButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor),
            openNowPlayingViewButton.leadingAnchor.constraint(equalTo: imageOfStation.leadingAnchor),
            openNowPlayingViewButton.trailingAnchor.constraint(equalTo: radioNameLabel.trailingAnchor)
        ])
    }
    func updatePlayerBar(with index: Int) {
        let data = presenter.dataForView(index: index)
        imageOfStation.image = data.image
        radioNameLabel.text = data.title
    }
    func updatePlayPauseIcon() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let imageName = presenter.playerStatus()
        playOrPauseButton.setImage(UIImage(systemName: imageName, withConfiguration: imageConfig), for: .normal)
    }
    func showAlert() {
            guard !(presentedViewController is UIAlertController) else { return }
            let alert = UIAlertController(
                title: "Нет подключения к интернету",
                message: "Проверьте подключение и попробуйте снова.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
                self?.presenter.checkOnlineStatus()
            })
            present(alert, animated: true)
        }
}

// MARK: - Actions
private extension StationsViewController {
    
    @objc func playButtonAction(_ sender: UIButton) {
        updatePlayPauseIcon()
    }
    @objc func stopButtonAction(_ sender: UIButton) {
        presenter.unvisiblePlayerView()
    }
    @objc func openNowPlayingViewButtonAction(_ sender: UIButton) {
        presenter.tapNowPlayingViewButton()
    }
}

// MARK: - StationsViewProtocol
extension StationsViewController: StationsViewProtocol {
    
    func succes() {
        tableView.reloadData()
        activityIndicator.stopAnimating()
    }
    func failure(error: any Error) {
        print(error.localizedDescription)
        activityIndicator.stopAnimating()
    }
    func viewPlayerView(constPlayerView: CGFloat) {
        tableViewBottomConstraint?.constant = constPlayerView
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    func showOnlineState(_ isOnline: Bool) {
        guard isOnline else {
            print("Нет подключения к интернету")
            showAlert()
            return
        }
        print("Есть интернет")
        activityIndicator.startAnimating()
        presenter.getStations()
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
        cell.configure(title: data.title, image: data.image)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.tapOnTheCellOfRadio(cellIndex: indexPath.row)
        presenter.visiblePlayerView()
        updatePlayerBar(with: indexPath.row)
    }
}
