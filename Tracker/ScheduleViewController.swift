import UIKit

final class ScheduleViewController: UIViewController {
    var schedule: Tracker.Schedule = [.tuesday, .saturday, .wednesday]
    var action: (Tracker.Schedule) -> Void = { _ in }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

final class ScheduleCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: ScheduleCell.self)
    enum Kind {
        case top
        case middle
        case bottom
    }
    let label = UILabel()
    let toggle = UISwitch()
    let divider = UIView()
    var action: (Bool) -> Void = { _ in }
    var kind: Kind = .middle {
        didSet {
            contentView.layer.maskedCorners =
                switch kind {
                case .top: [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                case .middle: []
                case .bottom: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override func prepareForReuse() {
        divider.isHidden = false
        kind = .middle
        action = { _ in }
    }
    @objc private func toggleValueChanged() {
        action(toggle.isOn)
    }
    func setupUI() {
        toggle.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
        divider.backgroundColor = .divider
        contentView.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 0.5),
            divider.topAnchor.constraint(equalTo: contentView.topAnchor),
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])

        label.font = .systemFont(ofSize: 17, weight: .regular)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                stack.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 16
                ),
                stack.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -16
                ),
            ]
        )
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(toggle)

        contentView.backgroundColor = .App.background
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = []
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

//#Preview {
//    UINavigationController(rootViewController: ScheduleViewController())
//}
