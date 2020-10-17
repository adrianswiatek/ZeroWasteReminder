import CoreData

public final class CoreDataStack {
    public let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ZeroWasteReminder")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
