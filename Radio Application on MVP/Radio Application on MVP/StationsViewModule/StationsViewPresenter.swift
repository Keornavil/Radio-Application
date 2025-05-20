





import UIKit

@objc protocol DataPresenterProtocol: AnyObject {
    func dataOnPresenter()
    func dataOfSong(artistName: String, trackName: String)
    func dataOfSongImage(image: UIImage?)
    @objc optional func succesLoadData()
    @objc optional func dataRequest(trackName: String, artistName: String, image: UIImage)
    
}

protocol StationsViewProtocol: AnyObject {
    func succes()
    func failure(error: Error)
    func viewPlayerView(constPlayerView: CGFloat)
}

protocol StationViewPresenterProtocol: AnyObject {
    init (view: StationsViewProtocol, networkService: NetworkServiceProtocol,networkReachability: NetworkReachabilityProtocol, router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol, radioStationData: RadioStationDataProtocol)
    func getComments()
    func isConnected() -> Bool
    func dataForView(index: Int) -> (title: String, image: UIImage)
    func tapOnTheCellOfRadio(cellIndex: Int)
    func tapNowPlayingViewButton()
    func radioStationsCount() -> Int
    func visiblePlayerView()
    func unvisiblePlayerView()
    func playerStatus() -> String
    func setupURL(url: String)
    func play()
    func stop()
    func pause()
    var constraintPlayerView: CGFloat { get set }
}

class StationsViewPresenter: StationViewPresenterProtocol {
    
    var constraintPlayerView: CGFloat = 0
    weak var view: StationsViewProtocol?
    let networkService: NetworkServiceProtocol!
    let networkReachability: NetworkReachabilityProtocol!
    var router: RouterProtocol?
    var audioPlayer: AudioPlayerProtocol?
    var audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol!
    var radioStationData: RadioStationDataProtocol!
    var playerViewIsVisible = false
    private var cellIndex: Int?
    private var transferData = TransferData()
    
    
    required init(view: StationsViewProtocol, networkService: NetworkServiceProtocol, networkReachability: NetworkReachabilityProtocol, router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol, radioStationData: RadioStationDataProtocol) {
        self.view = view
        self.networkService = networkService
        self.networkReachability = networkReachability
        self.router = router
        self.audioPlayer = audioPlayer
        self.audioPlayerDelegate = audioPlayerDelegate
        self.radioStationData = radioStationData
        radioStationData.setPresenterForData(presenter: self)
        dataOnPresenter()
    }
    
    func dataForView(index: Int) -> (title: String, image: UIImage) {
        let title = radioStationData.radioStations[index].title
        let image = radioStationData.radioStationsImages[index]
        return (title, image)
        
    }
    
    func tapOnTheCellOfRadio(cellIndex: Int) {
        
        guard self.cellIndex != cellIndex else {
            router?.showNowPlayingViewController(dataForRadio: self.transferData)
            return
        }
        setupURL(url: radioStationData.radioStations[cellIndex].link)
        play()
        self.cellIndex = cellIndex
        self.transferData.radioName = radioStationData.radioStations[cellIndex].title
        self.transferData.artistName = "Имя артиста неизвестно"
        self.transferData.trackName = "Название песни неизвестно"
        self.transferData.image = radioStationData.radioStationsImages[cellIndex]
        audioPlayerDelegate.playerStatus = .play
    }
    
    func playerStatus() -> String {
        let status = audioPlayerDelegate.togglePlayPause()
        (status == .pause) ? pause() : play()
        return (status == .pause) ? "play.circle" : "pause.circle"
    }
    
    func tapNowPlayingViewButton() {
        router?.showNowPlayingViewController(dataForRadio: self.transferData)
    }
    
    func isConnected() -> Bool {
        return networkReachability.isConnected()
    }
    
    func getComments() {
        radioStationData.loadDataFromNetwork()
    }
    
    func radioStationsCount() -> Int {
        return radioStationData.radioStations.count
    }
    
    
    func setupURL(url: String) {
        guard URL(string: url) != nil else { return }
        audioPlayer?.setupURLForRadio(url: url)
    }
    
    func play() {
        audioPlayer?.play()
    }
    
    func stop() {
        audioPlayer?.stop()
    }
    func pause() {
        audioPlayer?.pause()
    }
    
    func togglePlayerViewVisibility() {
        if playerViewIsVisible {
            unvisiblePlayerView()
        } else {
            visiblePlayerView()
        }
    }
    
    func visiblePlayerView() {
        if !playerViewIsVisible {
            self.constraintPlayerView = -70
            playerViewIsVisible = true
            view?.viewPlayerView(constPlayerView: self.constraintPlayerView)
        }
    }
    
    func unvisiblePlayerView() {
        stop()
        self.cellIndex = nil
        self.constraintPlayerView = 0
        playerViewIsVisible = false
        view?.viewPlayerView(constPlayerView: self.constraintPlayerView)
    }
}

extension StationsViewPresenter: DataPresenterProtocol {
    
    
    func dataOnPresenter() {
        audioPlayerDelegate.setPresenterForData(presenter: self)
    }
    
    func dataOfSong(artistName: String, trackName: String) {
        print("\(artistName) - \(trackName)")
        transferData.artistName = artistName
        transferData.trackName = trackName
    }
    
    func dataOfSongImage(image: UIImage?) {
        transferData.image = image
    }
    
    func dataRequest(trackName: String, artistName: String, image: UIImage) {
        transferData.trackName = trackName
        transferData.artistName = artistName
        transferData.image = image
    }
    
    func succesLoadData() {
        self.view?.succes()
    }
}

