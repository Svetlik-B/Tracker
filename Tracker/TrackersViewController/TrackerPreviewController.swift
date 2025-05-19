import UIKit

class TrackerPreviewController: UIViewController {
    struct ViewModel {
        var size: CGSize
        var color: UIColor
        var emoji: String
        var text: String
    }
    var viewModel = ViewModel(
        size: .init(width: 140, height: 90),
        color: .red,
        emoji: "😀",
        text: "Hello, World!"
    )
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = viewModel.size
        view.backgroundColor = viewModel.color

        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 3
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let attributedString = NSAttributedString(
            string: viewModel.text,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.white,
            ]
        )
        label.attributedText = attributedString
        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                label.centerXAnchor
                    .constraint(equalTo: view.centerXAnchor),
                label.leadingAnchor
                    .constraint(
                        equalTo: view.leadingAnchor, constant: 12),
                label.trailingAnchor
                    .constraint(
                        equalTo: view.trailingAnchor, constant: -12),
                label.topAnchor
                    .constraint(greaterThanOrEqualTo: view.topAnchor, constant: 12),
                label.bottomAnchor
                    .constraint(
                        lessThanOrEqualTo: view.bottomAnchor, constant: -12),
            ]
        )

        let emojiLabel = UILabel()
        emojiLabel.text = viewModel.emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 13)
        emojiLabel.textAlignment = .center

        let emojiBackground = UIView()
        emojiBackground.backgroundColor = .white.withAlphaComponent(0.3)
        emojiBackground.layer.cornerRadius = 12

        emojiBackground.addSubview(emojiLabel)
        view.addSubview(emojiBackground)

        emojiBackground.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            emojiBackground.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            emojiBackground.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 12),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
        ])
    }
}
