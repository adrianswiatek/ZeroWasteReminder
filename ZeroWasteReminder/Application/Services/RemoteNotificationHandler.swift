import Combine
import UIKit

public final class RemoteNotificationHandler {
    private let eventDispatcher: EventDispatcher
    private let eventBuilders: [RemoteNotification.Category: ([AnyHashable: Any]) -> RemoteEventBuilder]

    public init(eventDispatcher: EventDispatcher) {
        self.eventDispatcher = eventDispatcher
        self.eventBuilders = [
            .item: ItemRemoteEventBuilder.init,
            .list: ListRemoteEventBuilder.init,
            .photo: PhotoRemoteEventBuilder.init
        ]
    }

    public func received(with userInfo: [AnyHashable: Any]) {
        guard let category = RemoteNotification.Category(from: userInfo) else { return }

        eventBuilders[category]?(userInfo).build().map {
            eventDispatcher.dispatch($0)
        }
    }
}
