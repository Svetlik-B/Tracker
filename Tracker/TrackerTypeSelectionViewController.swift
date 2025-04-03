import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
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
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    @objc fileprivate func createHabit() {
        print("Создать привычку")
    }

    @objc fileprivate func createEvent() {
        print("Создать событие")
    }

    fileprivate func setupUI() {
        title = "Создание трекера"
        view.backgroundColor = .white

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
    UINavigationController(rootViewController: TrackerTypeSelectionViewController())
}
