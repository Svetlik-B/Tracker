import UIKit

final class TrackerCell: UICollectionViewCell {
    struct ViewModel {
        var emoji: String
        var text: String
        var color: UIColor
        var count: Int
        var completed: Bool
        var action: () -> Void
    }

    func configure(model: ViewModel) {
        colorView.backgroundColor = model.color
        button.tintColor = model.color
        cellLabel.text = model.text
        emojiLabel.text = model.emoji
        action = model.action
        dayLabel.text = model.count.days
        button.setImage(
            model.completed
                ? .done.withTintColor(.App.white)
                : .smallPlus.withTintColor(.App.white),
            for: .normal
        )
        button.layer.opacity = model.completed ? 0.3 : 1
    }

    static let reuseIdentifier = String(describing: TrackerCell.self)
    private let colorView = UIView()
    private let dayLabel = UILabel()
    private let button = UIButton(type: .custom)
    private let cellLabel = UILabel()
    private let emojiLabel = UILabel()
    private var action = {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    @objc private func didTapButton() {
        action()
    }

    override func prepareForReuse() {
        action = {}
    }

    func setUp() {
        colorView.layer.cornerRadius = 16
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor =
            UIColor.App.gray
            .withAlphaComponent(0.3)
            .cgColor
        cellLabel.textAlignment = .left
        cellLabel.numberOfLines = 3
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let attributedString = NSAttributedString(
            string: "Бабушка прислала открытку в вотсапе",
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.white,
            ]
        )
        cellLabel.attributedText = attributedString
        colorView.addSubview(cellLabel)

        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                cellLabel.centerXAnchor
                    .constraint(equalTo: colorView.centerXAnchor),
                cellLabel.leadingAnchor
                    .constraint(
                        equalTo: colorView.leadingAnchor, constant: 12),
                cellLabel.trailingAnchor
                    .constraint(
                        equalTo: colorView.trailingAnchor, constant: -12),
                cellLabel.topAnchor
                    .constraint(greaterThanOrEqualTo: colorView.topAnchor, constant: 12),
                cellLabel.bottomAnchor
                    .constraint(
                        lessThanOrEqualTo: colorView.bottomAnchor, constant: -12),
            ]
        )

        emojiLabel.text = "🐶"
        emojiLabel.font = UIFont.systemFont(ofSize: 13)
        emojiLabel.textAlignment = .center

        let emojiBackground = UIView()
        emojiBackground.backgroundColor = .white.withAlphaComponent(0.3)
        emojiBackground.layer.cornerRadius = 12

        emojiBackground.addSubview(emojiLabel)
        colorView.addSubview(emojiBackground)

        emojiBackground.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            emojiBackground.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiBackground.leadingAnchor.constraint(
                equalTo: colorView.leadingAnchor, constant: 12),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
        ])

        dayLabel.font = .systemFont(ofSize: 12, weight: .medium)

        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.setBackgroundImage(
            .circle.withRenderingMode(.alwaysTemplate),
            for: .normal
        )

        let hStack = UIStackView(arrangedSubviews: [dayLabel, button])
        hStack.axis = .horizontal
        hStack.spacing = 8

        let view = UIView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hStack)

        NSLayoutConstraint.activate(
            [
                colorView.heightAnchor.constraint(equalToConstant: 90),
                view.heightAnchor.constraint(equalToConstant: 58),
                hStack.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 12
                ),
                hStack.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -16
                ),
                hStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            ]
        )

        let stack = UIStackView(frame: contentView.frame)
        stack.axis = .vertical
        stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stack.addArrangedSubview(colorView)
        stack.addArrangedSubview(view)

        contentView.addSubview(stack)
    }
}
