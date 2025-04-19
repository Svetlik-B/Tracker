import UIKit

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: SectionHeaderView.self)
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    func setupUI() {
        label.font = .systemFont(ofSize: 19, weight: .medium)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
