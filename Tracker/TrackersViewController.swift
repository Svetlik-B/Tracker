import UIKit

class TrackersViewController: UIViewController {
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    private let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension TrackersViewController {
    fileprivate func setupUI() {
        setupDateLabel()
        updateDate()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Трекеры"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "plus"),
            style: .plain,
            target: nil,
            action: nil
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
    fileprivate func setupDateLabel() {
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        //        dateLabel.backgroundColor = .quaternarySystemFill
    }
    fileprivate func updateDate() {
        let currentDate = Date()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: dateFormatter.string(from: currentDate),
            style: .plain,
            target: nil,
            action: nil
        )

    }
}
