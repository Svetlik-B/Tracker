import CoreData
import UIKit

private enum Constant {
    static let minimumInteritemSpacing: CGFloat = 9
    static let sectionInset: CGFloat = 16
}

final class TrackersViewController: UIViewController {
    lazy var fetchedResultsController = createFetchedResultsController()

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
        updatedView()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackersViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        updatedView()
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
        guard fetchedResultsController.sections?[section] != nil else {
            return .zero
        }
        return .init(width: 0, height: section == 0 ? 54 : 46)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        fetchedResultsController.sections?.count ?? 0
        //        categories.count
    }
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }

        return sectionInfo.numberOfObjects
        //        categories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        )
        //        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        if let cell = cell as? TrackerCell {
            let isCompleted = false  // TODO:
            //            Model.shared.isCompleted(
            //                trackerId: tracker.id,
            //                on: datePicker.date
            //            )
            //            let date = datePicker.date
            //            let action = { [weak self] in
            // TODO
            //                let now = Calendar.current.startOfDay(for: Date())
            //                let selected = Calendar.current.startOfDay(for: date)
            //                guard now >= selected else { return }
            //                if isCompleted {
            //                    Model.shared.deleteRecord(trackerId: tracker.id, date: date)
            //                } else {
            //                    Model.shared.addRecord(trackerId: tracker.id, date: date)
            //                }
            //            }
            cell.configure(
                model: .init(
                    emoji: trackerCoreData.emoji ?? "",
                    text: trackerCoreData.name ?? "",
                    color: UIColorMarshalling().color(from: trackerCoreData.color ?? ""),
                    count: 0,  // TODO: Model.shared.count(trackerId: tracker.id),
                    completed: isCompleted,
                    action: {}  // TODO:
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
        guard let sectionInfo = fetchedResultsController.sections?[indexPath.section] else {
            return header
        }
        if let header = header as? TrackerHeader {
            header.label.text = sectionInfo.name
        }
        return header
    }
}

// MARK: - Implementation
extension TrackersViewController {
    fileprivate func createFetchedResultsController() -> NSFetchedResultsController<TrackerCoreData>
    {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = NSFetchRequest(
            entityName: "TrackerCoreData"
        )
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController<TrackerCoreData>(
            fetchRequest: fetchRequest,
            managedObjectContext: Store.persistentContainer.viewContext,
            sectionNameKeyPath: "category.name",
            cacheName: "AllTrackers"
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }
    @objc fileprivate func createTracker() {
        let trackerTypeSelectionViewController = TrackerTypeSelectionViewController()
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
    @objc fileprivate func datePickerEvent() {
    }
    fileprivate func updatedView() {
        let haveTrackers = (fetchedResultsController.sections?.count ?? 0) > 0
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
    UINavigationController(rootViewController: TrackersViewController())
}
