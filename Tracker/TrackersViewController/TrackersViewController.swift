import UIKit

private enum Constant {
    static let minimumInteritemSpacing: CGFloat = 9
    static let sectionInset: CGFloat = 16
}

final class TrackersViewController: UIViewController {
    var trackerStore: TrackerStoreProtocol

    init(trackerStore: TrackerStoreProtocol) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
        trackerStore.onDidChangeContent = { [weak self] in
            self?.updatedView()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var filter = FilterViewController.FilterType.all
    private let datePicker = UIDatePicker()
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
        updateFilters(dateChanged: false)
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
        guard trackerStore.sectionName(for: section) != nil
        else { return .zero }
        return .init(width: 0, height: section == 0 ? 54 : 46)
    }
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first
        else { return nil }
        let tracker = trackerStore.tracker(at: indexPath)
        return UIContextMenuConfiguration(
            previewProvider: {
                let viewModel = TrackerPreviewController.ViewModel(
                    size: .init(
                        width: (collectionView.bounds.width - 2 * Constant.sectionInset
                            - Constant.minimumInteritemSpacing) / 2,
                        height: 90
                    ),
                    color: tracker.color,
                    emoji: tracker.emoji,
                    text: tracker.name
                )
                let vc = TrackerPreviewController()
                vc.viewModel = viewModel
                return vc
            },
            actionProvider: { action in
                UIMenu(
                    children: [
                        UIAction(
                            title: tracker.isPinned ? "Открепить" : "Закрепить"
                        ) { [weak self] _ in
                            if tracker.isPinned {
                                try? self?.trackerStore.unpinTracker(at: indexPath)
                            } else {
                                try? self?.trackerStore.pinTracker(at: indexPath)
                            }
                        },
                        UIAction(title: "Редактировать") { [weak self] _ in
                            self?.editTracker(at: indexPath)
                        },
                        UIAction(
                            title: "Удалить",
                            attributes: .destructive
                        ) { [weak self] _ in
                            self?.deleteTrackers(at: indexPath)
                        },
                    ]
                )
            }
        )
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerStore.numberOfSections
    }
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        trackerStore.numberOfItems(in: section)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        )
        let tracker = trackerStore.tracker(at: indexPath)
        if let cell = cell as? TrackerCell {
            cell.configure(
                model: .init(
                    emoji: tracker.emoji,
                    text: tracker.name,
                    color: tracker.color,
                    count: tracker.count(),
                    completed: tracker.isCompleted(datePicker.date),
                    isPinned: tracker.isPinned,
                    action: { [weak self] in
                        guard let self else { return }
                        do {
                            try tracker.toggleCompleted(self.datePicker.date)
                        } catch {
                            print(
                                "Не смогли переключить запись:",
                                error.localizedDescription
                            )
                        }
                    }
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
            let text = trackerStore.sectionName(for: indexPath.section) ?? ""
            header.label.text = text.isEmpty ? "Закрепленные" : text
        }
        return header
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let searchText = searchController.searchBar.text,
            !searchText.isEmpty
        else {
            trackerStore.filterByTrackerName(nil)
            updatedView()
            return
        }
        trackerStore.filterByTrackerName(searchText)
        updatedView()
    }
    
}

// MARK: - Implementation
extension TrackersViewController {
    fileprivate func editTracker(at indexPath: IndexPath) {
        let vc = EditTrackerViewController(
            trackerStore: trackerStore,
            indexPath: indexPath
        )
        let navigationController = UINavigationController(
            rootViewController: vc
        )
        vc.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
    }
    fileprivate func deleteTrackers(at indexPath: IndexPath) {
        let actionSheet = UIAlertController(
            title: nil,
            message: "Уверены что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(
            .init(title: "Удалить", style: .destructive) { [weak self] _ in
                try? self?.trackerStore.deleteTracker(at: indexPath)
            }
        )
        actionSheet.addAction(.init(title: "Отменить", style: .cancel))
        present(actionSheet, animated: true)
    }
    @objc fileprivate func createTracker() {
        let trackerTypeSelectionViewController = TrackerTypeSelectionViewController(
            trackerStore: trackerStore
        )
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
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Поиск"
            navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self

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

        filterButton.addTarget(self, action: #selector(selectFilter), for: .touchUpInside)
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
    @objc fileprivate func datePickerEvent() {
        updateFilters(dateChanged: true)
    }
    @objc fileprivate func selectFilter() {
        let filterViewController = FilterViewController(
            viewModel: .init(filter: filter) { [weak self] filter in
                self?.filter = filter
                self?.updateFilters(dateChanged: false)
            }
        )
        let navigationController = UINavigationController(rootViewController: filterViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    fileprivate func updateFilters(dateChanged: Bool) {
        if dateChanged && filter == .today {
            filter = .all
        }
        switch filter {
        case .all:
            trackerStore.clearFilter()
        case .today:
            datePicker.date = Date()
            trackerStore.filterByDay(datePicker.date.weekday.short)
        case .completed:
            trackerStore.filterCompleted(on: datePicker.date)
        case .uncompleted:
            trackerStore.filterNotCompleted(on: datePicker.date)
        }
        updatedView()
    }
    fileprivate func updatedView() {
        let haveTrackers = trackerStore.haveTrackers
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

#Preview {
    UINavigationController(
        rootViewController: TrackersViewController(
            trackerStore: TrackerStore()
        )
    )
}
