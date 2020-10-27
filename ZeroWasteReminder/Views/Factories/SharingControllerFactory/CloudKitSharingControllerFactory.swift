import CloudKit
import UIKit

public final class CloudKitSharingControllerFactory: SharingControllerFactory {
    private let configuration: CloudKitConfiguration

    public init(configuration: CloudKitConfiguration) {
        self.configuration = configuration
    }

    public func create() -> UIViewController {
        UICloudSharingController { _, _ in }
    }
}
