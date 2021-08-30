//
//  NetworkRouter.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/19/21.
//

import Foundation
import UIKit

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
