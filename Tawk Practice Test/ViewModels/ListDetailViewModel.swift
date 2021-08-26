//
//  ListDetailViewModel.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/22/21.
//

import Foundation

typealias ListDetailDataType = CDUserModel

// MARK:- ViewModel
class ListDetailViewModel: DataViewModel{
    var username: String = ""
    var followers: Int?
    var following: Int?
    var name: String = ""
    var company: String = ""
    var blog: String = ""
    var note: String = ""
    var image: String = ""
    
    func configure(model: DataModel) {
        guard let model = model as? ListDetailDataType else { return }
        
        username = model.login ?? ""
        followers = model.followers as! Int?
        following = model.following as! Int?
        name = model.name ?? ""
        company = model.company ?? ""
        blog = model.blog ?? ""
        note = model.note ?? ""
        image = model.avatarURL ?? ""
    }
}


// This class is responsible for providing updated ViewModel to UIViewController
class ListDetailViewModelProvider: NSObject, DataViewModelProvider{
    
    // closures for completions
    var loadingUpdateCallBack: ((Bool) -> Void) = {(_) in }
    var networkDataCallBack: ((ListDetailViewModel) -> Void) = {(_) in }
    var savedNoteCallBack: (() -> Void) = {}
    
    private let manager: CDManager!
    private(set) var username: String
    
    init(username: String) {
        self.username = username
        self.manager = CDManager(entity: .user)
    }
    
    private var isLoading: Bool = false {
        didSet{
            self.loadingUpdateCallBack(isLoading)
        }
    }
    
    // Data for list of users
    private var data: ListDetailDataType! {
        didSet{
            let viewModel = ListDetailViewModel()
            viewModel.configure(model: data)
            self.networkDataCallBack(viewModel)
        }
    }
    
    // Saving note to data model
    func didSaveNote(note: String){
        data.hasNote = note == "" ? false : true
        data.note = note
        manager.saveContext()
        savedNoteCallBack()
    }
    
    // Network call for updated data
    func networkCall(){
        userProfileAPI()
    }
    
    // Mark:- Network Call
    private func userProfileAPI(){
        isLoading = true
        DetailViewControllerService.shared.getUserDetail(username: username) { (data, status) in
            self.isLoading = false
            if status && data != nil {
                // this data model is matched with one in cache, data values gets copied
                self.data = self.updateCacheWithNewData(model: data!)
            }
        }
    }
    
    // This updates cache model with new values from API
    private func updateCacheWithNewData(model: ListDetailDataType) -> ListDetailDataType{
        //update user with new values and save context
        let manager = CDManager(entity: .user)
        if let searchedModel = getModelfromCache(matching: model, by: manager) {
            // copy updated value to old cache
            searchedModel.clone(model: model)
            
            // remove new duplicat model
            manager.deleteDatabaseModel(model: model)
            return searchedModel
        }
        return model
    }
    
    // This get matching model from cache
    private func getModelfromCache(matching model: ListDetailDataType, by manager: CDManager) -> ListDetailDataType?{
        let cacheModels = manager.fetchDatabaseModels()
        
        // gets model from cache with same login But not same object id
        let filteredModels = (cacheModels as! [CDUserModel]).filter{
            ($0.login ?? "" ) == model.login && $0.objectID != model.objectID
        }
        
        if let filtered = filteredModels.first {
            return filtered
        }
        return nil
    }
}
