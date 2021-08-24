//
//  ViewControllerMAnager.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/14/21.
//

import Foundation
import UIKit

enum UIError: Error{
    case notFound(storyboard: String, controller: String)
    
    var description: String {
        switch self {
        case .notFound(let s, let c):
            return "ViewController with indentifier:\(c) not found in Storyboard:\(s)"
        }
    }
}

class ViewControllerManager{
    
    static let instance = ViewControllerManager()
    private init(){}
    
    enum StoryBoards: String {
        case main = "Main"
        
        var instance: UIStoryboard?{
            switch self {
            case .main:
                return UIStoryboard(name: self.rawValue, bundle: nil)
            }
        }
    }
    
    enum ViewControllers: String {
        case listVC = "ListViewController"
        case detailVC = "DetailViewController"
    }
    
    private func getViewController(_ storyBoard: StoryBoards, _ viewController: ViewControllers) throws -> UIViewController{
        guard let vc = storyBoard.instance?.instantiateViewController(withIdentifier: viewController.rawValue)
        else {
            throw UIError.notFound(storyboard: storyBoard.rawValue, controller: viewController.rawValue)
        }
        return vc
    }

    func getListViewController() -> UIViewController {
        let vc = try! getViewController(.main, .listVC)
        return vc
    }
    
    func getDetailViewController() -> UIViewController {
        let vc = try! getViewController(.main, .detailVC)
        return vc
    }
}
