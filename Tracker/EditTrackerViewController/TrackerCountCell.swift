import UIKit

class TrackerCountCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerCountCell.self)
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
        label.font = .systemFont(ofSize: 32, weight: .bold)
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                label.centerXAnchor.constraint(
                    equalTo: contentView.centerXAnchor
                ),
                label.widthAnchor.constraint(
                    lessThanOrEqualTo: contentView.widthAnchor
                ),
                label.centerYAnchor.constraint(
                    equalTo: contentView.centerYAnchor
                ),
            ]
        )
    }
}
