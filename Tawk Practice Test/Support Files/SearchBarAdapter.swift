//
//  SearchBarAdapter.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/23/21.
//

import Foundation
import UIKit

class SearchBarAdapter: NSObject, UISearchBarDelegate{
    
    var viewModel: ListViewModelProvider!
    
    init(viewModel: ListViewModelProvider) {
        self.viewModel = viewModel
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // fetch models from coredata here with text matching username and notes
        viewModel.didSearchText(text: searchText.lowercased())
    }
}
