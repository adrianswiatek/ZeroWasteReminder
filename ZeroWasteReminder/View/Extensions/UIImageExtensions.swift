import UIKit

public extension UIImage {
    static var more: UIImage { .bySystemName("ellipsis.circle") }
    static var filter: UIImage { .bySystemName("line.horizontal.3.decrease.circle") }
    static var filterActive: UIImage { .bySystemName("line.horizontal.3.decrease.circle.fill") }
    static var sortAscending: UIImage { .bySystemName("arrow.up.circle") }
    static var sortDescending: UIImage { .bySystemName("arrow.down.circle") }
    static var xmark: UIImage { .bySystemName("xmark") }
    static var calendar: UIImage { .bySystemName("calendar") }
    static var plus: UIImage { .bySystemName("plus") }

    private static func bySystemName(_ systemName: String) -> UIImage {
        guard let image = UIImage(systemName: systemName) else {
            preconditionFailure("Unable to create an image.")
        }
        return image
    }
}
