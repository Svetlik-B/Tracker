import UIKit

final class CreateHabitViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case nameInput
        case details
        case emoji
        case color
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

        let cell =
            switch section {
            case .nameInput:
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrackerNameInputCell.reuseIdentifier,
                    for: indexPath
                )
            case .details:
                if indexPath.item == 0 {
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: TrackerCategoryCell.reuseIdentifier,
                        for: indexPath
                    )
                } else {
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: TrackerScheduleCell.reuseIdentifier,
                        for: indexPath
                    )
                }

            case .emoji:
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrackerEmojiCell.reuseIdentifier,
                    for: indexPath
                )
            case .color:
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrackerColorCell.reuseIdentifier,
                    for: indexPath
                )
            }

        if let colorCell = cell as? TrackerColorCell {
            colorCell.colorView.backgroundColor = trackerColors[indexPath.item]
        } else if let emojiCell = cell as? TrackerEmojiCell {
            emojiCell.label.text = trackerEmoji[indexPath.item]
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select:", indexPath)
        if indexPath == [1, 1] {
            selectSchedule()
        }
    }
}

final class TrackerNameInputCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerNameInputCell.self)
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
        
        let textField = UITextField()
        textField.text = "Учиться делать iOS-приложения"
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
        
        let nameLabel = UILabel()
        nameLabel.text = "Важное"
        nameLabel.textColor = .App.gray
        vStack.addArrangedSubview(nameLabel)
        
        let chevron = UIImageView(image: .cheveron)
        chevron.contentMode = .center
        hStack.addArrangedSubview(chevron)
    }
}

final class TrackerScheduleCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerScheduleCell.self)
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
        
        let nameLabel = UILabel()
        nameLabel.text = "Вт, Сб"
        nameLabel.textColor = .App.gray
        vStack.addArrangedSubview(nameLabel)
        
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
        label.font = .systemFont(ofSize: 32, weight: .bold)
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.widthAnchor.constraint(equalToConstant: 40),
        ])

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
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
    fileprivate func selectSchedule() {
        let vc = UINavigationController(
            rootViewController: ScheduleViewController()
        )
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
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
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
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

        let createButton = UIButton(type: .system)
        createButton.setTitle("Создать", for: .normal)
        createButton.backgroundColor = .lightGray
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
    }
}

private let trackerColors: [UIColor] = [
    .Tracker.color1,
    UIColor(
        red: 255 / 255,
        green: 136 / 255,
        blue: 30 / 255,
        alpha: 1
    ),
    UIColor(
        red: 0 / 255,
        green: 123 / 255,
        blue: 250 / 255,
        alpha: 1
    ),
    UIColor(
        red: 110 / 255,
        green: 68 / 255,
        blue: 254 / 255,
        alpha: 1
    ),
    UIColor(
        red: 51 / 255,
        green: 207 / 255,
        blue: 105 / 255,
        alpha: 1
    ),
    UIColor(
        red: 230 / 255,
        green: 109 / 255,
        blue: 212 / 255,
        alpha: 1
    ),
    UIColor(
        red: 249 / 255,
        green: 212 / 255,
        blue: 212 / 255,
        alpha: 1
    ),
    UIColor(
        red: 52 / 255,
        green: 167 / 255,
        blue: 254 / 255,
        alpha: 1
    ),
    UIColor(
        red: 70 / 255,
        green: 230 / 255,
        blue: 157 / 255,
        alpha: 1
    ),
    UIColor(
        red: 53 / 255,
        green: 52 / 255,
        blue: 124 / 255,
        alpha: 1
    ),
    UIColor(
        red: 255 / 255,
        green: 103 / 255,
        blue: 77 / 255,
        alpha: 1
    ),
    UIColor(
        red: 255 / 255,
        green: 153 / 255,
        blue: 204 / 255,
        alpha: 1
    ),
    UIColor(
        red: 246 / 255,
        green: 196 / 255,
        blue: 139 / 255,
        alpha: 1
    ),
    UIColor(
        red: 121 / 255,
        green: 148 / 255,
        blue: 245 / 255,
        alpha: 1
    ),
    UIColor(
        red: 131 / 255,
        green: 44 / 255,
        blue: 241 / 255,
        alpha: 1
    ),
    UIColor(
        red: 173 / 255,
        green: 86 / 255,
        blue: 218 / 255,
        alpha: 1
    ),
    UIColor(
        red: 141 / 255,
        green: 114 / 255,
        blue: 230 / 255,
        alpha: 1
    ),
    UIColor(
        red: 47 / 255,
        green: 208 / 255,
        blue: 88 / 255,
        alpha: 1
    ),
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
