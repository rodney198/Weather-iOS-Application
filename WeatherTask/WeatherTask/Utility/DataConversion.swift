//
//  DataConversion.swift
//  WeatherTask
//
//  Created by Rodney Pinto on 23/09/24.
//

import Foundation

func kelvinToCelsius(kelvin: Double) -> Double {
    let celsius = kelvin - 273.15
    return Double(String(format: "%.2f", celsius)) ?? celsius
}
