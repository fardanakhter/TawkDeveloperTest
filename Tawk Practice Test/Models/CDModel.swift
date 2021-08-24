//
//  CDModel.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/19/21.
//

import Foundation
import CoreData

public extension CodingUserInfoKey {
    // Helper property to retrieve the context
    // This is to store context for first hand access to context, instead of explicitly passing into object
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

// This is for saving NSManagedObjectContext with in Codable Object instead of explicitly passing
enum CoreDataEntity: String {
    case user = "UserModel"
    case none
    
    func entityDescription(context: NSManagedObjectContext) -> NSEntityDescription?{
        return NSEntityDescription.entity(forEntityName: self.rawValue, in: context)
    }
}

// MARK:- DatabaseModelProtocol Concrete Class
class CDModel: NSManagedObject, DatabaseModelProtocol, Codable, DataModel{
    
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
              let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext
              //,let entity = NSEntityDescription.entity(forEntityName: CoreDataEntity.none.rawValue, in: managedObjectContext)
        else {
            fatalError("Failed to decode entity!")
        }
        self.init(entity: NSEntityDescription(), insertInto: managedObjectContext)
        try self.decode(from: decoder)
    }
    
    // MARK: - Decodable
    public func decode(from decoder: Decoder) throws {
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {}
}
