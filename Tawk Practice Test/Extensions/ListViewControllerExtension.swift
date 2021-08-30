//
//  ListViewControllerExtension.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/14/21.
//

import Foundation
import UIKit

enum CellType{
    case normal
    case inverted
    case note
    
    var identifier: String {
        switch self {
        case .normal:
            return NormalUserCell.identifier
        case .inverted:
            return InvertedUserCell.identifier
        case .note:
            return NoteUserCell.identifier
        }
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func registerCell(_ tableView: UITableView){
        tableView.register(UINib(nibName: CellType.normal.identifier, bundle: nil),
                           forCellReuseIdentifier: CellType.normal.identifier)
        tableView.register(UINib(nibName: CellType.inverted.identifier, bundle: nil),
                           forCellReuseIdentifier: CellType.inverted.identifier)
        tableView.register(UINib(nibName: CellType.note.identifier, bundle: nil),
                           forCellReuseIdentifier: CellType.note.identifier)
    }
    
    func registerTableView(_ tableView: UITableView){
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchResultTableview {return searchResultViewModels?.count ?? 0}
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserParentCell!
        
        let viewModel = tableView == searchResultTableview ? searchResultViewModels![indexPath.row] : viewModels[indexPath.row]
        
        if indexPath.row != 0 {
            viewModel.hasInvertedImage = (((indexPath.row + 1) % 4) == 0)
        }
        
        if (((indexPath.row + 1) % 4) == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: CellType.inverted.identifier) as! InvertedUserCell
        }
        else if viewModel.hasNote{
            cell = tableView.dequeueReusableCell(withIdentifier: CellType.note.identifier) as! NoteUserCell
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: CellType.normal.identifier) as! NormalUserCell
        }
        
        cell.configure(viewModel: viewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // check for searched user or normal user detail
        let viewModel = tableView == searchResultTableview ? searchResultViewModels![indexPath.row] : viewModels[indexPath.row]
        let listDetailViewModelProvider = ListDetailViewModelProvider(username: viewModel.username)
        coordinator?.moveToDetail(viewModelProvider: listDetailViewModelProvider)
    }
}
