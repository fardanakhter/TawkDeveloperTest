//
//  ViewControllerCoordinator.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/26/21.
//

import Foundation
import UIKit

class ViewControllerCoordinator: Coordinator{
    
    var navigation: UINavigationController?
    var isAnimatable: Bool = true
    
    init(navigation: UINavigationController?){
        self.navigation = navigation
    }
    
    func navigateBack(){
        navigation?.popViewController(animated: isAnimatable)
    }
    
    func moveToDetail(viewModelProvider: DataViewModelProvider){
        let vc = ViewControllerManager.instance.getDetailViewController() as! DetailViewController
        if let  provider = viewModelProvider as? ListDetailViewModelProvider{
            vc.viewModelProvider = provider
        }
        
        // Keeping single instance of Coordinator, as this is a small app with few controllers
        // for big scale app we must designate single coordinator for single flow
        vc.coordinator = self
        self.navigation?.pushViewController(vc, animated: isAnimatable)
    }
}

// MARK:- All UIViewControllers should implement this protocol to be able to use ViewControllerCoordinator
protocol Coordinated where Self: UIViewController {
    var coordinator: ViewControllerCoordinator? { get set }
}
