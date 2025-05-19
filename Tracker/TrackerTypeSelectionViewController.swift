import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    let trackerStore: TrackerStoreProtocol
    init(trackerStore: TrackerStoreProtocol) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Implementation
extension TrackerTypeSelectionViewController {
    fileprivate func createButton(
        title: String,
        selector: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .App.white
        button.backgroundColor = .App.black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    fileprivate func createTracker(needsSchedule: Bool) {
        let editTrackerViewController = EditTrackerViewController(trackerStore: trackerStore)
        editTrackerViewController.needsSchedule = needsSchedule
        editTrackerViewController.onCreatedTracker = { [weak self] in
            self?.dismiss(animated: true)
        }
        let vc = UINavigationController(
            rootViewController: editTrackerViewController
        )
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
    
    @objc fileprivate func createHabit() {
        createTracker(needsSchedule: true)
    }

    @objc fileprivate func createEvent() {
        createTracker(needsSchedule: false)
    }

    fileprivate func setupUI() {
        title = "Создание трекера"
        view.backgroundColor = .App.white

        let stack = UIStackView(
            arrangedSubviews: [
                createButton(
                    title: "Привычка",
                    selector: #selector(createHabit)
                ),
                createButton(
                    title: "Нерегулярные событие",
                    selector: #selector(createEvent)
                ),
            ]
        )
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

#Preview {
    UINavigationController(rootViewController: TrackerTypeSelectionViewController(trackerStore: TrackerStore()))
}
