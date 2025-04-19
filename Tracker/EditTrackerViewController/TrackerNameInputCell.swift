import UIKit

final class TrackerNameInputCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerNameInputCell.self)
    let textField = UITextField()

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

        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [
                .foregroundColor: UIColor.App.gray
            ]
        )
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .App.black
        textField.clearButtonMode = .whileEditing

        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                textField.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 16
                ),
                textField.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -16
                ),
            ]
        )
    }
}
