import UIKit

private enum Constant {
    static let minimumInteritemSpacing: CGFloat = 9
    static let sectionInset: CGFloat = 16
}

final class TrackersViewController: UIViewController {
    var categories: [TrackerCategory] = [] { didSet { resetView() } }
    var completedTrackers: [TrackerRecord] = []
    var haveTrackers: Bool {
        var count: Int = 0
        for category in categories {
            count += category.trackers.count
        }
        return count > 0
    }

    private let datePicker = UIDatePicker()
    private let searchBar = UISearchBar()
    private let imageContainerView = UIView()
    private let filterButton = UIButton(type: .system)
    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .App.white
        setupUI()
        mainStack()
        categories = Model.shared.categories
    }
}

final class TrackerHeader: UICollectionReusableView {
    static let reuseIdentifier = String(describing: TrackerHeader.self)
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    func setUp() {
        addSubview(label)
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
}

final class TrackerCell: UICollectionViewCell {
    struct ViewModel {
        var emoji: String
        var text: String
        var color: UIColor
        var count: Int
        var completed: Bool
        var action: () -> Void
    }

    func configure(model: ViewModel) {
        colorView.backgroundColor = model.color
        button.tintColor = model.color
        cellLabel.text = model.text
        emojiLabel.text = model.emoji
        action = model.action
        dayLabel.text =
            switch model.count {
            case let c where c % 100 >= 10 && c % 100 <= 20: "\(c) дней"
            case let c where c % 10 == 1: "\(c) день"
            case let c where c % 10 == 2: "\(c) дня"
            case let c where c % 10 == 3: "\(c) дня"
            case let c where c % 10 == 4: "\(c) дня"
            default: "\(model.count) дней"
            }
        button.setImage(
            model.completed
                ? .done.withTintColor(.App.white)
                : .smallPlus.withTintColor(.App.white),
            for: .normal
        )
        button.layer.opacity = model.completed ? 0.3 : 1
    }

    static let reuseIdentifier = String(describing: TrackerCell.self)
    private let colorView = UIView()
    private let dayLabel = UILabel()
    private let button = UIButton(type: .custom)
    private let cellLabel = UILabel()
    private let emojiLabel = UILabel()
    private var action = {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    @objc private func didTapButton() {
        action()
    }

    override func prepareForReuse() {
        action = {}
    }

    func setUp() {
        colorView.layer.cornerRadius = 16
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor =
            UIColor.App.gray
            .withAlphaComponent(0.3)
            .cgColor
        cellLabel.textAlignment = .left
        cellLabel.numberOfLines = 3
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let attributedString = NSAttributedString(
            string: "Бабушка прислала открытку в вотсапе",
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.white,
            ]
        )
        cellLabel.attributedText = attributedString
        colorView.addSubview(cellLabel)

        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                cellLabel.centerXAnchor
                    .constraint(equalTo: colorView.centerXAnchor),
                cellLabel.leadingAnchor
                    .constraint(
                        equalTo: colorView.leadingAnchor, constant: 12),
                cellLabel.trailingAnchor
                    .constraint(
                        equalTo: colorView.trailingAnchor, constant: -12),
                cellLabel.topAnchor
                    .constraint(greaterThanOrEqualTo: colorView.topAnchor, constant: 12),
                cellLabel.bottomAnchor
                    .constraint(
                        lessThanOrEqualTo: colorView.bottomAnchor, constant: -12),
            ]
        )

        emojiLabel.text = "🐶"
        emojiLabel.font = UIFont.systemFont(ofSize: 13)
        emojiLabel.textAlignment = .center

        let emojiBackground = UIView()
        emojiBackground.backgroundColor = .white.withAlphaComponent(0.3)
        emojiBackground.layer.cornerRadius = 12

        emojiBackground.addSubview(emojiLabel)
        colorView.addSubview(emojiBackground)

