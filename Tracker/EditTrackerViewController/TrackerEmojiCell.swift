import UIKit

final class TrackerEmojiCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerEmojiCell.self)
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    private func setupUI() {
        contentView.layer.cornerRadius = 16

        label.font = .systemFont(ofSize: 32, weight: .bold)
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 2.5),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
}
