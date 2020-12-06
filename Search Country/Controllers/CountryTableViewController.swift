//
//  CountryTableViewController.swift
//  Search Country
//
//  Created by Анастасия Улитина on 06.12.2020.
//

import UIKit

class CountryTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var countryArray = [Country]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        // Load countries
        fetchData()
    }
    
    private func fetchData() {
        networkManager.fetchAllCountries { [weak self] result in
            switch result {
            case .success(let country):
                // Save fetched data to country array
                self?.countryArray = country
            //print(country)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.countryCell, for: indexPath)
        let country = countryArray[indexPath.row]
    
        cell.textLabel?.text = country.name
        cell.detailTextLabel?.text = country.alpha3Code
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Segue to the detail view controller
        performSegue(withIdentifier: Segue.goToDetails, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.goToDetails {
            if let destinationVC = segue.destination as? DetailViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    // Pass data to destinationVC to show country details
                    let country = self.countryArray[indexPath.row]
                    destinationVC.name = country.name
                    destinationVC.languages = country.languages
                    destinationVC.countryImageString = country.flag
                    destinationVC.borders = country.borders
                    destinationVC.currency = country.currencies
                    destinationVC.nativeName = country.nativeName
                    destinationVC.capital = country.capital
                    
                }
            }
        }
    }
}


extension CountryTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let country = searchBar.text {
            // Check if there is some text
            if country != "" {
                let encodeCountry = country.replacingOccurrences(of: " ", with: "%20")
                let searchCountry = "name/" + encodeCountry
                // Request country
                networkManager.fetchAllCountries(request: searchCountry) { [weak self] result in
                    switch result {
                    case .success(let country):
                        self?.countryArray = country
                    //               print(country)
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                // If there is no text return all countries
                fetchData()
            }
        }
        
    }
    
}
