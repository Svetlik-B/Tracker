import UIKit

final class TrackerScheduleCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackerScheduleCell.self)
    let scheduleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    private func setupUI() {
        let divider = UIView()
        divider.backgroundColor = .divider
        contentView.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            divider.topAnchor.constraint(equalTo: contentView.topAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),
        ])

        contentView.backgroundColor = .App.background
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner,
        ]

        let hStack = UIStackView()
        hStack.axis = .horizontal

        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 2

        hStack.addArrangedSubview(vStack)
        // добавить spacer
        hStack.addArrangedSubview(UIStackView())

        let label = UILabel()
        label.text = "Расписание"
        label.textColor = .App.black
        vStack.addArrangedSubview(label)

        scheduleLabel.textColor = .App.gray
        vStack.addArrangedSubview(scheduleLabel)

        let chevron = UIImageView(image: .cheveron)
        chevron.contentMode = .center
        hStack.addArrangedSubview(chevron)

    }
}
