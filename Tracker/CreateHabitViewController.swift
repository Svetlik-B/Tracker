import UIKit

final class CreateHabitViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case nameInput
        case details
        case emoji
        case color
    }

    var action: (Tracker) -> Void = { _ in }
    var trackerName = "" { didSet { updateButtonState() }}
    var categoryName: String?  { didSet { updateButtonState() }}
    var schedule = Tracker.Schedule()  { didSet { updateButtonState() }}
    var selectedEmojiIndexPath = IndexPath(item: 0, section: Section.emoji.rawValue)
    var selectedColorIndexPath = IndexPath(item: 0, section: Section.color.rawValue)

    private let createButton = UIButton(type: .system)
    private let collectionViewLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - UITextFieldDelegate
extension CreateHabitViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if updatedText.count <= 38 {
            trackerName = updatedText
            return true
        } else {
            return false
        }
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        trackerName = ""
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension CreateHabitViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let section = Section(rawValue: section)
        else { return 0 }

        return switch section {
        case .nameInput: 1
        case .details: 2
        case .emoji: trackerEmoji.count
        case .color: trackerColors.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section)
        else { return UICollectionViewCell() }

        let cell: UICollectionViewCell

        switch section {
        case .nameInput:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerNameInputCell.reuseIdentifier,
                for: indexPath
            )
            if let cell = cell as? TrackerNameInputCell {
                cell.textField.delegate = self
            }
        case .details:
            if indexPath.item == 0 {
                cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrackerCategoryCell.reuseIdentifier,
                    for: indexPath
                )
                if let cell = cell as? TrackerCategoryCell {
                    cell.categoryLabel.text = categoryName
                }
            } else {
                cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrackerScheduleCell.reuseIdentifier,
                    for: indexPath
                )
                if let cell = cell as? TrackerScheduleCell {
                    let text =
                        schedule.count == 7
                        ? "Каждый день"
                        : schedule.sorted().map(\.short).joined(separator: ", ")
                    cell.scheduleLabel.text = text
                }
            }

        case .emoji:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerEmojiCell.reuseIdentifier,
                for: indexPath
            )
            if let cell = cell as? TrackerEmojiCell {
                cell.label.text = trackerEmoji[indexPath.item]
                cell.contentView.backgroundColor =
                    indexPath == selectedEmojiIndexPath
                    ? .App.lightGray
                    : nil
            }
        case .color:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerColorCell.reuseIdentifier,
                for: indexPath
            )
            if let cell = cell as? TrackerColorCell {
                cell.colorView.backgroundColor = trackerColors[indexPath.item]
                cell.contentView.layer.borderColor =
                    trackerColors[indexPath.item]
                    .withAlphaComponent(0.3)
                    .cgColor
                cell.contentView.layer.borderWidth =
                    indexPath == selectedColorIndexPath
                    ? 3
                    : 0
            }
        }
        return cell
    }
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath
        )

        guard
            let section = Section(rawValue: indexPath.section),
            let sectionHeaderView = view as? SectionHeaderView
        else { return view }

        switch section {
        case .nameInput, .details: break
        case .emoji: sectionHeaderView.label.text = "Emoji"
        case .color: sectionHeaderView.label.text = "Цвет"
        }

        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CreateHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard let section = Section(rawValue: section)
        else { return .zero }

        return switch section {
        case .nameInput:
            .init(
                top: 24,
                left: Constant.baseMagrin,
                bottom: 0,
                right: Constant.baseMagrin
            )
        case .details:
            .init(
                top: 24,
                left: Constant.baseMagrin,
                bottom: 32,
                right: Constant.baseMagrin
            )
        case .emoji: .init(top: 24, left: 18, bottom: 32, right: 19)
        case .color: .init(top: 24, left: 18, bottom: 40, right: 19)
        }
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let section = Section(rawValue: indexPath.section)
        else { return .zero }

        let length = (collectionView.bounds.width - 18 - 19) / 6

        return switch section {
        case .nameInput, .details:
            .init(
                width: collectionView.bounds.width - Constant.baseMagrin * 2,
                height: 75
            )
        case .emoji, .color:
            .init(width: length, height: length)
        }
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let section = Section(rawValue: section)
        else { return .zero }

        return switch section {
        case .nameInput, .details: .zero
        case .emoji, .color: .init(width: 0, height: 18)
        }
    }
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let section = Section(rawValue: indexPath.section)
        else { return }

        switch section {
        case .nameInput:
            break
        case .details:
            if indexPath.item == 1 {
                selectSchedule()
            } else if indexPath.item == 0 {
                selectCategories()
            }

        case .emoji:
            if indexPath != selectedEmojiIndexPath {
                selectedEmojiIndexPath = indexPath
                collectionView.reloadData()
            }
        case .color:
            if indexPath != selectedColorIndexPath {
                selectedColorIndexPath = indexPath
                collectionView.reloadData()
            }
        }
    }
}

