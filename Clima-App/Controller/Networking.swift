//
//  Networking.swift
//  Clima-App
//
//  Created by ErnestG on 13.06.2018.
//  Copyright © 2018 ErnestG. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Networking: UIViewController {
    
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(response.result.isFailure)")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
}
