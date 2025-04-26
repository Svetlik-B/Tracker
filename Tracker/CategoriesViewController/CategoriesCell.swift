import UIKit

final class CategoriesCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: ScheduleCell.self)
    enum Kind {
        case top
        case bottom
    }
    let label = UILabel()
    let checkmark = UIImageView()
    let divider = UIView()
    var kind: Set<Kind> = [] {
        didSet {
            contentView.layer.maskedCorners =
                switch kind {
                case [.top, .bottom]:
                    [
                        .layerMinXMinYCorner,
                        .layerMaxXMinYCorner,
                        .layerMinXMaxYCorner,
                        .layerMaxXMaxYCorner,
                    ]
                case [.top]:
                    [
                        .layerMinXMinYCorner,
                        .layerMaxXMinYCorner,
                    ]
                case [.bottom]:
                    [
                        .layerMinXMaxYCorner,
                        .layerMaxXMaxYCorner,
                    ]
                default: []
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
        kind = []
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
