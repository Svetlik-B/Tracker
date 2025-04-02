import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }

    private func setupTabBar() {
        tabBar.backgroundColor = .white
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
    }

    private func setupViewControllers() {

        let tracker = TrackersViewController()
        let trackerViewController = UINavigationController(rootViewController: tracker)
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Tracker"),
            selectedImage: UIImage(named: "Tracker")
        )

        let statistics = StatisticsViewController()
        let statisticsViewController = UINavigationController(rootViewController: statistics)
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Statistics"),
            selectedImage: UIImage(named: "Statistics")
        )

        viewControllers = [
            trackerViewController, statisticsViewController,
        ]
        tabBar.tintColor = .systemBlue

    }
}

