
import UIKit

// MARK: - Data -> Presenter
@objc protocol DataPresenterProtocol: AnyObject {
    func dataOnPresenter()
    func dataOfSong(artistName: String, trackName: String)
    func dataOfSongImage(image: UIImage?)
    @objc optional func succesLoadData()
    @objc optional func dataRequest(trackName: String, artistName: String, image: UIImage)
}

// MARK: - View -> Presenter
protocol StationsViewProtocol: AnyObject {
    func succes()
    func failure(error: Error)
    func viewPlayerView(constPlayerView: CGFloat)
    func showOnlineState(_ isOnline: Bool)
}

protocol StationViewPresenterProtocol: AnyObject {
    init(livenessService: LivenessServiceProtocol,
         router: RouterProtocol,
         audioPlayer: AudioPlayerProtocol,
         audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol,
         radioStationData: RadioStationDataProtocol)
    func attachView(_ view: StationsViewProtocol)
    func checkOnlineStatus()
    func getStations()
    func radioStationsCount() -> Int
    func dataForView(index: Int) -> (title: String, image: UIImage)
    func tapOnTheCellOfRadio(cellIndex: Int)
    func tapNowPlayingViewButton()
    func playerStatus() -> String
    func setupURL(url: String)
    func play()
    func pause()
    func stop()
    var constraintPlayerView: CGFloat { get set }
    func visiblePlayerView()
    func unvisiblePlayerView()
}

// MARK: - Presenter
final class StationsViewPresenter: StationViewPresenterProtocol {
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
            router.showNowPlayingViewController(dataForRadio: transferData)
            return
        }
        let station = radioStationData.radioStations[cellIndex]
        let image = radioStationData.radioStationsImages[cellIndex]
        setupURL(url: station.link)
        play()
        self.cellIndex = cellIndex
        transferData.radioName = station.title
        transferData.artistName = "Имя артиста неизвестно"
        transferData.trackName = "Название песни неизвестно"
        transferData.image = image
        audioPlayerDelegate.playerStatus = .play
    }
    func tapNowPlayingViewButton() {
        router.showNowPlayingViewController(dataForRadio: transferData)
    }
    func playerStatus() -> String {
        let status = audioPlayerDelegate.togglePlayPause()
        (status == .pause) ? pause() : play()
        return (status == .pause) ? "play.circle" : "pause.circle"
    }
    // MARK: Player control
    func setupURL(url: String) {
        guard URL(string: url) != nil else { return }
        audioPlayer.setupURLForRadio(url: url)
    }
    func play() { audioPlayer.play() }
    func pause() { audioPlayer.pause() }
    func stop() { audioPlayer.stop() }
    // MARK: PlayerView visibility
    func visiblePlayerView() {
        guard !playerViewIsVisible else { return }
        constraintPlayerView = -70
        playerViewIsVisible = true
        view?.viewPlayerView(constPlayerView: constraintPlayerView)
    }
    func unvisiblePlayerView() {
        stop()
        cellIndex = nil
        constraintPlayerView = 0
        playerViewIsVisible = false
        view?.viewPlayerView(constPlayerView: constraintPlayerView)
    }
}

// MARK: - DataPresenterProtocol
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
        guard let image else { return }
        transferData.image = image
    }
    func dataRequest(trackName: String, artistName: String, image: UIImage) {
        transferData.trackName = trackName
        transferData.artistName = artistName
        transferData.image = image
    }
    func succesLoadData() {
        Task { @MainActor in
            self.view?.succes()
        }
    }
}
