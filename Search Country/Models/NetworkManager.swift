//
//  NetworkManager.swift
//  Search Country
//
//  Created by Анастасия Улитина on 06.12.2020.
//

import Foundation

struct NetworkManager {
    
    // Base url for fetching countries
    private let allCountriesUrl = "https://restcountries.eu/rest/v2/"
    
    //Errors
    enum NetworkError: Error {
        case noDataAvilable
        case canNotProcessData
    }
    
    //fetch data from api to send it to VC
    func fetchAllCountries(request: String = "all", completion: @escaping(Result<[Country], NetworkError>) -> Void) {
        //Create url, check it
        let baseURL = allCountriesUrl + request
        //print(baseURL)
        if let requestURL = URL(string: baseURL) {
            let session = URLSession(configuration: .default)
            let dataTask = session.dataTask(with: requestURL) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                // Check if there is a fetched data
                guard let jsonData = data else {
                    completion(.failure(.noDataAvilable))
                    return
                }
                do {
                    // Decode fetched data to
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode([Country].self, from: jsonData)
                    //print(decodedData)
                    // Pass data
                    completion(.success(decodedData))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(.canNotProcessData))
                }
            }
            dataTask.resume()
        }
    }
    
}
