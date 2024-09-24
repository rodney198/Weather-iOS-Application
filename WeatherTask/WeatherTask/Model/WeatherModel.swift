////
////  WeatherModel.swift
////  WeatherTask
////
////  Created by Rodney Pinto on 23/09/24.
////
//
//import Foundation
//
//// MARK: - WeatherCondition
//struct WeatherCondition: Codable {
//    let cod: String
//    let message, cnt: Int
//    let list: [List]
//    let city: City
//}
//
//// MARK: - City
//struct City: Codable {
//    let id: Int
//    let name: String
//    let coord: Coord
//    let country: String
//    let population, timezone, sunrise, sunset: Int
//}
//
//// MARK: - Coord
//struct Coord: Codable {
//    let lat, lon: Double
//}
//
//// MARK: - List
//struct List: Codable {
//    let dt: Int
//    let main: MainClass
//    let weather: [Weather]
//    let clouds: Clouds
//    let wind: Wind
//    let visibility: Int
//    let pop: Double
//    let rain: Rain?
//    let sys: Sys
//    let dtTxt: String
//
//    enum CodingKeys: String, CodingKey {
//        case dt, main, weather, clouds, wind, visibility, pop, rain, sys
//        case dtTxt = "dt_txt"
//    }
//}
//
//// MARK: - Clouds
//struct Clouds: Codable {
//    let all: Int
//}
//
//// MARK: - MainClass
//struct MainClass: Codable {
//    let temp, feelsLike, tempMin, tempMax: Double
//    let pressure, seaLevel, grndLevel, humidity: Int
//    let tempKf: Double
//
//    enum CodingKeys: String, CodingKey {
//        case temp
//        case feelsLike = "feels_like"
//        case tempMin = "temp_min"
//        case tempMax = "temp_max"
//        case pressure
//        case seaLevel = "sea_level"
//        case grndLevel = "grnd_level"
//        case humidity
//        case tempKf = "temp_kf"
//    }
//}
//
//// MARK: - Rain
//struct Rain: Codable {
//    let the3H: Double
//
//    enum CodingKeys: String, CodingKey {
//        case the3H = "3h"
//    }
//}
//
//// MARK: - Sys
//struct Sys: Codable {
//    let pod: Pod
//}
//
//enum Pod: String, Codable {
//    case d = "d"
//    case n = "n"
//}
//
//// MARK: - Weather
//struct Weather: Codable {
//    let id: Int
//    let main: MainEnum
//    let description: Description
//    let icon: Icon
//}
//
//enum Description: String, Codable {
//    case heavyIntensityRain = "heavy intensity rain"
//    case lightRain = "light rain"
//    case moderateRain = "moderate rain"
//    case overcastClouds = "overcast clouds"
//    case veryHeavyRain = "very heavy rain"
//}
//
//enum Icon: String, Codable {
//    case the04D = "04d"
//    case the10D = "10d"
//    case the10N = "10n"
//}
//
//enum MainEnum: String, Codable {
//    case clouds = "Clouds"
//    case rain = "Rain"
//}
//
//// MARK: - Wind
//struct Wind: Codable {
//    let speed: Double
//    let deg: Int
//    let gust: Double
//}

import Foundation

// MARK: - WeatherResponse
struct WeatherResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [WeatherData]
    let city: City
}

// MARK: - City
struct City: Codable {
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

// MARK: - Coord
struct Coord: Codable {
    let lat: Double
    let lon: Double
}

// MARK: - WeatherData
struct WeatherData: Codable {
    let dt: Int
    let main: MainWeather
    let weather: [WeatherCondition]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let rain: Rain?
    let sys: Sys
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, rain, sys
        case dtTxt = "dt_txt"
    }
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - MainWeather
struct MainWeather: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let seaLevel: Int
    let grndLevel: Int
    let humidity: Int
    let tempKf: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
    }
}

// MARK: - Rain
struct Rain: Codable {
    let the3H: Double?

    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}

// MARK: - Sys
struct Sys: Codable {
    let pod: Pod
}

enum Pod: String, Codable {
    case d = "d"
    case n = "n"
}

// MARK: - WeatherCondition
struct WeatherCondition: Codable {
    let id: Int
    let main: WeatherMain
    let description: String
    let icon: String
}

enum WeatherMain: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
    // Add other weather types as needed
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double
}



//MARK: - This function can be used to decode weather data for any city
func decodeWeatherData(from jsonData: Data) throws -> WeatherResponse {
    let decoder = JSONDecoder()
    return try decoder.decode(WeatherResponse.self, from: jsonData)
}