final class TrackerNameInputCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerNameInputCell.self)
    let textField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    private func setupUI() {
        contentView.backgroundColor = .App.background
        contentView.layer.cornerRadius = 16

        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [
                .foregroundColor: UIColor.App.gray
            ]
        )
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .App.black
        textField.clearButtonMode = .whileEditing

        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                textField.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 16
                ),
                textField.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -16
                ),
            ]
        )
    }
}

final class TrackerCategoryCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerCategoryCell.self)
    let categoryLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    private func setupUI() {
        contentView.backgroundColor = .App.background
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
        ]

        let hStack = UIStackView()
        hStack.axis = .horizontal

        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 2

        hStack.addArrangedSubview(vStack)
        // добавить spacer
        hStack.addArrangedSubview(UIStackView())

        let label = UILabel()
        label.text = "Категория"
        label.textColor = .App.black
        vStack.addArrangedSubview(label)

        categoryLabel.textColor = .App.gray
        vStack.addArrangedSubview(categoryLabel)

        let chevron = UIImageView(image: .cheveron)
        chevron.contentMode = .center
        hStack.addArrangedSubview(chevron)
    }
}

final class TrackerScheduleCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerScheduleCell.self)
    let scheduleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    private func setupUI() {
        let divider = UIView()
        divider.backgroundColor = .divider
        contentView.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            divider.topAnchor.constraint(equalTo: contentView.topAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),
        ])

        contentView.backgroundColor = .App.background
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner,
        ]

        let hStack = UIStackView()
        hStack.axis = .horizontal

        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 2

        hStack.addArrangedSubview(vStack)
        // добавить spacer
        hStack.addArrangedSubview(UIStackView())

        let label = UILabel()
        label.text = "Расписание"
        label.textColor = .App.black
        vStack.addArrangedSubview(label)

        scheduleLabel.textColor = .App.gray
        vStack.addArrangedSubview(scheduleLabel)

        let chevron = UIImageView(image: .cheveron)
        chevron.contentMode = .center
        hStack.addArrangedSubview(chevron)

    }
}

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: SectionHeaderView.self)
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    func setupUI() {
        label.font = .systemFont(ofSize: 19, weight: .medium)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

final class TrackerEmojiCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerEmojiCell.self)
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    private func setupUI() {
        contentView.layer.cornerRadius = 16

        label.font = .systemFont(ofSize: 32, weight: .bold)
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 2.5),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
}

final class TrackerColorCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerColorCell.self)
    let colorView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        colorView.layer.cornerRadius = 8
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
}

// MARK: - Implementation

private enum Constant {
    static let baseMagrin: CGFloat = 16
}

extension CreateHabitViewController {
    fileprivate var isReady: Bool {
        trackerName != ""
            && !schedule.isEmpty
            && categoryName != nil
            && categoryName != ""
    }

