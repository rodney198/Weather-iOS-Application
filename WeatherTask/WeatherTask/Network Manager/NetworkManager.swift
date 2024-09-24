//
//  NetworkManager.swift
//  WeatherTask
//
//  Created by Rodney Pinto on 23/09/24.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case requestFailed
    case invalidData
    case jsonDecodingFailed
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func getRequest<T: Decodable>(urlString: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // Check for request errors
            if let _ = error {
                completion(.failure(.requestFailed))
                return
            }
            
            // Check for valid response and data
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode), let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            // Decode JSON data to the expected type
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.jsonDecodingFailed))
            }
        }
        
        task.resume()
    }
}
