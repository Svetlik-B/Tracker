import UIKit

final class TrackerColorCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerColorCell.self)
    let colorView = UIView()
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
        colorView.layer.cornerRadius = 8
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
}
