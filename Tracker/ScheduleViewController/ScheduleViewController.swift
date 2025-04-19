import UIKit

final class ScheduleViewController: UIViewController {
    var schedule: Tracker.Schedule = [.tuesday, .saturday, .wednesday]
    var action: (Tracker.Schedule) -> Void = { _ in }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - UICollectionViewDataSource
extension ScheduleViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        Tracker.Weekday.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ScheduleCell.reuseIdentifier,
            for: indexPath
        )

        guard let cell = cell as? ScheduleCell
        else { return cell }

        let day = Tracker.Weekday.allCases[indexPath.item]
        cell.label.text = day.rawValue
        if indexPath.item == 0 {
            cell.kind = .top
            cell.divider.isHidden = true
        } else if indexPath.item == Tracker.Weekday.allCases.count - 1 {
            cell.kind = .bottom
        }

        cell.toggle.isOn = schedule.contains(day)
        cell.action = { [weak self] value in
            if value {
                self?.schedule.insert(day)
            } else {
                self?.schedule.remove(day)
            }
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ScheduleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(
            width: collectionView.bounds.width - 2 * 16,
            height: 75
        )
    }
}

// MARK: - Implementation
extension ScheduleViewController {
    @objc fileprivate func ready() {
        action(schedule)
        dismiss(animated: true)
    }
    fileprivate func setupUI() {
        view.backgroundColor = .App.white
        title = "Расписание"

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 24

        view.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                vStack.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                vStack.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -24
                ),
                vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .App.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            ScheduleCell.self,
            forCellWithReuseIdentifier: ScheduleCell.reuseIdentifier
        )
        vStack.addArrangedSubview(collectionView)

        let button = UIButton(type: .system)
        button.tintColor = .App.white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .App.black
        button.layer.cornerRadius = 16
        button.setTitle("Готово", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(ready), for: .touchUpInside)

        let container = UIView()
        vStack.addArrangedSubview(container)
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        ])
    }

}

#Preview {
    UINavigationController(rootViewController: ScheduleViewController())
}
