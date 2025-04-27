import UIKit

final class EditCategoryViewController: UIViewController {
    private let viewModel: ViewModel
    private let textField = UITextField()
    private let actionButton = UIButton(type: .system)
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Interface
extension EditCategoryViewController {
    struct ViewModel {
        var category: TrackerCategory?
        var action: (TrackerCategory) -> Void
    }
}

// MARK: - Implementation

extension UIColor {
    var uiImage: UIImage {
        let rect = CGRect(origin: .zero, size: .init(width: 1, height: 1))
        return UIGraphicsImageRenderer(bounds: rect).image { context in
            self.setFill()
            context.fill(rect)
        }
    }
}

extension EditCategoryViewController {
    @objc fileprivate func onButtonTap() {
        guard let text = textField.text, !text.isEmpty
        else { return }
        viewModel.action(.init(name: text))
        dismiss(animated: true)
    }
    
    fileprivate func setupButton() {
        actionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        actionButton.layer.cornerRadius = 16
        actionButton.layer.masksToBounds = true
        actionButton.setTitle("Готово", for: .normal)
        actionButton.setTitleColor(.App.white, for: .normal)
        actionButton.setBackgroundImage(UIColor.App.black.uiImage, for: .normal)
        actionButton.setTitleColor(.white, for: .disabled)
        actionButton.setBackgroundImage(UIColor.App.gray.uiImage, for: .disabled)
        actionButton.addTarget(
            self,
            action: #selector(onButtonTap),
            for: .touchUpInside
        )

        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                actionButton.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 20
                ),
                actionButton.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -20
                ),
                actionButton.heightAnchor.constraint(equalToConstant: 60),
                actionButton.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -16
                ),
            ]
        )
    }
    func updateButtonState() {
        let text = textField.text ?? ""
        actionButton.isEnabled = !text.isEmpty
    }
    
    @objc fileprivate func onTextFieldDidChange() {
        updateButtonState()
    }

    fileprivate func setupTextField() {
        let container = UIView()
        container.backgroundColor = .App.background
        container.layer.cornerRadius = 16

        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            container.heightAnchor.constraint(equalToConstant: 75),

        ])
        
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [
                .foregroundColor: UIColor.App.gray
            ]
        )
        textField.text = viewModel.category?.name
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .App.black
        textField.addTarget(
            self,
            action: #selector(onTextFieldDidChange),
            for: .editingChanged
        )
        
        container.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: container.topAnchor, constant: 27),
        ])
    }
    
    fileprivate func setupUI() {
        title = "Новая категория"
        view.backgroundColor = .App.white

        setupTextField()
        setupButton()
        updateButtonState()
    }
}

#Preview {
    UINavigationController(
        rootViewController: EditCategoryViewController(
            viewModel: .init(category: .init(name: "Test")) { print($0) }
        )
    )
}
