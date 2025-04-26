import UIKit

final class OnboardingViewController: UIPageViewController {
    private let viewModel: ViewModel
    private var pages: [UIViewController] = []
    private let pageControl = UIPageControl()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Interface
extension OnboardingViewController {
    typealias ViewModel = [OnboardingPageViewController.ViewModel]
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        pageControl.currentPage = currentPage
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController)
        else { return nil }

        let newIndex = index - 1

        return pages.indices.contains(newIndex)
            ? pages[newIndex]
            : nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController)
        else { return nil }

        let newIndex = index + 1

        return pages.indices.contains(newIndex)
            ? pages[newIndex]
            : nil
    }
}

// MARK: - Implementation
extension OnboardingViewController {
    var currentPage: Int {
        guard let currentViewController = viewControllers?.first
        else { return 0 }
        return pages.firstIndex(of: currentViewController) ?? 0
    }
    @objc fileprivate func pageChanged() {
        setPage(pageControl.currentPage)
    }
    func setPage(_ page: Int) {
        setViewControllers(
            [pages[page]],
            direction: currentPage > pageControl.currentPage
                ? .reverse
                : .forward,
            animated: true
        )

    }
    fileprivate func setupPageControl() {
        pageControl.currentPageIndicatorTintColor = .App.onboardingText
        pageControl.pageIndicatorTintColor = .App.onboardingText.withAlphaComponent(0.3)
        pageControl.numberOfPages = viewModel.count
        pageControl.currentPage = 0

        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -168
            ),
        ])
        pageControl.addTarget(
            self,
            action: #selector(pageChanged),
            for: .valueChanged
        )
    }

    fileprivate func setup() {
        dataSource = self
        delegate = self
        pages = viewModel.map(OnboardingPageViewController.init)

        if let firstPage = pages.first {
            setViewControllers(
                [firstPage],
                direction: .forward,
                animated: true
            )
        }
        setupPageControl()
    }
}

// MARK: - Preview
#Preview {
    OnboardingViewController(
        viewModel: [
            .init(
                text: "Отслеживайте только то, что хотите",
                uiImage: .onboarding1,
                action: {
                    print("Hello!")
                }
            ),
            .init(
                text: "Даже если это не литры воды и йога",
                uiImage: .onboarding2,
                action: {
                    print("World!")
                }
            ),
        ]
    )
}
