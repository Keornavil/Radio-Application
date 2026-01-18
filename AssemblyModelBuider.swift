

import UIKit

protocol AssemblyBuilderProtocol {
    func createStationsViewModule(router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol, imageLoader: ImageLoaderServiceProtocol) -> UIViewController
    func createNowPlayerViewModule(transferDataForRadio: TransferData, router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol) -> UIViewController
}

final class AssemblyModuleBuilder: AssemblyBuilderProtocol {

    //Создание модуля: viewController+presenter с передачей данных и связей
    func createStationsViewModule(router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol, imageLoader: ImageLoaderServiceProtocol) -> UIViewController {
        
        let networkService = NetworkServiceWithAlamofire()
        let livenessService = NetworkLivenessService()
        let radioStationData = RadioStationData(networkService: networkService, imageLoader: imageLoader)
        let presenter = StationsViewPresenter(livenessService: livenessService, router: router, audioPlayer: audioPlayer, audioPlayerDelegate: audioPlayerDelegate, radioStationData: radioStationData)
        let view = StationsViewController(presenter: presenter)
        presenter.attachView(view)
        return view
    }
    
    func createNowPlayerViewModule(transferDataForRadio: TransferData, router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol) -> UIViewController {
        let presenter = NowPlayingViewPresenter(router: router, audioPlayer: audioPlayer, audioPlayerDelegate: audioPlayerDelegate, transferDataForRadio: transferDataForRadio)
        let view = NowPlayingViewController(presenter: presenter)
        presenter.attachView(view)
        return view
    }
}
