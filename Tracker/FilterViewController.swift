import UIKit

final class FilterViewController: UIViewController {
    private let viewModel: ViewModel
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Interface
extension FilterViewController {
    enum FilterType: String, CaseIterable {
        case all = "Все трекеры"
        case today = "Трекеры на сегодня"
        case completed = "Завершенные"
        case uncompleted = "Не завершенные"
    }
    struct ViewModel {
        var filter: FilterType
        var action: (FilterType) -> Void
    }
}

// MARK: - UITableViewDataSource
extension FilterViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return FilterType.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        )
        cell.selectionStyle = .none
        cell.textLabel?.text = FilterType.allCases[indexPath.row].rawValue
        cell.textLabel?.textColor = .App.black
        cell.backgroundColor = .App.background
        cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        cell.accessoryType = tableView.indexPathForSelectedRow == indexPath
        ? .checkmark
        : .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let oldIndexPath = tableView.indexPathForSelectedRow {
            tableView.cellForRow(at: oldIndexPath)?.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in 
            self?.onSelectFilter(FilterType.allCases[indexPath.row])
        }
        return indexPath
    }
}

// MARK: - Implementation
extension FilterViewController {
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 75
        tableView.backgroundColor = .App.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .App.gray

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        let row = FilterType.allCases.firstIndex(of: viewModel.filter) ?? .zero
        tableView.selectRow(
            at: .init(row: row, section: 0),
            animated: false,
            scrollPosition: .middle
        )
    }

    fileprivate func setupUI() {
        view.backgroundColor = .App.white
        title = "Фильтры"

        setupTableView()
    }
    
    fileprivate func onSelectFilter(_ filter: FilterType) {
        viewModel.action(filter)
        dismiss(animated: true)
    }
}

#Preview {
    UINavigationController(
        rootViewController: FilterViewController(
            viewModel: .init(filter: .uncompleted) { print($0) }
        )
    )
}
