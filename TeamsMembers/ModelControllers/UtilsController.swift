//
//  UtilsController.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/27/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit

class UtilsController {
    
    // Mark: - Shared instance
    static let shared = UtilsController()

    func fetchImage(image:String, completion: @escaping(UIImage?) -> Void ){
        guard let baseImageURL =  URL(string: image) else{
            completion(nil)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: baseImageURL) { (data, _, error) in
            if let error = error {
                print("Error fetching image \(error) : \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else{
                completion(nil)
                return
            }
            
            let image = UIImage(data:data)
            completion(image)
        }
        dataTask.resume()
    }
}
