import UIKit

final class EditTrackerViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case count
        case nameInput
        case details
        case emoji
        case color
    }

    init(trackerStore: TrackerStoreProtocol, indexPath: IndexPath? = nil) {
        self.trackerStore = trackerStore
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
        
        if let indexPath {
            let tracker = trackerStore.tracker(at: indexPath)
            self.tracker = tracker
            trackerName = tracker.name
            categoryIndexPath = tracker.categoryIndexPath
            schedule = tracker.schedule
            needsSchedule = !tracker.schedule.isEmpty
            if let index = Tracker.emoji.firstIndex(of: tracker.emoji) {
                selectedEmojiIndexPath = .init(
                    row: index,
                    section: Section.emoji.rawValue
                )
            }
            let hexColor = UIColorTransformer.hexString(from: tracker.color)
            if let index = Tracker.colors
                .map(UIColorTransformer.hexString(from:))
                .firstIndex(of: hexColor) {
                selectedColorIndexPath = .init(
                    row: index,
                    section: Section.color.rawValue
                )
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let trackerStore: TrackerStoreProtocol
    let indexPath: IndexPath?
    var needsSchedule = true
    var onCreatedTracker: (() -> Void)?

    private var tracker: Tracker? = nil
    private var isEditingTracker: Bool { indexPath != nil }
    private var trackerName = "" { didSet { updateButtonState() } }
    private var categoryStore: TrackerCategoryStoreProtocol { trackerStore.categoryStore
    }
    private var categoryIndexPath: IndexPath? { didSet { updateButtonState() } }
    private var schedule = Tracker.Schedule() { didSet { updateButtonState() } }
    private var selectedEmojiIndexPath: IndexPath? { didSet { updateButtonState() } }
    private var selectedColorIndexPath: IndexPath? { didSet { updateButtonState() } }

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
extension EditTrackerViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
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
extension EditTrackerViewController: UICollectionViewDataSource {
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
        case .count: isEditingTracker ? 1 : 0
        case .nameInput: 1
        case .details: needsSchedule ? 2 : 1
        case .emoji: Tracker.emoji.count
        case .color: Tracker.colors.count
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
        case .count:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCountCell.reuseIdentifier,
                for: indexPath
            )
            if let cell = cell as? TrackerCountCell {
                cell.label.text = tracker?.count().days
            }
        case .nameInput:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerNameInputCell.reuseIdentifier,
                for: indexPath
            )
            if let cell = cell as? TrackerNameInputCell {
                cell.textField.text = trackerName
                cell.textField.delegate = self
            }
        case .details:
            if indexPath.item == 0 {  // Категория
                cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrackerCategoryCell.reuseIdentifier,
                    for: indexPath
                )
                if let cell = cell as? TrackerCategoryCell {
                    if let indexPath = categoryIndexPath {
                        cell.categoryLabel.text = categoryStore.category(at: indexPath).name
                    }
                    cell.contentView.layer.maskedCorners =
                        needsSchedule
                        ? [
                            .layerMinXMinYCorner,
                            .layerMaxXMinYCorner,
                        ]
                        : [
                            .layerMinXMinYCorner,
                            .layerMaxXMinYCorner,
                            .layerMinXMaxYCorner,
                            .layerMaxXMaxYCorner,
                        ]
                }
            } else {  // Расписание
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
                cell.label.text = Tracker.emoji[indexPath.item]
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
                cell.colorView.backgroundColor = Tracker.colors[indexPath.item]
                cell.contentView.layer.borderColor =
                    Tracker.colors[indexPath.item]
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
        case .nameInput, .details, .count: break
        case .emoji: sectionHeaderView.label.text = "Emoji"
        case .color: sectionHeaderView.label.text = "Цвет"
        }

        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EditTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard let section = Section(rawValue: section)
        else { return .zero }

        return switch section {
        case .count:
                .init(
                    top: isEditingTracker ? 24 : 0,
                    left: Constant.baseMagrin,
                    bottom: isEditingTracker ? 16 : 0,
                    right: Constant.baseMagrin
                )
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
        case .count:
                .init(
                    width: collectionView.bounds.width,
                    height: 38
                )
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
        case .nameInput, .details, .count: .zero
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
        case .nameInput, .count:
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

// MARK: - Implementation

private enum Constant {
    case dummy
    static let baseMagrin: CGFloat = 16
}

extension EditTrackerViewController {
    fileprivate var isReady: Bool {
        trackerName != ""
            && (!needsSchedule || !schedule.isEmpty)
            && categoryIndexPath != nil
            && selectedColorIndexPath != nil
            && selectedEmojiIndexPath != nil
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
        let categoriesViewController = CategoriesViewController(
            viewModel: .init(
                categoryStore: categoryStore,
                action: { [weak self] in
                    self?.categoryIndexPath = $0
                    self?.collectionView.reloadData()
                }
            )
        )
        let viewController = UINavigationController(rootViewController: categoriesViewController)
        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true)
    }

    @objc fileprivate func cancel() {
        dismiss(animated: true)
    }
    fileprivate func setupUI() {
        title = switch (isEditingTracker, needsSchedule) {
        case (true, _): "Создание привычки"
        case (false, true): "Новая привычка"
        case(false, false): "Новое нерегулярное событие"
        }
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
            TrackerCountCell.self,
            forCellWithReuseIdentifier: TrackerCountCell.reuseIdentifier
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
                    equalTo: cancelButtonContainer.trailingAnchor
                ),
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
        guard
            let categoryIndexPath,
            isReady
        else { return }

        if let indexPath {
            try? trackerStore.editTracker(
                at: indexPath,
                name: trackerName,
                color: Tracker.colors[selectedColorIndexPath!.item],
                emoji: Tracker.emoji[selectedEmojiIndexPath!.item],
                schedule: schedule,
                categoryIndexPath: categoryIndexPath
            )

        } else {
            try? trackerStore.addNewTracker(
                name: trackerName,
                color: Tracker.colors[selectedColorIndexPath!.item],
                emoji: Tracker.emoji[selectedEmojiIndexPath!.item],
                schedule: schedule,
                categoryIndexPath: categoryIndexPath
            )
        }
        dismiss(animated: true)
        onCreatedTracker?()
    }
}

#Preview("Новый с расписанием") {
    UINavigationController(
        rootViewController: EditTrackerViewController(
            trackerStore: TrackerStore()
        )
    )
}

#Preview("Редактировать") {
    UINavigationController(
        rootViewController: EditTrackerViewController(
            trackerStore: TrackerStore(),
            indexPath: .init(row: 0, section: 0)
        )
    )
}

#Preview("Без расписания") {
    let vc = EditTrackerViewController(trackerStore: TrackerStore())
    vc.needsSchedule = false
    return UINavigationController(
        rootViewController: vc
    )
}
