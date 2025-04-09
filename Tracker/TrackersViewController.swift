import UIKit

final class TrackersViewController: UIViewController {
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    private let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .App.white
        setupUI()
    }
}

extension TrackersViewController {
    @objc fileprivate func createTracker() {
        let extractedExpr: UIViewController = TrackerTypeSelectionViewController()
        let vc = UINavigationController(rootViewController: extractedExpr)
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

        let logoImageView = UIImageView(image: .collectionPlaceholder)
        let questionLabel = UILabel()
        let searchBar = UISearchBar()

        [logoImageView, questionLabel, searchBar].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .App.blue

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        logoImageView.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        questionLabel.text = "Что будем отслеживать?"
        questionLabel.textColor = .App.black
        questionLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)

        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 8),
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            questionLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor, constant: -16),
        ])
    }
    @objc fileprivate func setDate() {
        print(#function)
    }
}

#Preview {
    UINavigationController(rootViewController: TrackersViewController())
}
