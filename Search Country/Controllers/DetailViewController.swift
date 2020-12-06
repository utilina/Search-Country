//
//  ViewController.swift
//  Search Country
//
//  Created by Анастасия Улитина on 06.12.2020.
//

import UIKit
import SVGKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private let networkManager = NetworkManager()
    
    var countryImageString: String = ""
    var name: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.navigationItem.title = self.name
                self.tableView.reloadData()
                
            }
        }
    }
    var nativeName: String = ""
    var languages: [Language] = []
    var currency: [Currency]?
    var borders = [String] () {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var capital: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Load image to image view from svg url
        loadImage()
    }
    
    private func loadImage() {
        let svgUrl = URL(string: countryImageString)
        DispatchQueue.global().async {
            guard let url = svgUrl, let imageData = try? Data(contentsOf: url) else { return }
            // Use SVGKit methods to create UIImagge from SVGImage
            let anSVGImage: SVGKImage = SVGKImage(data: imageData)
            DispatchQueue.main.async {
                self.countryFlag.image = anSVGImage.uiImage
                
            }
        }
    }
    
    //MARK: - Root controller Button
    @IBAction func toTheRoot(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Table view data source methods
    // Sections settings
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Country name"
        } else if section == 1 {
            return "Capital"
        } else if section == 2 {
            return "Languages"
        } else if section == 3 {
            return "Borders"
        } else if section == 4 {
            return "Currencies"
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return languages.count
        } else if section == 3 {
            if borders.count != 0 {
                return borders.count
            } else {
                return 1
            }
        } else if section == 4 {
            return currency?.count ?? 1
        } else {
            return 0
        }
    }
    
    // Cells settings
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.detailCell, for: indexPath)
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.textLabel?.text = name + " (\(nativeName))"
        } else if indexPath.section == 1 {
            if capital != "" {
                cell.textLabel?.text = capital
            } else {
                cell.textLabel?.text = "No capital"
            }
        } else if indexPath.section == 2 {
            cell.textLabel?.text = languages[indexPath.row].name + " (\(languages[indexPath.row].nativeName))"
        } else if indexPath.section == 3 {
            if borders.count != 0 {
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = borders[indexPath.row]
                cell.isUserInteractionEnabled = true
                cell.selectionStyle = .gray
            } else {
                cell.textLabel?.text = "No borders"
                cell.isUserInteractionEnabled = false
            }
        } else if indexPath.section == 4 {
            if let currency = currency?[indexPath.row] {
                cell.textLabel?.text = currency.name!
            }  else {
                cell.textLabel?.text = "No currency"
            }
        }
        return cell
    }
    
    //MARK: - Table view delegate method
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            // Pushing to the next view controller
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyBoard.instantiateViewController(withIdentifier: Identifier.detailVC) as! DetailViewController
            navigationController?.pushViewController(detailViewController, animated: true)
            // Get picked country code
            if let countryTitle =  tableView.cellForRow(at: indexPath)?.textLabel?.text {
                let request = "alpha?codes=" + countryTitle
                // Request picked country code details
                networkManager.fetchAllCountries(request: request) { [weak self] result in
                    switch result {
                    case .success(let country):
                        // Set details to the next VC
                        detailViewController.name = country[0].name
                        detailViewController.nativeName = country[0].nativeName
                        detailViewController.borders = country[0].borders
                        detailViewController.languages = country[0].languages
                        detailViewController.countryImageString = country[0].flag
                        detailViewController.currency = country[0].currencies
                        detailViewController.capital = country[0].capital
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

