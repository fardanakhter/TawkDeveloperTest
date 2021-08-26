//
//  NetworkRouter.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/19/21.
//

import Foundation
import UIKit


let testingJsonData = """
[{
    "login": "mojombo",
    "id": 1,
    "node_id": "MDQ6VXNlcjE=",
    "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
    "gravatar_id": "",
    "url": "https://api.github.com/users/mojombo",
    "html_url": "https://github.com/mojombo",
    "followers_url": "https://api.github.com/users/mojombo/followers",
    "following_url": "https://api.github.com/users/mojombo/following{/other_user}",
    "gists_url": "https://api.github.com/users/mojombo/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/mojombo/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/mojombo/subscriptions",
    "organizations_url": "https://api.github.com/users/mojombo/orgs",
    "repos_url": "https://api.github.com/users/mojombo/repos",
    "events_url": "https://api.github.com/users/mojombo/events{/privacy}",
    "received_events_url": "https://api.github.com/users/mojombo/received_events",
    "type": "User",
    "site_admin": false
  },
  {
    "login": "defunkt",
    "id": 200,
    "node_id": "MDQ6VXNlcjI=",
    "avatar_url": "https://avatars.githubusercontent.com/u/2?v=4",
    "gravatar_id": "",
    "url": "https://api.github.com/users/defunkt",
    "html_url": "https://github.com/defunkt",
    "followers_url": "https://api.github.com/users/defunkt/followers",
    "following_url": "https://api.github.com/users/defunkt/following{/other_user}",
    "gists_url": "https://api.github.com/users/defunkt/gists{/gist_id}",
    "starred_url": "https://api.github.com/users/defunkt/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/defunkt/subscriptions",
    "organizations_url": "https://api.github.com/users/defunkt/orgs",
    "repos_url": "https://api.github.com/users/defunkt/repos",
    "events_url": "https://api.github.com/users/defunkt/events{/privacy}",
    "received_events_url": "https://api.github.com/users/defunkt/received_events",
    "type": "User",
    "site_admin": false
  }]
""".data(using: .utf8)!

struct Router{
    
    // MARK:- ReponseError
    enum ReponseError: Error{
        case invalidURL
        case noDataFound
        case parseFailed
        case serviceFailed(String)
        
        var description: String {
            switch self {
            case .serviceFailed(let errorString):
                return errorString
            default:
                return self.localizedDescription
            }
        }
    }
    
    // MARK:- HttpMethod
    enum HttpMethod: String{
        case get  = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    typealias ResponseType<T> = (Result<T, ReponseError>) -> Void
    
    // Global Queue for making serial API calls
    static var dispatchQueueGlobal = DispatchQueue.global()
    static var dispatchQueueMain = DispatchQueue.main
    
    // MARK:- Method for making Network Calls
    static func makeRequest<T: Codable>(url: API, method: HttpMethod, completion: @escaping ResponseType<T>){
        
        guard let urlValue = URL(string: url.url) else {
            dispatchQueueMain.async { completion(.failure(.invalidURL)) }
            return
        }
        
        //Global async Queue to make serial API calls using semaphores
        dispatchQueueGlobal.async {
            
            var request = URLRequest(url: urlValue)
            request.httpMethod = method.rawValue
            
            let semaphore = DispatchSemaphore (value: 0)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in

                guard let data = data else {
                    dispatchQueueMain.async { completion(.failure(.noDataFound)) }
                    semaphore.signal()
                    return
                }

                dispatchQueueMain.async {
                    do {
                        //DEBUG: data simulation
                        //if let resultCodable = try Router.decodeJsonToCoredata(data: testingJsonData, decoderType: T.self){
                        
                        if let resultCodable = try Router.decodeJsonToCoredata(data: data, decoderType: T.self){
                            completion(.success(resultCodable))
                        }
                        else{ completion(.failure(.parseFailed)) }
                    }
                    catch { completion(.failure(.serviceFailed(error.localizedDescription))) }
                }
                semaphore.signal()
            }
            
            task.resume()
            semaphore.wait()
        }
    }
    
    // MARK:- Method for JSON parsing
    static func decodeJsonToCoredata<T: Decodable>(data: Data, decoderType: T.Type) throws -> T?{
        
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
            fatalError("Failed to retrieve context")
        }
        
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let decoder = JSONDecoder()
        decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
        return try decoder.decode(decoderType, from: data)
    }
}
