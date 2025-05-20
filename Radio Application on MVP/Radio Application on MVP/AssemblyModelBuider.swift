





import UIKit

protocol AssemblyBuilderProtocol {
    func createStationsViewModule(router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol) -> UIViewController
    func createNowPlayerViewModule(transferDataForRadio: TransferData, router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol) -> UIViewController
}

class AssemblyModuleBuilder: AssemblyBuilderProtocol {
    
    //Создание модуля: viewController+presenter с передачей данных и связей
    
    func createStationsViewModule(router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol) -> UIViewController {
        let view = StationsViewController()
        let networkService = NetworkServiceWithAlamofire()
        let networkReachability = NetworkReachability()
        let radioStationData = RadioStationData(networkService: networkService)
        let presenter = StationsViewPresenter(view: view, networkService: networkService, networkReachability: networkReachability, router: router, audioPlayer: audioPlayer, audioPlayerDelegate: audioPlayerDelegate, radioStationData: radioStationData)
        view.presenter = presenter
        return view
    }
    
    func createNowPlayerViewModule(transferDataForRadio: TransferData, router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol) -> UIViewController {
        let view = NowPlayingViewController()
        let presenter = NowPlayingViewPresenter(view: view, router: router, audioPlayer: audioPlayer, audioPlayerDelegate: audioPlayerDelegate, transferDataForRadio: transferDataForRadio)
        view.presenter = presenter
        return view
        
    }
}
