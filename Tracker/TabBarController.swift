import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }

    private func setupTabBar() {
        tabBar.backgroundColor = .App.white
        tabBar.layer.borderWidth = 1
    }

    private func setupViewControllers() {
        let tracker = TrackersViewController(trackerStore: TrackerStore())
        let trackerViewController = UINavigationController(rootViewController: tracker)
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: .tracker,
            selectedImage: .tracker
        )

        let statistics = StatisticsViewController()
        let statisticsViewController = UINavigationController(rootViewController: statistics)
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: .statistics,
            selectedImage: .statistics
        )

        viewControllers = [
            trackerViewController, statisticsViewController,
        ]
        tabBar.tintColor = .App.blue

    }
}

#Preview {
    TabBarController()
}
