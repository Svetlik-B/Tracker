import UIKit

final class EditCategoryViewController: UIViewController {
    
}

// MARK: - Interface
extension EditCategoryViewController {
    struct ViewModel {
        var category: TrackerCategory?
        var action: (TrackerCategory?) -> Void
    }
}
