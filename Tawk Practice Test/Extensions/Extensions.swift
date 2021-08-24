//
//  UIViewControllerExtension.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/14/21.
//

import Foundation
import UIKit

// MARK:- UIViewController Extension
extension UIViewController{
    
    func setBackButtonTitle(_ title: String){
        let backbtn = UIBarButtonItem(title: NSLocalizedString(title, comment: ""), style: .plain, target: self, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backbtn
    }
    
    func showLoader(title: String , message: String, withLoader: Bool = true, withOK: Bool = false){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = UIColor.black
        
        if withLoader{
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10,y: 5,width: 50, height: 50)) as UIActivityIndicatorView
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
        }
        
        if withOK {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        
        self.present(alert, animated: true)
    }
    
    func hideLoader(){
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK:- Inverted colored image
extension UIImage {
    func inverseImage(cgResult: Bool) -> UIImage? {
        let coreImage = UIKit.CIImage(image: self)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        if cgResult { // I've found that UIImage's that are based on CIImages don't work with a lot of calls properly
            return UIImage(cgImage: CIContext(options: nil).createCGImage(result, from: result.extent)!)
        }
        return UIImage(ciImage: result)
    }
}

