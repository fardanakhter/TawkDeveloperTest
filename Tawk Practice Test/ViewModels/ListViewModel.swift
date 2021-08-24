//
//  ListViewModel.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/21/21.
//

import Foundation

// MARK:- ViewModel
class ListViewModel: DataViewModel{
    
    var imageURL: String = ""
    var username: String = ""
    var hasNote: Bool = false
    var hasInvertedImage: Bool = false 
    
    func configure(model: DataModel) {
        
        guard let model = model as? CDUserModel else {return}
        
        imageURL = model.avatarURL ?? ""
        username = model.login ?? ""
        hasNote = (model.hasNote ?? 0) == 0 ? false : true
    }
}

// This class is responsible for providing updated ViewModel to UIViewController
class ListDataRepresenter: NSObject{
    
    // MARK:- Closures for callbacks
    var loadingUpdateCallBack: ((Bool) -> Void) = {(_) in }
    var networkDataCallBack: (([ListViewModel]) -> Void) = {(_) in }
    var searchedDataCallBack: (([ListViewModel]?) -> Void) = {(_) in }
    
    // CoreData manager
    private let manager = CDManager(entity: .user)
    // Page index tracker
    private var currentLoadedPageId : Int = 0
    
    private var isLoading: Bool = false {
        didSet{
            self.loadingUpdateCallBack(isLoading)
        }
    }
    
    // Data for list of users
    private var data: ListDataType? {
        didSet{
            let viewModels = self.mapDataModelToViewModel(dataModels: data ?? [])
            self.networkDataCallBack(viewModels)
        }
    }
    
    // Data for list of searched users
    private var searchedData: ListDataType? {
        didSet{
            if let searchedData = searchedData, !searchedData.isEmpty{
                let viewModels = self.mapDataModelToViewModel(dataModels: searchedData)
                self.searchedDataCallBack(viewModels)
                return
            }
            self.searchedDataCallBack(nil)
        }
    }
    
    override init() {
        super.init()
    }
    
    func didSearchText(text: String){
        self.searchedData = manager.fetchDatabaseModel(username: text, note: text) as? ListDataType
    }
    
    // Network call for updated data
    func networkCall(){
        usersListAPI(page: currentLoadedPageId)
    }
    
    // Cache Data
    func getCacheData(){
        if let models = manager.fetchDatabaseModels() as? ListDataType{
            updatePageIndex(items: models)
            data = models
        }
    }
    
    private func emptyCacheAndList(){
        manager.deleteAll()
        //guard data != nil else { return }
        data?.removeAll()
    }
    
    // MARK:- DataModel to ViewModel Binding
    // This maps datamodels into viewmodels and return
    private func mapDataModelToViewModel(dataModels: [CDModel]) -> [ListViewModel]{
        var viewModels = [ListViewModel]()
        dataModels.forEach{
            let viewModel = ListViewModel()
            viewModel.configure(model: $0)
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    // MARK:- Network Call
    private func usersListAPI(page: Int){
        if page == 0 { emptyCacheAndList() }
        isLoading = true
        
        ListViewControllerServices.shared.getListOfUsers(page: page){ (data, status) in
            //self.hideLoader()
            self.isLoading = false
            if status && data != nil {
                self.handleDataFromNetworkCall(newList: data!)
            }
        }
    }
    
    // MARK:- Method that handles data from Network Call
    // if list NOT already updated
    // then append new data models with existing and reloads view
    private func handleDataFromNetworkCall(newList: ListDataType){
        // This check old page index with new page index
        let currentindex = currentLoadedPageId
        updatePageIndex(items: newList)
        
        if data?.isEmpty ?? true || currentindex < currentLoadedPageId {
            // saves new data to cache
            self.data?.append(contentsOf: newList) // append new list to existing
            
            // DEBUG: Here this line create a bug case results in old models to be invalidated on adding new ones
            self.manager.saveContext()
        }
    }
    
    // This updates next page index
    private func updatePageIndex(items: ListDataType){
        currentLoadedPageId = items.last?.id as? Int ?? 0
        print(currentLoadedPageId)
    }
}
