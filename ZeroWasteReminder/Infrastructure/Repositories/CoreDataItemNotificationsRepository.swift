import CoreData

public final class CoreDataItemNotificationsRepository: ItemNotificationsRepository {
    private let viewContext: NSManagedObjectContext
    private let mapper: CoreDataMapper

    public init(coreDataStack: CoreDataStack, mapper: CoreDataMapper) {
        self.viewContext = coreDataStack.persistentContainer.viewContext
        self.mapper = mapper
    }

    public func fetchAll() -> [ItemNotification] {
        fetchEntities(by: .init(value: true)).map {
            mapper.map($0).toNotification()
        }
    }

    public func fetchAll(from list: List) -> [ItemNotification] {
        fetchEntities(by: .init(format: "listId == %@", list.id.asString)).map {
            mapper.map($0).toNotification()
        }
    }

    public func fetch(for item: Item) -> ItemNotification? {
        fetchEntity(for: item.id).map { mapper.map($0).toNotification() }
    }

    public func update(for item: Item) {
        let entity = fetchEntity(for: item.id) ?? NotificationEntity(context: viewContext)
        entity.updateBy(item)
        try? viewContext.save()
    }

    public func remove(by itemIds: [Id<Item>]) {
        remove(fetchEntities(by: .init(format: "itemId IN %@", itemIds.map { $0.asString })))
    }

    public func remove(by itemId: Id<Item>) {
        fetchEntity(for: itemId).map { remove(.just($0)) }
    }

    public func remove(by listId: Id<List>) {
        remove(fetchEntities(by: .init(format: "listId == %@", listId.asString)))
    }

    private func fetchEntity(for itemId: Id<Item>) -> NotificationEntity? {
        fetchEntities(by: .init(format: "itemId == %@", itemId.asString)).first
    }

    private func fetchEntities(by predicate: NSPredicate) -> [NotificationEntity] {
        let request: NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
        request.predicate = predicate
        return (try? viewContext.fetch(request)) ?? []
    }

    private func remove(_ entities: [NotificationEntity]) {
        entities.forEach { viewContext.delete($0) }
        try? viewContext.save()
    }
}
