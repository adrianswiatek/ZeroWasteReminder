import UserNotifications

public struct ItemUserNotificationsResheduler: ItemNotificationsRescheduler {
    private let itemNotificationsRepository: ItemNotificationsRepository
    private let notificationRequestFactory: ItemNotificationRequestFactory
    private let userNotificationCenter: UNUserNotificationCenter

    public init(
        itemNotificationsRepository: ItemNotificationsRepository,
        notificationRequestFactory: ItemNotificationRequestFactory,
        userNotificationCenter: UNUserNotificationCenter
    ) {
        self.itemNotificationsRepository = itemNotificationsRepository
        self.notificationRequestFactory = notificationRequestFactory
        self.userNotificationCenter = userNotificationCenter
    }

    public func reschedule() {
        DispatchQueue.global(qos: .background).async {
            userNotificationCenter.removeAllPendingNotificationRequests()

            itemNotificationsRepository.fetchAll()
                .filter(notificationRequestFactory.canCreate)
                .map(notificationRequestFactory.create)
                .forEach(userNotificationCenter.add)
        }
    }
}

private extension UNUserNotificationCenter {
    func add(_ request: UNNotificationRequest) {
        add(request, withCompletionHandler: nil)
    }
}
