import UIKit

class TrackersViewController: UIViewController {
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    private let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension TrackersViewController {
    @objc fileprivate func createTracker() {
        let vc = UINavigationController(rootViewController: TrackerTypeSelectionViewController())
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
    fileprivate func setupDatePicker() {
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_Ru")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    fileprivate func setupUI() {
        setupDatePicker()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Трекеры"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "plus"),
            style: .plain,
            target: self,
            action: #selector(createTracker)
        )

        let logoImageView = UIImageView(image: UIImage(named: "1"))
        let questionLabel = UILabel()
        let searchBar = UISearchBar()

        [logoImageView, questionLabel, searchBar].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal

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
        questionLabel.textColor = .black
        questionLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)

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

extension Locale {
    static var custom: Locale {
        var components = Locale.Components(identifier: "en_US")
        components.currency = "BTC"
        return Locale(components: components)
    }
}

#Preview {
    UINavigationController(rootViewController: TrackersViewController())
}
