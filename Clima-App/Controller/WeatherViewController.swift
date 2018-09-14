//
//  WeatherViewController.swift
//  Clima-App
//
//  Created by ErnestG on 10.05.2018.
//  Copyright © 2018 ErnestG. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "b27faa39866dad9c270539ce6568ecd7"
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Networking
    
    //getWeatherData method:
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
    
    
    //MARK: - JSON Parsing
    
    //updateWeatherData method:
    func updateWeatherData(json: JSON) {
        
        if let tempResult = json["main"]["temp"].double {
            
            weatherDataModel.temperature = Int(tempResult - 273)
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWeatherData()
        }
        
        else {
            cityLabel.text = "Weather unavailable"
        }
    }
    
    
    
    //MARK: - UI Updates
    
    //updateUIWithWeatherData method:
    func updateUIWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    //MARK: - Location Manager Delegate Methods
    
    //didUpdateLocations method:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            
            print("Longitude: \(location.coordinate.longitude), latitude: \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat": latitude, "lon": longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    

    //didFailWithError method:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    //MARK: - Change City Delegate methods

    //userEnteredANewCityName Delegate method:
    func userEnteredANewCityName(city: String) {
        
        print(city)
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }
    
    
    //prepareForSegue method:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
}
