//
//  SearchBarAdapter.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/23/21.
//

import Foundation
import UIKit

class SearchBarAdapter: NSObject, UISearchBarDelegate{
    
    var viewModelProvider: DataViewModelProvider!
    
    init(viewModelProvider: DataViewModelProvider) {
        self.viewModelProvider = viewModelProvider
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // fetch models from coredata here with text matching username and notes
        if let listViewModelProvider = viewModelProvider as? ListViewModelProvider{
            listViewModelProvider.didSearchText(text: searchText.lowercased())
        }
    }
}
