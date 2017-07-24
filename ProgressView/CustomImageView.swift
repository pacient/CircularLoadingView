//
//  CustomImageView.swift
//  ProgressView
//
//  Created by Vasil Nunev on 23/07/2017.
//  Copyright © 2017 nunev. All rights reserved.
//

import UIKit
import Alamofire

class CustomImageView: UIImageView {
    let progressIndicator = CircularLoadingView(frame: CGRect.zero)
    
    func setImage(from url: String) {
        // Add those lines later on
        addSubview(progressIndicator)
        progressIndicator.frame = bounds
        progressIndicator.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        //After you type the above lines and you add to the storyboard run the project to make sure all is ok
        
        let utilityQueue = DispatchQueue.global(qos: .utility)
        
        Alamofire.request(url)
            .downloadProgress(queue: utilityQueue) { (progress) in
                print("Download Progress: \(progress.fractionCompleted)")
                
                DispatchQueue.main.async {
                    self.progressIndicator.progress = CGFloat(progress.fractionCompleted)
                }
            }
            .responseData { (response) in
                if let data = response.result.value {
                    let image = UIImage(data: data)
                    self.image = image
                    self.progressIndicator.reveal()
                }
        }
    }
}