    fileprivate func updateButtonState() {
        createButton.isEnabled = isReady
        createButton.backgroundColor = isReady ? .App.black : .App.gray
        createButton.setTitleColor(isReady ? .App.white : .App.black, for: .normal)
    }
    fileprivate func selectSchedule() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.schedule = schedule
        scheduleViewController.action = { [weak self] schedule in
            self?.schedule = schedule
            self?.collectionView.reloadData()
        }
        let vc = UINavigationController(
            rootViewController: scheduleViewController
        )
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }

    fileprivate func selectCategories() {
        let categoriesViewController = CategoriesViewController()
        categoriesViewController.categoryNames = ["Sveta", "Vika", "Alex", "Katya"]
        //        categoriesViewController.
        categoriesViewController.action = { [weak self] category in
            self?.categoryName = category
            self?.collectionView.reloadData()
        }
        let viewC = UINavigationController(
            rootViewController: categoriesViewController
        )
        viewC.modalPresentationStyle = .pageSheet
        present(viewC, animated: true)
    }

    @objc fileprivate func cancel() {
        dismiss(animated: true)
    }
    fileprivate func setupUI() {
        title = "Новая привычка"
        view.backgroundColor = .systemBackground

        let vStack = UIStackView()
        vStack.axis = .vertical
        view.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                vStack.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -24
                ),
                vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]
        )
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionView.register(
            TrackerNameInputCell.self,
            forCellWithReuseIdentifier: TrackerNameInputCell.reuseIdentifier
        )
        collectionView.register(
            TrackerCategoryCell.self,
            forCellWithReuseIdentifier: TrackerCategoryCell.reuseIdentifier
        )
        collectionView.register(
            TrackerScheduleCell.self,
            forCellWithReuseIdentifier: TrackerScheduleCell.reuseIdentifier
        )
        collectionView.register(
            TrackerEmojiCell.self,
            forCellWithReuseIdentifier: TrackerEmojiCell.reuseIdentifier
        )
        collectionView.register(
            TrackerColorCell.self,
            forCellWithReuseIdentifier: TrackerColorCell.reuseIdentifier
        )
        collectionView
            .register(
                SectionHeaderView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SectionHeaderView.reuseIdentifier
            )
        collectionView.dataSource = self
        collectionView.delegate = self
        vStack.addArrangedSubview(collectionView)

        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 8
        vStack.addArrangedSubview(hStack)

        let cancelButtonContainer = UIView()
        hStack.addArrangedSubview(cancelButtonContainer)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButtonContainer.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                cancelButton.heightAnchor.constraint(equalToConstant: 60),
                cancelButton.leadingAnchor.constraint(
                    equalTo: cancelButtonContainer.leadingAnchor,
                    constant: 20
                ),
                cancelButton.trailingAnchor.constraint(
                    equalTo: cancelButtonContainer.trailingAnchor),
                cancelButton.topAnchor.constraint(equalTo: cancelButtonContainer.topAnchor),
                cancelButton.bottomAnchor.constraint(equalTo: cancelButtonContainer.bottomAnchor),
            ]
        )

        let createButtonContainer = UIView()
        hStack.addArrangedSubview(createButtonContainer)

        createButton.setTitle("Создать", for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButtonContainer.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createButton.leadingAnchor.constraint(equalTo: createButtonContainer.leadingAnchor),
            createButton.trailingAnchor.constraint(
                equalTo: createButtonContainer.trailingAnchor,
                constant: -20
            ),
            createButton.topAnchor.constraint(equalTo: createButtonContainer.topAnchor),
            createButton.bottomAnchor.constraint(equalTo: createButtonContainer.bottomAnchor),
        ])
        createButton.addTarget(
            self,
            action: #selector(createButtonTapped),
            for: .touchUpInside
        )
        updateButtonState()
    }
    @objc fileprivate func createButtonTapped() {
        guard isReady else { return }
        dismiss(animated: true)
        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: trackerColors[selectedColorIndexPath.item],
            emoji: trackerEmoji[selectedEmojiIndexPath.item],
            schedule: schedule
        )
        action(tracker)
    }
}

private let trackerColors: [UIColor] = [
    .Tracker.color1,
    .Tracker.color2,
    .Tracker.color3,
    .Tracker.color4,
    .Tracker.color5,
    .Tracker.color6,
    .Tracker.color7,
    .Tracker.color8,
    .Tracker.color9,
    .Tracker.color10,
    .Tracker.color11,
    .Tracker.color12,
    .Tracker.color13,
    .Tracker.color14,
    .Tracker.color15,
    .Tracker.color16,
    .Tracker.color17,
    .Tracker.color18,
]

private let trackerEmoji = [
    "🙂",
    "😻",
    "🌺",
    "🐶",
    "❤️",
    "😱",
    "😇",
    "😡",
    "🥶",
    "🤔",
    "🙌",
    "🍔",
    "🥦",
    "🏓",
    "🥇",
    "🎸",
    "🏝",
    "😪",
]

#Preview {
    UINavigationController(rootViewController: CreateHabitViewController())
}