        emojiBackground.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            emojiBackground.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiBackground.leadingAnchor.constraint(
                equalTo: colorView.leadingAnchor, constant: 12),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
        ])

        dayLabel.font = .systemFont(ofSize: 12, weight: .medium)

        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.setBackgroundImage(
            .circle.withRenderingMode(.alwaysTemplate),
            for: .normal
        )

        let hStack = UIStackView(arrangedSubviews: [dayLabel, button])
        hStack.axis = .horizontal
        hStack.spacing = 8

        let view = UIView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hStack)

        NSLayoutConstraint.activate(
            [
                colorView.heightAnchor.constraint(equalToConstant: 90),
                view.heightAnchor.constraint(equalToConstant: 58),
                hStack.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 12
                ),
                hStack.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -16
                ),
                hStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            ]
        )

        let stack = UIStackView(frame: contentView.frame)
        stack.axis = .vertical
        stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stack.addArrangedSubview(colorView)
        stack.addArrangedSubview(view)

        contentView.addSubview(stack)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(
            width: (collectionView.bounds.width - 2 * Constant.sectionInset
                - Constant.minimumInteritemSpacing) / 2,
            height: 148
        )
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard categories[section].trackers.count > 0 else {
            return .zero
        }
        return .init(width: 0, height: section == 0 ? 54 : 46)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        categories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        )
        if let cell = cell as? TrackerCell {
            let tracker = categories[indexPath.section].trackers[indexPath.item]
            let isCompleted = Model.shared.isCompleted(
                trackerId: tracker.id,
                on: datePicker.date
            )
            let date = datePicker.date
            let action = { [weak self] in
                let now = Calendar.current.startOfDay(for: Date())
                let selected = Calendar.current.startOfDay(for: date)
                guard now >= selected else { return }
                if isCompleted {
                    Model.shared.deleteRecord(trackerId: tracker.id, date: date)
                } else {
                    Model.shared.addRecord(trackerId: tracker.id, date: date)
                }
                self?.resetView()
            }
            cell.configure(
                model: .init(
                    emoji: tracker.emoji,
                    text: tracker.name,
                    color: tracker.color,
                    count: Model.shared.count(trackerId: tracker.id),
                    completed: isCompleted,
                    action: action
                )
            )
        }
        return cell
    }
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeader.reuseIdentifier,
            for: indexPath
        )
        if let header = header as? TrackerHeader {
            header.label.text = categories[indexPath.section].name
        }
        return header
    }
}

extension TrackersViewController {
    fileprivate func mainStack() {
        let mainStack = UIStackView(frame: view.bounds)
        mainStack.axis = .vertical
        view.addSubview(mainStack)

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .App.blue
        mainStack.addArrangedSubview(searchBar)

        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = Constant.minimumInteritemSpacing
        layout.sectionInset = .init(
            top: 0,
            left: Constant.sectionInset,
            bottom: 0,
            right: Constant.sectionInset
        )

        collectionView.backgroundColor = .App.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.reuseIdentifier
        )
        collectionView.register(
            TrackerHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeader.reuseIdentifier
        )
        mainStack.addArrangedSubview(collectionView)

        let logoImageView = UIImageView(image: .collectionPlaceholder)
        logoImageView.contentMode = .scaleAspectFit

        let questionLabel = UILabel()
        questionLabel.text = "Что будем отслеживать?"
        questionLabel.textColor = .App.black
        questionLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)

        mainStack.addArrangedSubview(imageContainerView)

        let imageStack = UIStackView()
        imageStack.axis = .vertical
        imageStack.spacing = 8
        imageStack.addArrangedSubview(logoImageView)
        imageStack.addArrangedSubview(questionLabel)
        imageContainerView.addSubview(imageStack)
        imageStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageStack.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageStack.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
        ])

        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.backgroundColor = .App.blue
        filterButton.tintColor = .white
        filterButton.layer.cornerRadius = 16

        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        NSLayoutConstraint.activate(
            [
                filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                filterButton.widthAnchor.constraint(equalToConstant: 114),
                filterButton.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -16
                ),
                filterButton.heightAnchor.constraint(equalToConstant: 50),
            ]
        )
    }
}
extension TrackersViewController {
    @objc fileprivate func createTracker() {
        let trackerTypeSelectionViewController = TrackerTypeSelectionViewController()
        trackerTypeSelectionViewController.action = { [weak self] tracker in
            guard let self else { return }
            Model.shared.add(tracker: tracker)
            print(tracker)

            categories = Model.shared.categories
        }
        let vc = UINavigationController(rootViewController: trackerTypeSelectionViewController)
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }

    fileprivate func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .App.black
        navigationItem.title = "Трекеры"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .plus,
            style: .plain,
            target: self,
            action: #selector(createTracker)
        )

        datePicker.tintColor = .App.blue
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_Ru")
        datePicker.addTarget(
            self,
            action: #selector(datePickerEvent),
            for: .editingDidEnd
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    @objc fileprivate func datePickerEvent() {
        categories = Model.shared.categories
    }
    fileprivate func resetView() {
        collectionView.isHidden = !haveTrackers
        filterButton.isHidden = !haveTrackers
        imageContainerView.isHidden = haveTrackers
        collectionView.reloadData()
    }
    fileprivate var selectedWeekday: Tracker.Weekday {
        let weekdayComponent = datePicker.calendar.dateComponents(
            [.weekday],
            from: datePicker.date
        )
        return switch weekdayComponent.weekday ?? 0 {
        case 2: .monday
        case 3: .tuesday
        case 4: .wednesday
        case 5: .thursday
        case 6: .friday
        case 7: .saturday
        default: .sunday
        }
    }
}

//#Preview {
//    UINavigationController(rootViewController: TrackersViewController())
//}
