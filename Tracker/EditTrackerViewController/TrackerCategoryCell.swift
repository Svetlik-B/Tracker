import UIKit

final class TrackerCategoryCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerCategoryCell.self)
    let categoryLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    private func setupUI() {
        contentView.backgroundColor = .App.background
        contentView.layer.cornerRadius = 16

        let hStack = UIStackView()
        hStack.axis = .horizontal

        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 2

        hStack.addArrangedSubview(vStack)
        // добавить spacer
        hStack.addArrangedSubview(UIStackView())

        let label = UILabel()
        label.text = "Категория"
        label.textColor = .App.black
        vStack.addArrangedSubview(label)

        categoryLabel.textColor = .App.gray
        vStack.addArrangedSubview(categoryLabel)

        let chevron = UIImageView(image: .cheveron)
        chevron.contentMode = .center
        hStack.addArrangedSubview(chevron)
    }
}
