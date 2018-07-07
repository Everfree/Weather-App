//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "5b3af14ee52f5b1460ef12a850de3c66"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
	let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
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
        
    }//viewDidLoad()
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
	func getWeatherData(url: String, parameters: [String:String]){
		Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
			response in
			if response.result.isSuccess {
				print("Success! Got the weather data")
				
				let weatherJSON: JSON = JSON(response.result.value!)
				self.updateWeatherData(json: weatherJSON)
				
			}
			else {
				print("Error \(response.result.error ?? "Connection Issues" as! Error)")
				self.cityLabel.text = "Connection Issues"
			}
		}
	}//getWeatherData(url: String, parameters: [String:String])
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
	func updateWeatherData(json: JSON){
		
		if let tempResult = json["main"]["temp"].double {
		
			weatherDataModel.temperature = Int((tempResult * (9.0/5.0)) - 459.67)
		
			weatherDataModel.city = json["name"].stringValue
		
			weatherDataModel.condition = json["weather"][0]["id"].intValue
		
			weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
			
			updateUIWithWeatherData()
		}
		else {
			cityLabel.text = "Weather Unavailable"
		}
	}//updateWeatherData(json: JSON)

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
	func updateUIWithWeatherData() {
		
		cityLabel.text = weatherDataModel.city
		temperatureLabel.text = "\(weatherDataModel.temperature)°"
		weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
		
	}//updateUIWithWeatherData()
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations[locations.count - 1]
		if location.horizontalAccuracy > 0 {
			locationManager.stopUpdatingLocation()
			
			print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
			
			let latitude = location.coordinate.latitude
			let longitude = location.coordinate.longitude
			
			let params : [String:String] = ["lat": String(latitude), "lon": String(longitude), "appid": APP_ID]
			
			getWeatherData(url: WEATHER_URL, parameters: params)
		}
	}//locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    
    
    //Write the didFailWithError method here:
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
		cityLabel.text = "Location Unavailable"
	}//locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
	func userEnteredANewCityName(city: String) {
		
		let params: [String:String] = ["q": city, "appid": APP_ID]
		
		getWeatherData(url: WEATHER_URL, parameters: params)
		
	}//userEnteredANewCityName(city: String)

    
    //Write the PrepareForSegue Method here
    
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "changeCityName" {
			let destinationVC = segue.destination as! ChangeCityViewController
			
			destinationVC.delegate = self
		}
	}//prepare(for segue: UIStoryboardSegue, sender: Any?)
    
    
    
}//WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate


