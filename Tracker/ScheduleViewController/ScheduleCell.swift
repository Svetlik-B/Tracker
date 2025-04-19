import UIKit

final class ScheduleCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: ScheduleCell.self)
    enum Kind {
        case top
        case middle
        case bottom
    }
    let label = UILabel()
    let toggle = UISwitch()
    let divider = UIView()
    var action: (Bool) -> Void = { _ in }
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
        kind = .middle
        action = { _ in }
    }
    @objc private func toggleValueChanged() {
        action(toggle.isOn)
    }
    func setupUI() {
        toggle.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
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
        stack.addArrangedSubview(toggle)

        contentView.backgroundColor = .App.background
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = []
    }
}
