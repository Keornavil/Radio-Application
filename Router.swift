





import UIKit

protocol RouterMain {
    var navigationController: UINavigationController { get }
    var assemblyBuilder: AssemblyBuilderProtocol { get }
}

protocol RouterProtocol: RouterMain {
    func initialStationViewController()
    func showNowPlayingViewController(dataForRadio: TransferData)
}

class Router: RouterProtocol {
    
    var navigationController: UINavigationController
    var assemblyBuilder: AssemblyBuilderProtocol
    private let audioPlayer: AudioPlayerProtocol
    private let audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol
    private let imageLoader: ImageLoaderServiceProtocol
    
    init(
        navigationController: UINavigationController,
        assemlyBuilder: AssemblyBuilderProtocol,
        audioPlayerProtocol: AudioPlayerProtocol,
        audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol,
        imageLoader: ImageLoaderServiceProtocol
    ) {
        self.navigationController = navigationController
        self.assemblyBuilder = assemlyBuilder
        self.audioPlayer = audioPlayerProtocol
        self.audioPlayerDelegate = audioPlayerDelegate
        self.imageLoader = imageLoader
    }
    
    func initialStationViewController() {
        let stationsViewController = assemblyBuilder.createStationsViewModule(
            router: self,
            audioPlayer: audioPlayer,
            audioPlayerDelegate: audioPlayerDelegate, imageLoader: imageLoader)
        navigationController.viewControllers = [stationsViewController]
    }
    
    func showNowPlayingViewController(dataForRadio: TransferData) {
        let nowPlayingViewController = assemblyBuilder.createNowPlayerViewModule(
            transferDataForRadio: dataForRadio,
            router: self,
            audioPlayer: audioPlayer,
            audioPlayerDelegate: audioPlayerDelegate)
        navigationController.visibleViewController?.present(nowPlayingViewController, animated: true)
    }
}
