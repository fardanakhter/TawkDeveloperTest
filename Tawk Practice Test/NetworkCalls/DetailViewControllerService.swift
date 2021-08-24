//
//  DetailViewControllerService.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/22/21.
//

import Foundation

struct DetailViewControllerService{
    
    static let shared = DetailViewControllerService()
    
    func getUserDetail(username: String, completion: @escaping (ListDetailDataType?, Bool) -> Void){
         
        Router.makeRequest(url: .userProfile(username: username), method: .get) {
            (result: Result<ListDetailDataType, Router.ReponseError>) in
            
            switch result{
            case .success(let model):
                print(model)
                completion(model, true)
                
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
