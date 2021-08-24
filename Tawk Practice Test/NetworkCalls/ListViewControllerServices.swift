//
//  ListViewControllerServices.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/21/21.
//

import Foundation

struct ListViewControllerServices{
    
    static let shared = ListViewControllerServices()
    
    func getListOfUsers(page: Int, completion: @escaping (ListDataType?, Bool) -> Void){
        
        let manager = CDManager(entity: .user)
        manager.deleteAll()
        
        Router.makeRequest(url: .userList(since: page), method: .get) {
            (result: Result<ListDataType, Router.ReponseError>) in
            
            switch result{
            
            case .success(let models):
                completion(models, true)
                
            case .failure(let error):
                switch error {
                case .noDataFound:
                    break
                case .parseFailed:
                    break
                case .serviceFailed(let errorString):
                    print(errorString)
                case .invalidURL:
                    break
                }
                
                completion(nil, false)
            }
        }
    }
}
