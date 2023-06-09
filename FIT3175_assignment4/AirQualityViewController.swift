//
//  AirQualityViewController.swift
//  FIT3175_assignment4
//
//  Created by Ishrat Kaur on 9/6/2023.
//

import UIKit
import CoreLocation
import Foundation

/**
 The class manages the properties and behaviour of the Air quality view controller. The function of the class is to successfully take input from user either manually or via location services (if permission is provided), and outouts the
 air quality index and carbon monoxide concentration in the location inputted by the user.
 */

class AirQualityViewController: UIViewController, CLLocationManagerDelegate {

    /**
        Class properties, outlets and constants
     */
    let locationManager = CLLocationManager()               // create an instance of CLLocationManagerClass
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var getCurrentLocationButton: UIButton!
    @IBOutlet weak var aqiLabel: UILabel!
    @IBOutlet weak var coLabel: UILabel!
    let REQUEST_STRING = "https://air-quality-by-api-ninjas.p.rapidapi.com/v1/airquality"
    let API_KEY = "7540481d67msh289040e37ea0a01p1fa1b2jsncac2e4433d67"

    /**
     The function is responsible for loading the view of the app and determing which properties will be dispalyed when. Method also handles gesture recognition to dismiss keyboard.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        
        // the location manager is set to ask for permission for location whenever the app is in use
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // hide the labels (which will change to output) initially
        aqiLabel.isHidden = true
        coLabel.isHidden = true
        
        // gesture recognistion is used to dismiss keyboard when tap action is performed outside the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    /**
     The method is a delegate method of CLLocationManager and is responsible for updatung user location
     @param: manager which is an instance of CLLocationManager
     @param: status which updates authorization status
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    /**
     locationManager is also a delegate method which is responsible for
     @param: manager which is an instance of CLLocationManager class
     @param: didUpdatLocations which is an array of updated locations
     */
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
    
    /**
     enter function refers to when "calculate" button is clicked. The method is responsible for checking if user does not leave the text fileds blank and with correct inputs, calls the makeAPIRrequest function. Once the API request is made,
     the hidden labels are now made visible to the user.
     */
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

    /**
     the method is responsible for obatining user's current location's coordinates when the button in UI is clicked. startUpdatingLocation() method is called to update user location
     */
    @IBAction func getCurrentLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }

    /**
     The method is responsible for making the API reuquest as per rapidapi API documentation. The function converts the input values (latitude and longitude) to be part of the url string.
     @param: Longitude of type Double is required as a mandatory requirement for the API along with Latitude.  The response is handled asynchronously, and upon successful retrieval
     and JSON parsing and the UI also updated using the received data.
     @param: Latitude of type Double is required as a mandatory requirement for the API along with longitude
     */
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

    /**
     
     */
    func updateUIWithData(_ data: [String: Any]) {
            if let aqi = (data["data"] as? NSArray)?.firstObject as? [String: Any],
               let aqiValue = aqi["aqi"] as? Int {
                aqiLabel.text = "Air quality index at this location is \(aqiValue)"
            }
            
            if let co = (data["data"] as? NSArray)?.firstObject as? [String: Any],
               let coValue = co["co"] as? Int {
                coLabel.text = "Carbon monoxide is \(coValue)µg/m³"
            }
        }
        func displayAPIResponse(_ response: [String: Any]) {
            updateUIWithData(response)
        }
    
    /**
     The method uses an laertController to show users with information regarding what the data they are viewing means
     */
    @IBAction func showInfo(_ sender: Any) {
        let alertController = UIAlertController(title: "Information", message: "AQI: Air Quality Index [US - EPA standard 0 - +500]\nCO: Concentration of carbon monoxide (µg/m³)", preferredStyle: .alert)

        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alertController.addAction(dismissAction)
      
        present(alertController, animated: true, completion: nil)
    }
    
    /**
     Method to dismiss keyboard
     */
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
