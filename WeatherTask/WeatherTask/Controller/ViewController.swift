//
//  ViewController.swift
//  WeatherTask
//
//  Created by Rodney Pinto on 23/09/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    //MARK: - View Outlets
    @IBOutlet weak var topBaseView: UIView!
    @IBOutlet weak var feelsLikeView: UIView!
    @IBOutlet weak var humidView: UIView!
    @IBOutlet weak var windView: UIView!
    @IBOutlet weak var weatherDescView: UIView!
    @IBOutlet weak var searchbaseView: UIView!
    
    @IBOutlet weak var tableViewList: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tempLBL: UILabel!
    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var desLBL: UILabel!
    @IBOutlet weak var feelsLikeLBL: UILabel!
    @IBOutlet weak var humidityLBL: UILabel!
    @IBOutlet weak var windLBL: UILabel!
    // Property to store the weather condition data
    var weatherCondition: WeatherResponse?
    var weatherList: [WeatherData] = []
    var dateForecasts: [String: WeatherData] = [:]
    
    //MARK: - Cell Reuse Identifier
    let weatherListTVCell = "WhetherCell"
    
    private let searchTableView = UITableView()
    private var searchController: UISearchController!
    private var filteredCities: [String] = []
    private var allCities: [String] = ["Mumbai", "Delhi", "Bangalore", "Kolkata", "Chennai", "Hyderabad", "Ahmedabad", "Pune", "Jaipur", "Lucknow"]
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchCityfromJson()
        fetchData(location: "Kolkata")
        setupSearchController()
        setupTableView()
        setupData()
    }
    
    //MARK: - Function to Setup Data
    func setupData() {
        tableViewList.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Very light gray
        let view  = [topBaseView, feelsLikeView, humidView, windView, weatherDescView, tableViewList]
        
        for i in view {
            i?.layer.cornerRadius = 10
        }
        searchbaseView.isHidden = true
    }
    
    //MARK: - Fetch the Data from the API
    private func fetchData(location: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(location)&appid=79f4dee6de7a4f6dc54b69d870c20f8e"
        NetworkManager.shared.getRequest(urlString: urlString) { [self] (result: Result<WeatherResponse, NetworkError>) in
            switch result {
            case .success(let weatherData):
                print("Data received: \(weatherData)")
                self.weatherCondition = weatherData
                self.weatherList = weatherData.list
                // Update UI on the main thread if necessary
                // Extract unique dates
                // Extract unique dates with time at 9:00 AM
//                var dateForecasts: [String: WeatherData] = [:]
                
                for weather in weatherList {
                    let dateString = String(weather.dtTxt.prefix(10)) // Get the date part (YYYY-MM-DD)
                    let timeString = String(weather.dtTxt.suffix(8)) // Get the time part (HH:mm:ss)
                    
                    if timeString == "09:00:00" {
                        dateForecasts[dateString] = weather // Keep only the first forecast for that date
                    }
                }
                
                // Select the first three different dates with 9:00 AM
                let uniqueDates = Array(dateForecasts.keys.prefix(5))

                // Print out the forecasts for the three different dates
                for date in uniqueDates {
                    if let forecast = dateForecasts[date] {
                        print("Forecast for \(date) at 09:00 AM:")
                        print("  Temp: \(forecast.main.temp), Condition: \(forecast.weather.first?.description ?? "")")
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableViewList.reloadData()
                    // Update your UI here
                    updateUIElements(data: weatherList)
                }
                
            case .failure(let error):
                print("Error: \(error)")
                // Handle error accordingly
            }
        }
    }
    
    //MARK:  -Fetch data from Json
    func fetchCityfromJson() -> [Location] {
        var locations: [Location] = []
        if let path = Bundle.main.path(forResource: "Cities", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                 locations = try JSONDecoder().decode([Location].self, from: jsonData)
                print(locations)
                self.allCities = locations.map { $0.name }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        return locations
    }
        
    func updateUIElements(data: [WeatherData]) {
        let temp = kelvinToCelsius(kelvin: data[0].main.temp)
        self.tempLBL.text = String("\(temp)°")
        nameLBL.text = weatherCondition?.city.name
        let desc = String(data[0].weather[0].description)
        desLBL.text = desc
        let feeltemp = kelvinToCelsius(kelvin: data[0].main.feelsLike)
        feelsLikeLBL.text = String("\(feeltemp)°")
        humidityLBL.text = String("\(data[0].main.humidity)%")
        windLBL.text = String("\(data[0].wind.speed)m/s")
    }
}

extension ViewController {
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cities"
        
        // Set the search controller in the navigation item
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchController.searchBar.delegate = self
        searchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableViewList.delegate = self
        tableViewList.dataSource = self
        let cellNib1 = UINib(nibName: weatherListTVCell, bundle: nil)
        tableViewList.register(cellNib1, forCellReuseIdentifier: weatherListTVCell)
        
        searchbaseView.addSubview(searchTableView)
        searchTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            searchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func updateCityList(with city: String) {
        if !allCities.contains(city) {
            allCities.append(city)
        }
        searchTableView.reloadData()
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == searchTableView {
            // Show no results initially
            return isFiltering() ? filteredCities.count : 0
        } else if tableView == tableViewList {
            return dateForecasts.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let city = filteredCities[indexPath.row] // Always use filteredCities if filtering
            cell.textLabel?.text = city
            return cell
        } else if tableView == tableViewList {
            let cell: WhetherCell = tableView.dequeueReusableCell(withIdentifier: weatherListTVCell, for: indexPath) as! WhetherCell
            cell.backgroundColor = .clear

            // Use a filtered array of forecasts based on unique dates at 09:00 AM
            let uniqueDates = Array(dateForecasts.keys).sorted() // Sort to maintain order
            
            // Ensure we don't exceed the array bounds
            guard indexPath.row < uniqueDates.count else {
                return cell // Return an empty cell if there's no data
            }

            let date = uniqueDates[indexPath.row]
            if let forecast = dateForecasts[date] {
                // Display the forecast for the specific date
                cell.dateTimeLbl.text = date
                cell.cloudLbl.text = forecast.weather[0].main.rawValue
                let mintemp = kelvinToCelsius(kelvin: forecast.main.tempMin)
                let maxtemp = kelvinToCelsius(kelvin: forecast.main.tempMax)
                cell.tempLbl.text = "\(mintemp)° \(maxtemp)°"
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = filteredCities[indexPath.row]
        print("Selected city: \(selectedCity)") // Print the selected city
        searchController.isActive = false // Dismiss the search controller
        searchController.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row
        self.fetchData(location: selectedCity)
        searchView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
}

// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        // Filter the cities based on the search text
        filteredCities = allCities.filter { city in
            return city.lowercased().contains(searchText.lowercased())
        }
        
        searchTableView.reloadData() // Reload the table view to reflect changes
    }
    
    // UISearchBarDelegate Methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Search started")
        searchbaseView.isHidden = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Search canceled")
        searchbaseView.isHidden = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search completed")
        searchbaseView.isHidden = true
        searchController.isActive = false // Dismiss the search controller
        searchController.searchBar.resignFirstResponder() // Dismiss the keyboard
    }
}




