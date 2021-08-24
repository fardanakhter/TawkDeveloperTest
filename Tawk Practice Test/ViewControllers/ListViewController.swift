//
//  ListViewController.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/14/21.
//

import UIKit
import CoreData

// typealias for ease for future change in data type
typealias ListDataType = [CDUserModel]

class ListViewController: UIViewController {
    
    //    func displayIds(){
    //        list.forEach{ print($0.id) }
    //    }
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            self.registerTableView(tableView)
            self.registerCell(tableView)
        }
    }
    
    @IBOutlet weak var searchResultTableview: UITableView!{
        didSet{
            self.registerTableView(searchResultTableview)
            self.registerCell(searchResultTableview)
        }
    }
    
    // MARK:- DataRepresentor & ViewModel
    lazy var dataRepresentable = ListDataRepresenter()
    var viewModels = [ListViewModel]() {
        didSet{
            guard !viewModels.isEmpty else {return}
            reloadTableView()
        }
    }
    
    // MARK:- Search Properties
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    var searchAdaptor: SearchBarAdapter!
    var searchResultViewModels: [ListViewModel]? {
        didSet{
            searchResultTableview.isHidden = searchResultViewModels?.isEmpty ?? true
            searchResultTableview.reloadData()
            tableView.tableFooterView?.isHidden = true
        }
    }
    
    var isNewDataRequested = false
    
    // MARK:- Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        observeConnectionStatus()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        let user = CDUserModel(context: coreDataManager.context)
        //        user.id = 1000
        //        coreDataManager.addDatabaseModel(model: user)
        //        coreDataManager.saveContext()
        //
        //        list.append(user)
        //        let last = (coreDataManager.fetchDatabaseModels().last as? CDUserModel)?.id
        //        print(last)
        
        // To fill UI with cache and get new data in parallel
        initDataRepresentor()
        populateUIWithCacheData()
        
        // make network call
        if viewModels.isEmpty {
            dataRepresentable.networkCall()
        }
    }
    // MARK:-
    
    func observeConnectionStatus(){
        ConnectionManager.connectionStatusObserver = { (status) in
            switch status {
            case .unavailable:
                // update UI with no internet
                self.showLoader(title: "Alert", message: "No Internet Connection!", withLoader: false, withOK: true)
                break
            case .cellular, .wifi:
                // make network call and update UI
                self.hideLoader()
                if self.isNewDataRequested {
                    self.dataRepresentable.networkCall()
                }
                break
            }
        }
        ConnectionManager.sharedInstance.observeReachability()
    }
    
    func setupSearchBar(){
        searchBar.placeholder = "Search users"
        self.navigationItem.titleView = searchBar
        searchAdaptor = SearchBarAdapter(viewModel: dataRepresentable)
        searchBar.delegate = searchAdaptor
    }
    
    // Initialize data representor object here wit Callbacks registerations
    func initDataRepresentor(){
        // handle loader on API status
        dataRepresentable.loadingUpdateCallBack = { status in
            if status {
                //self.showLoader(title: "Loading", message: "Please Wait..")
            }else{
                self.hideLoader()
            }
        }
        
        // update UI with latest ViewModel
        dataRepresentable.networkDataCallBack = { data in
            self.viewModels = data
        }
        
        // update search list UI
        dataRepresentable.searchedDataCallBack = { data in
            self.searchResultViewModels = data
        }
    }
    
    // MARK:- Gets data from cache 
    func populateUIWithCacheData(){
        dataRepresentable.getCacheData()
    }
    
    // MARK:- Loads more data
    func loadMoreItemsForList(){
        dataRepresentable.networkCall()
    }
    
    //MARK:- scrollViewDidScroll
    // if at the end of page + not already loading + list is not empty
    // then load next page
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isNewDataRequested && !viewModels.isEmpty){
            self.isNewDataRequested = true
            
            //DEBUG: Comment this line to disable pagination 
            self.loadMoreItemsForList()
        }
    }
    
    func reloadTableView(){
        isNewDataRequested = false
        tableView.tableFooterView?.isHidden = true
        tableView.reloadData()
    }
}