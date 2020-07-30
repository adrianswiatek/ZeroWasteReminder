import UIKit

public extension UIImage {
    static func fromSymbol(_ symbol: Symbol, withConfiguration configuration: Configuration? = nil) -> UIImage {
        guard let image =  UIImage(systemName: symbol.rawValue, withConfiguration: configuration) else {
            preconditionFailure("Unable to create an image.")
        }
        return image
    }

    func withColor(_ color: UIColor) -> UIImage {
        withRenderingMode(.alwaysOriginal).withTintColor(color)
    }

    enum Symbol: String {
        case arrowDownCircle = "arrow.down.circle"
        case arrowUpCircle = "arrow.up.circle"
        case arrowUpLeftAndArrowDownRight = "arrow.up.left.and.arrow.down.right"
        case calendar = "calendar"
        case calendarBadgeMinus = "calendar.badge.minus"
        case calendarBadgePlus = "calendar.badge.plus"
        case cameraFill = "camera.fill"
        case cameraOnRectangleFill = "camera.on.rectangle.fill"
        case checkmark = "checkmark"
        case chevronRight = "chevron.right"
        case ellipsisCircle = "ellipsis.circle"
        case lineHorizontal3DecreaseCircle = "line.horizontal.3.decrease.circle"
        case lineHorizontal3DecreaseCircleFill = "line.horizontal.3.decrease.circle.fill"
        case listDash = "list.dash"
        case multiplyCircleFill = "multiply.circle.fill"
        case pencil = "pencil"
        case photoOnRectangle = "photo.on.rectangle"
        case photoOnRectangleFill = "photo.on.rectangle.fill"
        case plus = "plus"
        case textBadgePlus = "text.badge.plus"
        case trash = "trash"
        case xmark = "xmark"
        case xmarkCircleFill = "xmark.circle.fill"
    }
}
