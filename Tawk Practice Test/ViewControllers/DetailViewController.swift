//
//  DetailViewController.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/14/21.
//

import UIKit

class DetailViewController: UIViewController, Coordinated {
    
    @IBOutlet weak var userImageView: CacheImageView!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var followingLbl: UILabel!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var companyLbl: UILabel!
    @IBOutlet weak var blogLbl: UILabel!
    @IBOutlet weak var notesTextView: UITextView!{
        didSet{
            notesTextView.layer.cornerRadius = 5.0
            notesTextView.layer.borderWidth = 2.0
            notesTextView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet weak var saveBtn: UIButton!{
        didSet{
            saveBtn.layer.cornerRadius = 5.0
            saveBtn.layer.borderWidth = 2.0
            saveBtn.layer.borderColor = UIColor.black.cgColor
            saveBtn.setTitleColor(.black, for: .normal)
        }
    }
    
    
    // MARK:- Coordinator
    var coordinator: ViewControllerCoordinator?
    
    // MARK:- ViewModelProvider
    var viewModelProvider: ListDetailViewModelProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModelProvider()
        title = viewModelProvider.username
    }
    
    
    func initViewModelProvider(){
        // handle loader on API status
        viewModelProvider.loadingUpdateCallBack = { status in
            if status {
                //self.showLoader(title: "Loading", message: "Please Wait..")
            }else{
                //self.hideLoader()
            }
        }
        
        // update UI with latest ViewModel
        viewModelProvider.networkDataCallBack = { data in
            
            self.userImageView.downloaded(from: data.image, didLoadImage: {})
            
            self.followersLbl.text = "followers: " + (data.followers == nil ? "" : "\(data.followers!)")
            self.followingLbl.text = "following: " + (data.followers == nil ? "" : "\(data.following!)")
            
            self.nameLbl.text = data.name
            self.companyLbl.text = data.company
            self.blogLbl.text = data.blog
            
            self.notesTextView.text = data.note
        }
        
        // update UI for saved note completion
        viewModelProvider.savedNoteCallBack = {
            self.presentSavedAlert()
        }
        
        // make network call
        viewModelProvider.networkCall()
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        self.viewModelProvider.didSaveNote(note: notesTextView.text)
    }
    
    func presentSavedAlert(){
        let alert = UIAlertController(title: "Alert", message: "Saved!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
