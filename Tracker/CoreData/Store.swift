import CoreData
import UIKit

enum Store {
    static let persistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Ошибка создания стора \(error), \(error.userInfo)")
            }
        })
        print("Стор загружен")
        return container
    }()
}
