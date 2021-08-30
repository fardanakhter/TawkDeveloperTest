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

class ListViewController: UIViewController, Coordinated {
    
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
    
    // MARK:- Coordinator
    var coordinator: ViewControllerCoordinator?
    
    // MARK:- DataRepresentor & ViewModel
    lazy var viewModelProvider = ListViewModelProvider()
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
        setupViewControllerCoordinator()
        observeConnectionStatus()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBackButtonTitle("")
        
        // To fill UI with cache and get new data in parallel
        initViewModelPRovider()
        populateUIWithCacheData()
        
        // make network call
        if viewModels.isEmpty {
            viewModelProvider.networkCall()
        }
    }
    // MARK:-
    
    func setupViewControllerCoordinator(){
        coordinator = ViewControllerCoordinator(navigation: navigationController)
    }
    
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
                    self.viewModelProvider.networkCall()
                }
                break
            }
        }
        ConnectionManager.sharedInstance.observeReachability()
    }
    
    func setupSearchBar(){
        searchBar.placeholder = "Search users"
        self.navigationItem.titleView = searchBar
        searchAdaptor = SearchBarAdapter(viewModelProvider: viewModelProvider)
        searchBar.delegate = searchAdaptor
    }
    
    // Initialize data representor object here wit Callbacks registerations
    func initViewModelPRovider(){
        // handle loader on API status
        viewModelProvider.loadingUpdateCallBack = { status in
            if status {
                //self.showLoader(title: "Loading", message: "Please Wait..")
            }else{
                self.hideLoader()
            }
        }
        
        // update UI with latest ViewModel
        viewModelProvider.networkDataCallBack = { data in
            self.viewModels = data
        }
        
        // update search list UI
        viewModelProvider.searchedDataCallBack = { data in
            self.searchResultViewModels = data
        }
    }
    
    // MARK:- Gets data from cache 
    func populateUIWithCacheData(){
        viewModelProvider.getCacheData()
    }
    
    // MARK:- Loads more data
    func loadMoreItemsForList(){
        viewModelProvider.networkCall()
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
