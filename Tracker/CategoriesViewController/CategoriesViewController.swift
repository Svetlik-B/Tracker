import UIKit

final class CategoriesViewController: UIViewController {
    private let viewModel: ViewModel
    private let placeholder = UIStackView()
    private let button = UIButton(type: .system)
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
        viewModel.categoryStore.delegate = self
        setupUI()
    }
}

// MARK: - Interface
extension CategoriesViewController {
    struct ViewModel {
        var categoryStore: TrackerCategoryStoreProtocol
        var currentCategoryIndexPath: IndexPath?
        var action: (IndexPath) -> Void
    }
}

extension CategoriesViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange(_ store: TrackerCategoryStoreProtocol) {
        updateUI()
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return viewModel.categoryStore.numberOfCategories
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        )
        let category = viewModel.categoryStore.category(at: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text =
            category.name == ""
            ? "Закрепленные"
            : category.name
        cell.textLabel?.textColor = .App.black
        cell.backgroundColor = .App.background
        cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        cell.accessoryType =
            tableView.indexPathForSelectedRow == indexPath
            ? .checkmark
            : .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard tableView.indexPathForSelectedRow != indexPath
        else {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            return nil
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        var menuElements: [UIMenuElement] = [
            UIAction(title: "Редактировать") { [weak self] _ in
                self?.presentEditCategoriesViewController(at: indexPath)
            }
        ]
        if indexPath != viewModel.currentCategoryIndexPath {
            menuElements.append(
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    self?.deleteCategory(at: indexPath)
                }
            )
        }
        return .init(actionProvider: { _ in UIMenu(children: menuElements) })
    }
}

// MARK: - Implementation
extension CategoriesViewController {
    fileprivate func presentEditCategoriesViewController(at indexPath: IndexPath?) {
        let editCategoryViewController = EditCategoryViewController(
            viewModel: .init(
                categoryStore: viewModel.categoryStore,
                indexPath: indexPath
            ) { [weak self] indexPath in
                self?.tableView.reloadData()
                self?.tableView.selectRow(
                    at: indexPath,
                    animated: true,
                    scrollPosition: .top
                )
            }
        )
        let viewController = UINavigationController(rootViewController: editCategoryViewController)
        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true)

    }
    fileprivate func deleteCategory(at indexPath: IndexPath) {
        try? viewModel.categoryStore.deleteCategory(at: indexPath)
    }
    fileprivate func setupButton() {
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .App.black
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.App.white, for: .normal)
        button.addTarget(
            self,
            action: #selector(onButtonTap),
            for: .touchUpInside
        )

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                button.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 20
                ),
                button.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -20
                ),
                button.heightAnchor.constraint(equalToConstant: 60),
                button.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -16
                ),
            ]
        )
    }

    fileprivate func setupPlaceholder() {
        let imageView = UIImageView(image: .collectionPlaceholder)
        imageView.contentMode = .center

        let label = UILabel()
        label.text = "Категорий нет"

        placeholder.addArrangedSubview(imageView)
        placeholder.addArrangedSubview(label)
        placeholder.axis = .vertical
        placeholder.spacing = 8
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

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
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor),
        ])
    }

    fileprivate func setupUI() {
        view.backgroundColor = .App.white
        title = "Категория"

        setupPlaceholder()
        setupButton()
        setupTableView()
        updateUI()
    }

    fileprivate func updateUI() {
        let numberOfCategories = viewModel.categoryStore.numberOfCategories
        placeholder.isHidden = numberOfCategories != 0
        tableView.isHidden = numberOfCategories == 0
        tableView.reloadData()
    }

    @objc fileprivate func onButtonTap() {
        if let indexPath = tableView.indexPathForSelectedRow {
            viewModel.action(indexPath)
            dismiss(animated: true)
            return
        }

        presentEditCategoriesViewController(at: nil)
    }
}

#Preview {
    UINavigationController(
        rootViewController: CategoriesViewController(
            viewModel: .init(categoryStore: TrackerCategoryStore()) { print($0) }
        )
    )
}
