import UIKit

// MARK: - View
protocol NowPlayingViewProtocol: AnyObject {
    func setComment(transferDataForRadio: TransferData)
    func dataOfSong(artistName: String, trackName: String)
    func dataOfSongImage(image: UIImage)
}

final class NowPlayingViewController: UIViewController {
    
    private let presenter: NowPlayingViewPresenterProtocol
    
    // MARK: - UI
    private let nowPlayingViewUIComponents = NowPlayingViewUIComponents()
    private let gradientView = GradientView()
    private lazy var topView = nowPlayingViewUIComponents.makeTopView()
    private lazy var bottomView = nowPlayingViewUIComponents.makeBottomView()
    private lazy var imageView = nowPlayingViewUIComponents.makeImageView()
    private lazy var stackViewLabel = nowPlayingViewUIComponents.makeLabelsStackView()
    private lazy var nameRadioLabel = nowPlayingViewUIComponents.makeLabel(text: "", color: .white, in: stackViewLabel)
    private lazy var trackNameLabel = nowPlayingViewUIComponents.makeLabel(text: "", color: .lightGray, in: stackViewLabel)
    private lazy var artistNameLabel = nowPlayingViewUIComponents.makeLabel(text: "", color: .lightGray, in: stackViewLabel)
    private lazy var playOrPauseButton = nowPlayingViewUIComponents.makeButton(systemName: "pause.circle", action: #selector(playButtonAction), target: self)
    
    // MARK: - Init
    init(presenter: NowPlayingViewPresenterProtocol) {
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
        presenter.setComment()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.activateAsDataReceiver()
    }
}

// MARK: - Setup
private extension NowPlayingViewController {
    
    func setupUI() {
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        view.addSubview(topView)
        view.addSubview(bottomView)
        
        topView.addSubview(imageView)
        bottomView.addSubview(stackViewLabel)
        bottomView.addSubview(playOrPauseButton)
    }
    func setupConstraints() {
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.heightAnchor.constraint(equalTo: view.widthAnchor),
            
            bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: topView.widthAnchor, constant: -30),
            imageView.heightAnchor.constraint(equalTo: topView.heightAnchor, constant: -30),
            
            playOrPauseButton.topAnchor.constraint(equalTo: stackViewLabel.bottomAnchor, constant: 10),
            playOrPauseButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            
            stackViewLabel.topAnchor.constraint(equalTo: bottomView.topAnchor),
            stackViewLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            stackViewLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            stackViewLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            stackViewLabel.widthAnchor.constraint(equalTo: bottomView.widthAnchor),
            stackViewLabel.heightAnchor.constraint(equalTo: playOrPauseButton.heightAnchor, constant: 20)
        ])
    }
}

// MARK: - Actions
private extension NowPlayingViewController {
    @objc func playButtonAction(_ sender: UIButton) {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 70, weight: .ultraLight)
        let imageName = presenter.playerStatus()
        playOrPauseButton.setImage(UIImage(systemName: imageName, withConfiguration: imageConfig), for: .normal)
    }
}

extension NowPlayingViewController: NowPlayingViewProtocol {
    
    func setComment(transferDataForRadio: TransferData) {
        imageView.image = transferDataForRadio.image
        nameRadioLabel.text = transferDataForRadio.radioName
        trackNameLabel.text = transferDataForRadio.trackName
        artistNameLabel.text = transferDataForRadio.artistName
    }
    func dataOfSong(artistName: String, trackName: String) {
        trackNameLabel.text = trackName
        artistNameLabel.text = artistName
    }
    func dataOfSongImage(image: UIImage) {
        imageView.image = image
    }
}
