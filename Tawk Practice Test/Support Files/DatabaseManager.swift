//
//  DatabaseManager.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/19/21.
//

import Foundation

protocol DataTableViewCell{
    func configure(viewModel: DataViewModel)
}

protocol DataModel{}

protocol DataViewModel{
    //func configure(model: DataModel, indexPath: IndexPath)
    func configure(model: DataModel)
}

//extension DataViewModel{
//    func configure(model: DataModel){}
//}

protocol DatabaseModelProtocol{}

protocol DatabaseManager{
    
    associatedtype T: DatabaseModelProtocol
    
    //define CRUD functions here
    
    //Setup Code
    func setupDatabase()
    //func createDatabaseSchema()
    
    //Create
    func addDatabaseModel(model: T)
    
    //Update
    //func updateDatabaseModel(model: T)
    
    //Delete
    func deleteDatabaseModel(model: T)
    func deleteAll()
    
    //Read
    func fetchDatabaseModels() -> [T]
}
