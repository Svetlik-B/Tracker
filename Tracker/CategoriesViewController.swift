import UIKit

final class CategoriesViewController: UIViewController {
    var action: (TrackerCategory) -> Void = { _ in }
    private var selectedCategoryIndexPath: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

final class CategoriesCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: ScheduleCell.self)
    enum Kind {
        case top
        case middle
        case bottom
    }
    let label = UILabel()
    let checkmark = UIImageView()
    let divider = UIView()
    var kind: Kind = .middle {
        didSet {
            contentView.layer.maskedCorners =
                switch kind {
                case .top: [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                case .middle: []
                case .bottom: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override func prepareForReuse() {
        divider.isHidden = false
        checkmark.isHidden = true
        kind = .middle
    }
    func setupUI() {
        divider.backgroundColor = .divider
        contentView.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 0.5),
            divider.topAnchor.constraint(equalTo: contentView.topAnchor),
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])

        label.font = .systemFont(ofSize: 17, weight: .regular)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                stack.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 16
                ),
                stack.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -16
                ),
            ]
        )
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(checkmark)

        contentView.backgroundColor = .App.background
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = []
        checkmark.contentMode = .bottomRight
        checkmark.image = UIImage(systemName: "checkmark")
        prepareForReuse()
    }
}

// MARK: - UICollectionViewDataSource
extension CategoriesViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        Model.shared.categories.count
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

        cell.label.text = Model.shared.categories[indexPath.item].name
        if indexPath.item == 0 {
            cell.kind = .top
            cell.divider.isHidden = true
        } else if indexPath.item == Model.shared.categories.count - 1 {
            cell.kind = .bottom
        }
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
        if let selectedCategoryIndexPath {
            action(Model.shared.categories[selectedCategoryIndexPath.item])
            dismiss(animated: true)
        }
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

//#Preview {
//    UINavigationController(rootViewController: CategoriesViewController())
//}
