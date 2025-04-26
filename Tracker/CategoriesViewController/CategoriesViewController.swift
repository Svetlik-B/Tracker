import UIKit

final class CategoriesViewController: UIViewController {
    var action: (TrackerCategory) -> Void = { _ in }
    private var selectedCategoryIndexPath: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - UICollectionViewDataSource
extension CategoriesViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        0  // Model.shared.categories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    )
        -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoriesCell.reuseIdentifier,
            for: indexPath
        )
        guard let cell = cell as? CategoriesCell
        else { return cell }

        // cell.label.text = Model.shared.categories[indexPath.item].name
        if indexPath.item == 0 {
            cell.kind.insert(.top)
            cell.divider.isHidden = true
        }
        //        if indexPath.item == Model.shared.categories.count - 1 {
        //            cell.kind.insert(.bottom)
        //        }
        cell.checkmark.isHidden = indexPath != selectedCategoryIndexPath

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CategoriesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(
            width: collectionView.bounds.width - 2 * 16,
            height: 75
        )
    }
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if selectedCategoryIndexPath == indexPath {
            selectedCategoryIndexPath = nil
            collectionView.reloadData()
        } else {
            selectedCategoryIndexPath = indexPath
            collectionView.reloadData()
        }
    }
}

// MARK: - Implementation
extension CategoriesViewController {
    @objc fileprivate func ready() {
        // if let selectedCategoryIndexPath {
        //      action(Model.shared.categories[selectedCategoryIndexPath.item])
        //      dismiss(animated: true)
        // }
    }
    fileprivate func setupUI() {
        view.backgroundColor = .App.white
        title = "Категория"

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 24

        view.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                vStack.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: 16
                ),
                vStack.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -24
                ),
                vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]
        )

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .App.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CategoriesCell.self,
            forCellWithReuseIdentifier: CategoriesCell.reuseIdentifier
        )
        vStack.addArrangedSubview(collectionView)

        let button = UIButton(type: .system)
        button.tintColor = .App.white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .App.black
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(ready), for: .touchUpInside)

        let container = UIView()
        vStack.addArrangedSubview(container)
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        ])
    }

}

#Preview {
    UINavigationController(rootViewController: CategoriesViewController())
}
