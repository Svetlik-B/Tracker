import CoreData
import UIKit

final class TrackerHeader: UICollectionReusableView {
    static let reuseIdentifier = String(describing: TrackerHeader.self)
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    func setUp() {
        addSubview(label)
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
}
