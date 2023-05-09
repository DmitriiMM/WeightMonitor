import UIKit
import CoreData

enum WeightRecordStoreError: Error {
    case decodingErrorInvalidDate
    case decodingErrorInvalidWeight
    case decodingErrorInvalidRecord
}

struct WeightRecordStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol WeightRecordStoreDelegate: AnyObject {
    func store(_ store: WeightRecordStore, didUpdate update: WeightRecordStoreUpdate)
}

final class WeightRecordStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: WeightRecordStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<WeightRecordStoreUpdate.Move>?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<WeightRecordCoreData> = {
        let fetchRequest = NSFetchRequest<WeightRecordCoreData>(entityName: "WeightRecordCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \WeightRecordCoreData.date, ascending: false)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistantConteiner.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var weightRecords: [WeightRecord] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let weightRecords = try? objects.map({ try self.weightRecord(from: $0) })
        else { return [] }
        return weightRecords
    }
    
    func addNewWeightRecord(_ weightRecord: WeightRecord) throws {
        let newWeightRecord = WeightRecordCoreData(context: context)
        newWeightRecord.weight = weightRecord.weight
        newWeightRecord.date = weightRecord.date
        
        try context.save()
    }
    
    func deleteExistingWeightRecord(at indexPath: IndexPath) throws {
        
        context.delete(fetchedResultsController.object(at: IndexPath(row: indexPath.row, section: 0)))
        
        try context.save()
    }
    
    func updateExistingWeightRecord(at indexPath: IndexPath, with record: WeightRecord) throws {
        let existingWeightRecord = fetchedResultsController.object(at: IndexPath(row: indexPath.row, section: 0))
        existingWeightRecord.weight = record.weight
        existingWeightRecord.date = record.date
        
        try context.save()
    }
    
    func makeWeightRecord(from weightRecord: WeightRecord) throws -> WeightRecordCoreData {
        let weightRecordCoreData = WeightRecordCoreData(context: context)
        weightRecordCoreData.weight = weightRecord.weight
        weightRecordCoreData.date = weightRecord.date
        
        return weightRecordCoreData
    }
    
    func weightRecord(from weightRecordCorData: WeightRecordCoreData) throws -> WeightRecord {
        let weight = weightRecordCorData.weight
        guard let date = weightRecordCorData.date else {
            throw WeightRecordStoreError.decodingErrorInvalidDate
        }
        return WeightRecord(weight: weight, date: date)
    }
}

extension WeightRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<WeightRecordStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: WeightRecordStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!,
                movedIndexes: movedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.row)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.row)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.row)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.row, newIndex: newIndexPath.row))
        @unknown default:
            fatalError()
        }
    }
}
