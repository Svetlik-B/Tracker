import UIKit

class TrackerViewController: UIViewController {
    let dateLabel = UILabel()
    let dateFormatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDateLabel()
        updateDate()

        let addButton = UIButton(type: .system)
        let label = UILabel()
        let logoImageView = UIImageView(image: UIImage(named: "1"))
        let questionLabel = UILabel()
        let searchBar = UISearchBar()

        [addButton, label, logoImageView, questionLabel, searchBar].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        addButton.setImage(UIImage(named: "plus"), for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        addButton.setTitleColor(.white, for: .normal)
        addButton.tintColor = .black
        addButton.clipsToBounds = true

        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            addButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),

            addButton.widthAnchor.constraint(equalToConstant: 42),
            addButton.heightAnchor.constraint(equalToConstant: 42),
        ])

        label.text = "Трекеры"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 34, weight: .semibold)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 2),
        ])

        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 7),
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
    func setupDateLabel() {
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        dateLabel.font = UIFont.systemFont(ofSize: 17, weight: .light)
        dateLabel.textAlignment = .center
        dateLabel.textColor = .black
        dateLabel.backgroundColor = .quaternarySystemFill
        dateLabel.layer.cornerRadius = 7
        dateLabel.layer.masksToBounds = true

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),

            dateLabel.widthAnchor.constraint(equalToConstant: 77),
            dateLabel.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    func updateDate() {
        let currentDate = Date()
        dateLabel.text = dateFormatter.string(from: currentDate)
    }
}
