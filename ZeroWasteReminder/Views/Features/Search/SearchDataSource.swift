import UIKit

public final class SearchDataSource: UITableViewDiffableDataSource<SearchDataSource.Section, String> {

}

extension SearchDataSource {
    public enum Section {
        case main
    }
}
