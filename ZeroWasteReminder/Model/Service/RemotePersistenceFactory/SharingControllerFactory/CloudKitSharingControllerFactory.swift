import CloudKit
import UIKit

public final class CloudKitSharingControllerFactory: SharingControllerFactory {
    private let configuration: CloudKitConfiguration

    public init(configuration: CloudKitConfiguration) {
        self.configuration = configuration
    }

    public func build() -> UIViewController {
        UICloudSharingController { _, _ in }
    }
}
