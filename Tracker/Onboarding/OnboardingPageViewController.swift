import UIKit

final class OnboardingPageViewController: UIViewController {
    let viewModel: ViewModel

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
extension OnboardingPageViewController {
    struct ViewModel {
        var text: String
        var uiImage: UIImage?
        var action: () -> Void
    }
}

// MARK: - Implementation
extension OnboardingPageViewController {
    fileprivate func setupUI() {
        let imageView = UIImageView(image: viewModel.uiImage)
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        let label = UILabel()
        label.text = viewModel.text
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .App.onboardingText
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                label.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 16
                ),
                label.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -16
                ),
                label.centerYAnchor.constraint(
                    equalTo: view.centerYAnchor, constant: 60
                ),
            ]
        )

        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .App.onboardingText
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            button.heightAnchor.constraint(equalToConstant: 60),
        ])
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
    }

    @objc fileprivate func handleButtonTap() {
        viewModel.action()
    }
}

#Preview {
    OnboardingPageViewController(
        viewModel: .init(
            text: "Отслеживайте только то, что хотите",
            uiImage: .onboarding1,
            action: { print("Action!") }
        )
    )
}
