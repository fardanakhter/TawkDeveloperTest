//
//  APIs.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/19/21.
//

import Foundation

enum API{
    case userList(since: Int)
    case userProfile(username: String)
    
    private var baseUrl: String {
        "https://api.github.com"
    }
    
    var url: String{
        switch self {
        case .userList(since: let page):
            return baseUrl + "/users?since=\(page)"
        case .userProfile(username: let login):
            return baseUrl + "/users/\(login)"
        }
    }
}
