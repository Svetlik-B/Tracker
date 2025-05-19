import SwiftUI
import UIKit

final class TabBarController: UITabBarController {
    init(trackerStore: TrackerStoreProtocol) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let trackerStore: TrackerStoreProtocol
    private let statisticsItem = UITabBarItem(
        title: NSLocalizedString("Статистика", comment: ""),
        image: .statistics,
        selectedImage: .statistics
    )
    private let statisticsViewModel = StatisticsViewWithNavigation.ViewModel(data: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item === statisticsItem {
            statisticsViewModel.data = (try? trackerStore.getStatistics()) ?? []
        }
    }

    private func setupTabBar() {
        tabBar.layer.borderWidth = 1
    }

    private func setupViewControllers() {
        let tracker = TrackersViewController(trackerStore: trackerStore)
        let trackerViewController = UINavigationController(rootViewController: tracker)
        trackerViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Трекеры", comment: ""),
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
    TabBarController(trackerStore: TrackerStore())
}
