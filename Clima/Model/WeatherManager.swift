//
//  WeatherManager.swift
//  Clima
//
//  Created by Erik Santos on 05/01/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//
import UIKit
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(show error: Error)
}
struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    let watherUrlBase = "https://api.openweathermap.org/data/2.5/weather?appid=40bd9d72c4c3294b177df08d724d6d58&units=metric"
    
    func fetchWather(cityName: String){
        let urlString = "\(watherUrlBase)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchLatAndLon(lat: CLLocationDegrees, lon: CLLocationDegrees){
        let UrlString = "\(watherUrlBase)&lat=\(lat)&lon=\(lon)"
        performRequest(with: UrlString)
    }
    
    func performRequest(with urlString: String){
        //1. Create URL
        if let url = URL(string: urlString) {
            //2. Create URL Session
            
            let session = URLSession(configuration: .default)
            
            //3. Create Session a Task
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(show: error!)
                    return
                }
                
                
                if let safeData = data {
                    guard let weather = self.parseJSON(weather: safeData) else { return }
                    self.delegate?.didUpdateWeather(weather: weather)
                }
            }
            
            //4. Start the task
            task.resume()
            
        }
    }
    
    func parseJSON(weather: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decoderData = try decoder.decode(WeatherData.self, from: weather)
            let conditionId = decoderData.weather[0].id
            let temp = decoderData.main.temp
            let cityName = decoderData.name
            
            let weatherModel = WeatherModel(conditionId: conditionId, cityName: cityName, temperature: temp)
            return weatherModel
        } catch {
            delegate?.didFailWithError(show: error)
            return nil
        }
    }
}
