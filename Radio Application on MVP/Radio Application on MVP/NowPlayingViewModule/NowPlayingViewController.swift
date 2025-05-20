





import UIKit

class NowPlayingViewController: UIViewController {
    
    var presenter: NowPlayingViewPresenterProtocol!
    var dataForRadio: TransferData?
    var nowPlayingViewComponents = NowPlayingViewComponents()
    
    var nameRadioLabel = UILabel()
    var trackNameLabel = UILabel()
    var artistNameLabel = UILabel()
    
    var playOrPauseButton = UIButton()
    
    var topView = UIView()
    var bottomView = UIView()
    
    var gradientView = GradientView()
    var imageView = UIImageView()
    
    var stackViewLabel = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.setComment()
        
        topView = nowPlayingViewComponents.topView
        bottomView = nowPlayingViewComponents.bottomView
        imageView = nowPlayingViewComponents.imageView
        stackViewLabel = nowPlayingViewComponents.stackViewLabel
        
        imageView.image = dataForRadio?.image
        
        nameRadioLabel = nowPlayingViewComponents.setupLabel(text: dataForRadio!.radioName!, color: .white, in: stackViewLabel)
        
        trackNameLabel = nowPlayingViewComponents.setupLabel(text: dataForRadio!.trackName!, color: .lightGray, in: stackViewLabel)
        
        artistNameLabel = nowPlayingViewComponents.setupLabel(text: dataForRadio!.artistName!, color: .lightGray, in: stackViewLabel)
        
        playOrPauseButton = nowPlayingViewComponents.setupButton(systemName: "pause.circle", action: #selector(playButtonAction), target: self)
        
        view.addSubview(gradientView)
        view.addSubview(topView)
        view.addSubview(bottomView)
        topView.addSubview(imageView)
        bottomView.addSubview(stackViewLabel)
        bottomView.addSubview(playOrPauseButton)
        
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
            stackViewLabel.heightAnchor.constraint(equalTo: playOrPauseButton.heightAnchor,constant: 20)
        ])
        
    }
    @objc func playButtonAction(_ sender: UIButton) {
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 70, weight: .ultraLight)
        let imageName = presenter.playerStatus()
        playOrPauseButton.setImage(UIImage(systemName: imageName, withConfiguration: imageConfig), for: .normal)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isBeingDismissed {
            presenter.routeForDelegate()
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}

extension NowPlayingViewController: NowPlayingViewProtocol {
    
    func setComment(transferDataForRadio: TransferData) {
        dataForRadio = transferDataForRadio
    }
    
    func dataOfSong(artistName: String, trackName: String) {
        trackNameLabel.text = trackName
        artistNameLabel.text = artistName
    }
    
    func dataOfSongImage(image: UIImage) {
        imageView.image = image
    }
}
