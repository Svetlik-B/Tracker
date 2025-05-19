import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private enum Constant {
        static let seenOnboardingKey = "seenOnboarding"
    }
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        let seenOnboarding = UserDefaults.standard.bool(forKey: Constant.seenOnboardingKey)
        if seenOnboarding {
            window?.rootViewController = TabBarController(trackerStore: TrackerStore())
        } else {
            window?.rootViewController = OnboardingViewController(
                viewModel: [
                    .init(
                        text: "Отслеживайте только то, что хотите",
                        uiImage: .onboarding1,
                        action: showTabBarController
                    ),
                    .init(
                        text: "Даже если это не литры воды и йога",
                        uiImage: .onboarding2,
                        action: showTabBarController
                    ),
                ]
            )
        }
        window?.makeKeyAndVisible()
    }
    
    private func showTabBarController() {
        UserDefaults.standard.set(true, forKey: Constant.seenOnboardingKey)
        let vc = TabBarController(trackerStore: TrackerStore())
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        window?.rootViewController?.present(vc, animated: true)
    }
}
