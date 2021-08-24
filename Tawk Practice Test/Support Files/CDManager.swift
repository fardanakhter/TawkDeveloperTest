//
//  CDManager.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/19/21.
//

import Foundation
import CoreData
import UIKit

// MARK:- DatabaseManager Concrete Class
class CDManager: DatabaseManager{
    typealias T = CDModel
    
    var context: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer!
    var enityType: CoreDataEntity = .none
    
    init(entity: CoreDataEntity) {
        enityType = entity
        setupDatabase()
    }
    
    func saveContext(){
        //guard context.hasChanges else {return}
        
        do {
            try context.save()
        } catch {
            print("failed to save context!")
        }
    }
    
    func setupDatabase() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.persistentContainer = appDelegate.persistentContainer
        self.context = persistentContainer.viewContext
    }
    
    func addDatabaseModel(model: CDModel) {
        context.insert(model)
        saveContext()
    }
    
    func fetchDatabaseModels() -> [CDModel] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: enityType.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.returnsObjectsAsFaults = false
        if let results = try? context.fetch(fetchRequest) as? [CDModel]{
            return results
        }
        return []
    }
    
    // fetch model from database with username and/or note
    func fetchDatabaseModel(username: String, note: String) -> [CDModel] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: enityType.rawValue)
        //let matchesPredicate = NSPredicate(format: "first_name =%@", "test")
        //let matchesPredicate = NSPredicate(format: "id =%@", "test")
        
        let containsPredicateUsername: NSPredicate?
        let containsPredicateNote: NSPredicate?
        
        var subPrecidates = [NSPredicate]()
        
        // 'login' for username match
        if !username.isEmpty{
            containsPredicateUsername = NSPredicate(format: "login CONTAINS[c] '\(username)'") // [c] matches with case insensitive
            subPrecidates.append(containsPredicateUsername!)
        }
        
        // 'note' for note match
        if !note.isEmpty{
            containsPredicateNote = NSPredicate(format: "note CONTAINS[c] '\(note)'") // [c] matches with case insensitive
            subPrecidates.append(containsPredicateNote!)
        }
        
        guard !subPrecidates.isEmpty else{ return [] }
        
        let orPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: subPrecidates)
        fetchRequest.predicate = orPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.returnsObjectsAsFaults = false
        
        if let results = try? context.fetch(fetchRequest) as? [CDModel]{
            return results
        }
        return []
    }
    
    func deleteDatabaseModel(model: CDModel) {
        context.delete(model)
        saveContext()
    }
    
    func deleteAll() {
        // Specify a batch to delete with a fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: enityType.rawValue)
        
        // Create a batch delete request for the
        // fetch request
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )
        
        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the
        // deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs
        
        // Get a reference to a managed object context
        let context = persistentContainer.viewContext
        
        // Perform the batch delete
        let batchDelete = try! context.execute(deleteRequest)
            as? NSBatchDeleteResult
        
        guard let deleteResult = batchDelete?.result
                as? [NSManagedObjectID]
        else { return }
        
        let deletedObjects: [AnyHashable: Any] = [
            NSDeletedObjectsKey: deleteResult
        ]
        
        // Merge the delete changes into the managed
        // object context
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )
    }
}




