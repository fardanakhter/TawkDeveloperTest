//
//  CacheImageView.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/21/21.
//

import Foundation
import UIKit

class CacheImageView: UIImageView {
    
    private let cache = NSCache<NSString, NSData>()
    
    private func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFill, didLoadImage: @escaping () -> Void) {
        contentMode = mode
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.httpMethod = "get"
        session.dataTask(with: request) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            self.cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
                didLoadImage()
            }
        }.resume()
    }
    
    
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit, didLoadImage: @escaping () -> Void) {
        if let cachedData = cache.object(forKey: link as NSString) {
            self.image = UIImage(data: cachedData as Data)
            didLoadImage()
            return 
        }
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode,didLoadImage: didLoadImage)
    }
}
