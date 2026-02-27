import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        let imageLoader = ImageLoaderService()
        let audioPlayer = AudioPlayer()
        let audioPlayerDelegate = AudioPlayerDelegateHandler(imageLoader: imageLoader)
        let navigationController = UINavigationController()
        let assemblyBuilder = AssemblyModuleBuilder()
        let router = Router(
            navigationController: navigationController,
            assemlyBuilder: assemblyBuilder,
            audioPlayerProtocol: audioPlayer,
            audioPlayerDelegate: audioPlayerDelegate,
            imageLoader: imageLoader
        )
        router.initialStationViewController()
        audioPlayer.setDelegate(delegate: audioPlayerDelegate)
        audioPlayerDelegate.configurePlaybackHandlers(
            play: { audioPlayer.play() },
            pause: { audioPlayer.pause() }
        )
        UIApplication.shared.beginReceivingRemoteControlEvents()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
