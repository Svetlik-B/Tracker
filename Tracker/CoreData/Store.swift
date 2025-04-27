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
        // не удалять: нужно для отладки
        // clearData(context: container.viewContext)
        // ensureOneCategoryExits(context: container.viewContext)
        print("Стор загружен")
        return container
    }()
}

// MARK: - Implementation
extension Store {
    fileprivate static func clearData(context: NSManagedObjectContext) {
        print("удаляем все данные")
        let request = TrackerCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(request)
            for category in categories {
                context.delete(category)
            }
        } catch {
            print("Ошибка очистки базы данных \(error.localizedDescription)")
        }
    }
    fileprivate static func ensureOneCategoryExits(context: NSManagedObjectContext) {
        let request = TrackerCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(request)
            if categories.isEmpty {
                print("Добавляем одну категорию")
                let category = TrackerCategoryCoreData(context: context)
                category.name = "Тестовая категория"
                try context.save()
            }
        } catch {
            print("Ошибка загрузки категорий \(error.localizedDescription)")
        }
    }
}
