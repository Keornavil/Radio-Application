import UIKit

// MARK: - Data -> Presenter
protocol PlayerDataPresenterProtocol: AnyObject {
    func dataOnPresenter()
    func dataOfSong(artistName: String, trackName: String)
    func dataOfSongImage(image: UIImage?)
}

protocol StationsDataLoadPresenterProtocol: AnyObject {
    func successLoadData()
    func failureLoadData(error: Error)
}

protocol StationsViewPresenterProtocol: AnyObject {
    init(livenessService: LivenessServiceProtocol,
         router: RouterProtocol,
         audioPlayer: AudioPlayerProtocol,
         audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol,
         radioStationData: RadioStationDataProtocol)
    func attachView(_ view: StationsViewProtocol)
    func checkOnlineStatus()
    func activateAsDataReceiver()
    func getStations()
    func radioStationsCount() -> Int
    func dataForView(index: Int) -> (title: String, image: UIImage)
    func tapOnTheCellOfRadio(cellIndex: Int)
    func tapNowPlayingViewButton()
    func playerStatus() -> String
    func setupURL(url: String) -> Bool
    func play()
    func pause()
    func stop()
    var constraintPlayerView: CGFloat { get set }
    func showPlayerView()
    func hidePlayerView()
}

// MARK: - Presenter
final class StationsViewPresenter: StationsViewPresenterProtocol {
    // MARK: Public state
    var constraintPlayerView: CGFloat = 0
    // MARK: Weak view
    private weak var view: StationsViewProtocol?
    // MARK: Dependencies
    private let livenessService: LivenessServiceProtocol
    private let router: RouterProtocol
    private let audioPlayer: AudioPlayerProtocol
    private let audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol
    private let radioStationData: RadioStationDataProtocol

    // MARK: Internal state
    private var playerViewIsVisible = false
    private var cellIndex: Int?
    private var transferData = TransferData.initial

    // MARK: Init
    required init(livenessService: LivenessServiceProtocol,
                  router: RouterProtocol,
                  audioPlayer: AudioPlayerProtocol,
                  audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol,
                  radioStationData: RadioStationDataProtocol) {
        self.livenessService = livenessService
        self.router = router
        self.audioPlayer = audioPlayer
        self.audioPlayerDelegate = audioPlayerDelegate
        self.radioStationData = radioStationData
        radioStationData.setPresenterForData(presenter: self)
        dataOnPresenter()
    }

    // MARK: Binding
    func attachView(_ view: StationsViewProtocol) {
        self.view = view
    }

    // MARK: Lifecycle / Loading
    func checkOnlineStatus() {
        Task { [weak self] in
            guard let self else { return }
            let online = await self.livenessService.isOnline()
            await MainActor.run {
                self.view?.showOnlineState(online)
            }
        }
    }
    func activateAsDataReceiver() {
        dataOnPresenter()
    }

    func getStations() {
        radioStationData.loadDataFromNetwork()
    }

    // MARK: Table data
    func radioStationsCount() -> Int {
        radioStationData.radioStations.count
    }

    func dataForView(index: Int) -> (title: String, image: UIImage) {
        guard radioStationData.radioStations.indices.contains(index),
              radioStationData.radioStationsImages.indices.contains(index) else {
            return ("", UIImage())
        }
        return (radioStationData.radioStations[index].title,
                radioStationData.radioStationsImages[index])
    }
    func tapOnTheCellOfRadio(cellIndex: Int) {
        guard radioStationData.radioStations.indices.contains(cellIndex),
              radioStationData.radioStationsImages.indices.contains(cellIndex) else { return }
        guard self.cellIndex != cellIndex else {
            router.showNowPlayingViewController(radioName: transferData.radioName)
            return
        }
        let station = radioStationData.radioStations[cellIndex]
        let image = radioStationData.radioStationsImages[cellIndex]
        guard setupURL(url: station.link) else { return }
        play()
        self.cellIndex = cellIndex
        transferData.radioName = station.title
        audioPlayerDelegate.setCurrentStationName(station.title)
        transferData.artistName = "Имя артиста неизвестно"
        transferData.trackName = "Название песни неизвестно"
        transferData.image = image
        audioPlayerDelegate.dataRequest(
            artistName: transferData.artistName,
            trackName: transferData.trackName,
            image: transferData.image
        )
        audioPlayerDelegate.playerStatus = .play
    }
    func tapNowPlayingViewButton() {
        router.showNowPlayingViewController(radioName: transferData.radioName)
    }

    func playerStatus() -> String {
        let status = audioPlayerDelegate.togglePlayPause()
        (status == .pause) ? pause() : play()
        return (status == .pause) ? "play.circle" : "pause.circle"
    }
    // MARK: Player control
    func setupURL(url: String) -> Bool {
        guard URL(string: url) != nil else { return false }
        audioPlayer.setupURLForRadio(url: url)
        return true
    }

    func play() { audioPlayer.play() }
    func pause() { audioPlayer.pause() }
    func stop() { audioPlayer.stop() }

    // MARK: PlayerView visibility
    func showPlayerView() {
        guard !playerViewIsVisible else { return }
        constraintPlayerView = -70
        playerViewIsVisible = true
        view?.updatePlayerView(constPlayerView: constraintPlayerView)
    }
    func hidePlayerView() {
        stop()
        audioPlayerDelegate.playerStatus = .pause
        cellIndex = nil
        constraintPlayerView = 0
        playerViewIsVisible = false
        view?.updatePlayerView(constPlayerView: constraintPlayerView)
    }
}

// MARK: - PlayerDataPresenterProtocol
extension StationsViewPresenter: PlayerDataPresenterProtocol {

    func dataOnPresenter() {
        if let current = audioPlayerDelegate.presenterForData as AnyObject?, current === self {
            return
        }
        audioPlayerDelegate.setPresenterForData(presenter: self)
    }

    func dataOfSong(artistName: String, trackName: String) {
        print("\(artistName) - \(trackName)")
        transferData.artistName = artistName
        transferData.trackName = trackName
    }

    func dataOfSongImage(image: UIImage?) {
        guard let image else { return }
        transferData.image = image
    }
}

// MARK: - StationsDataLoadPresenterProtocol
extension StationsViewPresenter: StationsDataLoadPresenterProtocol {

    func successLoadData() {
        Task { @MainActor in
            self.view?.success()
        }
    }

    func failureLoadData(error: Error) {
        Task { @MainActor in
            self.view?.failure(error: error)
        }
    }
}
