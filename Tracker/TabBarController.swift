import SwiftUI
import UIKit

final class TabBarController: UITabBarController {
    private let trackerStore = TrackerStore()
    private let statisticsItem = UITabBarItem(
        title: "Статистика",
        image: .statistics,
        selectedImage: .statistics
    )
    private let statisticsViewModel = StatisticsViewWithNavigation.ViewModel(data: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item === statisticsItem {
            statisticsViewModel.data = trackerStore.getStatistics()
        }
    }

    private func setupTabBar() {
        tabBar.backgroundColor = .App.white
        tabBar.layer.borderWidth = 1
    }

    private func setupViewControllers() {
        let tracker = TrackersViewController(trackerStore: trackerStore)
        let trackerViewController = UINavigationController(rootViewController: tracker)
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: .tracker,
            selectedImage: .tracker
        )

        let statisticsViewController = UIHostingController(
            rootView: StatisticsViewWithNavigation(viewModel: statisticsViewModel)
        )
        statisticsViewController.tabBarItem = statisticsItem

        viewControllers = [
            trackerViewController, statisticsViewController,
        ]
        tabBar.tintColor = .App.blue

    }
}

#Preview {
    TabBarController()
}
