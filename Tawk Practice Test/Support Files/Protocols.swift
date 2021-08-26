//
//  DatabaseManager.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/19/21.
//

import Foundation
import UIKit

// MARK:- Coordinator Protocol
protocol Coordinator{
    var navigation: UINavigationController? { get set }
    var isAnimatable: Bool { get set }
}

// MARK:- MVVM Protocols

// protocol to be implemented by table view cell for mapping data from view model
protocol DataTableViewCell{
    func configure(viewModel: DataViewModel)
}

// protocol to be implemented by models
protocol DataModel{}

// The adoptor of this protocol must handle logic for data binding b/w model and view model
// and expose view model to views
protocol DataViewModelProvider{}

// protocol to be implemented by view models
protocol DataViewModel{
    func configure(model: DataModel)
}

// MARK:- Data Persistent protocols
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
