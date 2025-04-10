import UIKit

private enum Constant {
    static let minimumInteritemSpacing: CGFloat = 9
    static let sectionInset: CGFloat = 16
}

final class TrackersViewController: UIViewController {
    var categories: [TrackerCategory] = [
        .init(
            name: "First",
            trackers: [
                .init(
                    id: UUID(),
                    name: "tracker",
                    color: .red,
                    emoji: "😪",
                    schedule: [.friday, .saturday]
                ),
                .init(
                    id: UUID(),
                    name: "tracker",
                    color: .orange,
                    emoji: "😪",
                    schedule: [.friday, .saturday]
                ),
                .init(
                    id: UUID(),
                    name: "tracker",
                    color: .cyan,
                    emoji: "😪",
                    schedule: [.friday, .saturday]
                ),
            ]
        ),
        .init(
            name: "Second",
            trackers: [
                .init(
                    id: UUID(),
                    name: "tracker",
                    color: .yellow,
                    emoji: "😪",
                    schedule: [.friday, .saturday]
                ),
                .init(
                    id: UUID(),
                    name: "tracker",
                    color: .green,
                    emoji: "😪",
                    schedule: [.friday, .saturday]
                ),
                .init(
                    id: UUID(),
                    name: "tracker",
                    color: .blue,
                    emoji: "😪",
                    schedule: [.friday, .saturday]
                ),
                .init(
                    id: UUID(),
                    name: "tracker",
                    color: .purple,
                    emoji: "😪",
                    schedule: [.friday, .saturday]
                ),
            ]
        ),
    ]
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .App.white
        setupUI()
        mainStack()
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
    static let reuseIdentifier = String(describing: TrackerCell.self)
    let colorView = UIView()
    let dayLabel = UILabel()
    let button = UIButton(type: .custom)
    // Кнопка галочка вместо плюс
    let doneImage = UIImageView(
        image: .done
            .withRenderingMode(.alwaysTemplate)
    )
    let labelCell = UILabel()
    let backgroundEmoji = UIView()
    let labelEmoji = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    func setUp() {
        colorView.layer.cornerRadius = 16
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor =
            UIColor.App.gray
            .withAlphaComponent(0.3)
            .cgColor
        labelCell.textAlignment = .left
        labelCell.numberOfLines = 3
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
        labelCell.attributedText = attributedString
        colorView.addSubview(labelCell)

        labelCell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                labelCell.centerXAnchor
                    .constraint(equalTo: colorView.centerXAnchor),
                labelCell.leadingAnchor
                    .constraint(
                        equalTo: colorView.leadingAnchor, constant: 12),
                labelCell.trailingAnchor
                    .constraint(
                        equalTo: colorView.trailingAnchor, constant: -12),
                labelCell.topAnchor
                    .constraint(greaterThanOrEqualTo: colorView.topAnchor, constant: 12),
                labelCell.bottomAnchor
                    .constraint(
                        lessThanOrEqualTo: colorView.bottomAnchor, constant: -12),
            ]
        )

        labelEmoji.text = "🐶"
        labelEmoji.font = UIFont.systemFont(ofSize: 13)
        labelEmoji.textAlignment = .center

        backgroundEmoji.backgroundColor = .white.withAlphaComponent(0.3)
        backgroundEmoji.layer.cornerRadius = 12
        //        backgroundEmoji.layer.masksToBounds = true

        backgroundEmoji.addSubview(labelEmoji)
        colorView.addSubview(backgroundEmoji)

        backgroundEmoji.translatesAutoresizingMaskIntoConstraints = false
        labelEmoji.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundEmoji.widthAnchor.constraint(equalToConstant: 24),
            backgroundEmoji.heightAnchor.constraint(equalToConstant: 24),
            backgroundEmoji.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            backgroundEmoji.leadingAnchor.constraint(
                equalTo: colorView.leadingAnchor, constant: 12),

            labelEmoji.centerXAnchor.constraint(equalTo: backgroundEmoji.centerXAnchor),
            labelEmoji.centerYAnchor.constraint(equalTo: backgroundEmoji.centerYAnchor),
        ])

        dayLabel.font = .systemFont(ofSize: 12, weight: .medium)
        button.setImage(
            .button34X34.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
//        button.setBackgroundImage(
//            .circle.withRenderingMode(.alwaysTemplate),
//            for: .normal
//        )
//        button.setImage(
//            .done.withTintColor(.App.white),
//            for: .normal
//        )
//        button.isEnabled = false
//        button.layer.opacity = 0.3

        let hStack = UIStackView(
            arrangedSubviews: [
                dayLabel,
                button,
            ]
        )
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
        .init(width: 0, height: section == 0 ? 54 : 46)
    }
}

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
            let color = categories[indexPath.section]
                .trackers[indexPath.item].color
            cell.colorView.backgroundColor = color
            cell.button.tintColor = color
            cell.dayLabel.text = "4 дня"
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

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = Constant.minimumInteritemSpacing
        layout.sectionInset = .init(
            top: 0,
            left: Constant.sectionInset,
            bottom: 0,
            right: Constant.sectionInset
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = !haveTrackers
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

        let imageContainerView = UIView()
        imageContainerView.isHidden = haveTrackers
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

        let button = UIButton(type: .system)
        button.setTitle("Фильтры", for: .normal)
        button.backgroundColor = .App.blue
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.isHidden = !haveTrackers

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate(
            [
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.widthAnchor.constraint(equalToConstant: 114),
                button.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -16
                ),
                button.heightAnchor.constraint(equalToConstant: 50),
            ]
        )
    }
}
extension TrackersViewController {
    @objc fileprivate func createTracker() {
        let trackerTypeSelectionViewController = TrackerTypeSelectionViewController()
        trackerTypeSelectionViewController.action = { [weak self] tracker in
            print(tracker)
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

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    @objc fileprivate func setDate() {
        print(#function)
    }
}

#Preview {
    UINavigationController(rootViewController: TrackersViewController())
}
