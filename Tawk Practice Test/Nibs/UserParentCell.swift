//
//  UserParentCell.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/14/21.
//

import UIKit

class UserParentCell: UITableViewCell, DataTableViewCell {
    
    // Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userImageView: CacheImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    
    // configure ViewModel
    func configure(viewModel: DataViewModel) {

        guard let viewModel = viewModel as? ListViewModel else {
            return
        }
        
        self.usernameLbl.text = viewModel.username
        self.noteImageView.isHidden = !viewModel.hasNote
        self.userImageView?.downloaded(from: viewModel.imageURL,didLoadImage: { [weak self] in
            guard let self = self else {
                return
            }
            if viewModel.hasInvertedImage{
                self.userImageView?.image = self.userImageView.image?.inverseImage(cgResult: false)
                self.layoutSubviews()
            }
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.layer.borderWidth = 2.0
        self.containerView.layer.borderColor = UIColor.black.cgColor
        
        self.userImageView.layer.cornerRadius = userImageView.frame.height / 2
        self.userImageView.layer.borderColor = UIColor.black.cgColor
        self.userImageView.layer.borderWidth = 2.0
    }
    
    override func prepareForReuse() {
        self.usernameLbl.text = ""
        self.userImageView.image = nil
        self.noteImageView.isHidden = true
    }
}

// Child Class of different cell views
final class InvertedUserCell: UserParentCell {
    static var identifier: String {
        return String(describing: self)
    }
}

final class NormalUserCell: UserParentCell {
    static var identifier: String {
        return String(describing: self)
    }
}

final class NoteUserCell: UserParentCell {
    static var identifier: String {
        return String(describing: self)
    }
}
