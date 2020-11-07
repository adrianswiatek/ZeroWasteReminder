@testable import ZeroWasteReminder
import XCTest

class PhotosChangesetTests: XCTestCase {
    func test_hasChanges_notPhotosToSaveAndDelete_returnsFalse() {
        XCTAssertFalse(PhotosChangeset().hasChanges)
    }

    func test_hasChanges_withPhotosToSave_returnsTrue() {
        let image = createImage()
        let photoToSave = PhotoToSave(id: .fromUuid(UUID()), fullSizeImage: image, thumbnailImage: image)
        let changeset = PhotosChangeset()

        let updatedChangeset = changeset.withSavedPhoto(photoToSave)

        XCTAssertTrue(updatedChangeset.hasChanges)
    }

    func test_hasChanges_withPhotosToDelete_returnsTrue() {
        let changeset = PhotosChangeset()
        let updatedChangeset = changeset.withRemovedPhoto(id: .fromUuid(UUID()))
        XCTAssertTrue(updatedChangeset.hasChanges)
    }

    func test_withwithSavedPhoto_returnsUpdatedObject() {
        let image = createImage()
        let photoToSave = PhotoToSave(id: .fromUuid(UUID()), fullSizeImage: image, thumbnailImage: image)
        let changeset = PhotosChangeset()

        let updatedChangeset = changeset.withSavedPhoto(photoToSave)

        XCTAssertEqual(updatedChangeset.photosToSave.count, 1)
    }

    func test_withRemovedPhoto_returnsUpdatedObject() {
        let photoId = Id<Photo>.fromUuid(UUID())
        let changeset = PhotosChangeset()

        let updatedChangeset = changeset.withRemovedPhoto(id: photoId)

        XCTAssertEqual(updatedChangeset.idsToDelete.count, 1)
        XCTAssertEqual(updatedChangeset.idsToDelete[0], photoId)
    }

    func test_withRemovedPhoto_withExistingPhotoId_returnsExistingObject() {
        let photoId = Id<Photo>.fromUuid(UUID())
        let changeset = PhotosChangeset().withRemovedPhoto(id: photoId)

        let updatedChangeset = changeset.withRemovedPhoto(id: photoId)

        XCTAssertEqual(changeset, updatedChangeset)
    }
}

private extension PhotosChangesetTests {
    func createImage() -> UIImage {
        let expectation = self.expectation(description: "")
        var image: UIImage!

        UIGraphicsImageRenderer(size: .init(width: 10, height: 10)).image {
            image = $0.currentImage
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        return image
    }
}
