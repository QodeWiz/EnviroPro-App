//
//  AirQualityViewController.swift
//  FIT3175_assignment4
//
//  Created by Ishrat Kaur on 9/6/2023.
//

import UIKit
import CoreLocation
import Foundation

class AirQualityViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    @IBOutlet weak var latitudeTextField: UITextField!
    
    @IBOutlet weak var longitudeTextField: UITextField!
    
    @IBOutlet weak var getCurrentLocationButton: UIButton!
    
    
    @IBOutlet weak var aqiLabel: UILabel!
    
    
    @IBOutlet weak var coLabel: UILabel!
    
    
    let REQUEST_STRING = "https://air-quality-by-api-ninjas.p.rapidapi.com/v1/airquality"
    let API_KEY = "7540481d67msh289040e37ea0a01p1fa1b2jsncac2e4433d67"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        aqiLabel.isHidden = true
        coLabel.isHidden = true
      
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            // Do something with the latitude and longitude values
            self.latitudeTextField.text = "\(latitude)"
            self.longitudeTextField.text = "\(longitude)"
            
            locationManager.stopUpdatingLocation() // Stop updating location once you have the current location
        }
    }
    
    @IBAction func enter(_ sender: Any) {
        guard let latitudeText = latitudeTextField.text, let longitudeText = longitudeTextField.text else {
                return
            }

            guard let latitude = Double(latitudeText), let longitude = Double(longitudeText) else {
                let alertController = UIAlertController(title: "Coordinates invalid", message: "Latitude and longitude must be valid numbers", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
                return
            }
        
        // Call the API request method with the latitude and longitude values
        makeAPIRequest(latitude: latitude, longitude: longitude)
        
        DispatchQueue.main.async {
                    // Show the labels
                    self.aqiLabel.isHidden = false
                    self.coLabel.isHidden = false
                }
    }
    
    
    
    @IBAction func getCurrentLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    

//    "X-RapidAPI-Key": "209deefd45msh762bec92f029163p151a05jsn6eaae8066f7d",
 //   "X-RapidAPI-Host": "air-quality.p.rapidapi.com"
    
    // Method to make the API request

    func makeAPIRequest(latitude: Double, longitude: Double) {
        let apiKey = "209deefd45msh762bec92f029163p151a05jsn6eaae8066f7d"
        let host = "air-quality.p.rapidapi.com"
        let urlString = "https://air-quality.p.rapidapi.com/current/airquality?lon=\(longitude)&lat=\(latitude)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue(host, forHTTPHeaderField: "X-RapidAPI-Host")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Handle the JSON response
                    print(json)
                    DispatchQueue.main.async {
                        self.updateUIWithData(json)
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }



    func updateUIWithData(_ data: [String: Any]) {
            
            if let aqi = (data["data"] as? NSArray)?.firstObject as? [String: Any],
               let aqiValue = aqi["aqi"] as? Int {
                aqiLabel.text = "AQI: \(aqiValue)"
            }
            
            if let co = (data["data"] as? NSArray)?.firstObject as? [String: Any],
               let coValue = co["co"] as? Int {
                coLabel.text = "CO: \(coValue)"
            }
            
            // Add similar code for other labels and data points
        }
        
        // Call this method with the API response data
        func displayAPIResponse(_ response: [String: Any]) {
            updateUIWithData(response)
        }
    
    @IBAction func showInfo(_ sender: Any) {
        // Create an alert controller
        let alertController = UIAlertController(title: "Information", message: "AQI: Air Quality Index [US - EPA standard 0 - +500]\nCO: Concentration of carbon monoxide (µg/m³)", preferredStyle: .alert)
        
        // Add an action to dismiss the alert
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alertController.addAction(dismissAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
