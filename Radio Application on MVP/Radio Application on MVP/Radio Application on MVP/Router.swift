





import UIKit

protocol RouterMain {
    var navigationController: UINavigationController? {get set}
    var assemblyBuilder: AssemblyBuilderProtocol? {get set}
}

protocol RouterProtocol: RouterMain {
    func initialStationViewController()
    func showNowPlayingViewController(dataForRadio: TransferData)
}

class Router: RouterProtocol {
    
    var navigationController: UINavigationController?
    var assemblyBuilder: AssemblyBuilderProtocol?
    var audioPlayer: AudioPlayerProtocol?
    var audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol?
    
    init(navigationController: UINavigationController, assemlyBuilder: AssemblyBuilderProtocol, audioPlayerProtocol: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol) {
        self.navigationController = navigationController
        self.assemblyBuilder = assemlyBuilder
        self.audioPlayer = audioPlayerProtocol
        self.audioPlayerDelegate = audioPlayerDelegate
    }
    
    func initialStationViewController() {
        guard let navigationController = navigationController,
              let audioPlayer = audioPlayer,
              let audioPlayerDelegate = audioPlayerDelegate,
              
                let stationsViewController = assemblyBuilder?.createStationsViewModule(router: self, audioPlayer: audioPlayer, audioPlayerDelegate: audioPlayerDelegate)
        else {
            return }
        navigationController.viewControllers = [stationsViewController]
    }
    
    func showNowPlayingViewController(dataForRadio: TransferData) {
        guard let navigationController = navigationController,
              let audioPlayer = audioPlayer,
              let audioPlayerDelegate = audioPlayerDelegate,
              let nowPlayingViewController = assemblyBuilder?.createNowPlayerViewModule(transferDataForRadio: dataForRadio, router: self, audioPlayer: audioPlayer, audioPlayerDelegate: audioPlayerDelegate)
        else {
            return }
        navigationController.visibleViewController?.present(nowPlayingViewController, animated: true)
    }
}
