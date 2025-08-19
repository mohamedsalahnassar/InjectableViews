import Foundation
import CoreData

/// A common base class for Core Data entities providing a stable identifier and
/// main-actor isolation.
///
/// By isolating the `Identifiable` conformance to the main actor we ensure that
/// accessing the managed object's identifier is always performed on the correct
/// thread and avoids data races under Swift 6's strict concurrency model.
@MainActor
open class ManagedEntity: NSManagedObject {
    /// A stable unique identifier for the entity.
    @NSManaged public var id: UUID
}

@MainActor
extension ManagedEntity: Identifiable {}
