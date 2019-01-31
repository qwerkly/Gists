//
//  APIClient.swift
//  Gists
//
//  Created by Ivan Babich on 26/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import Foundation

protocol APIClient {
    
    var session: URLSession { get }
    
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void)
    
    func fetchImage(from url: URL, completion: @escaping (Result<Data, APIError>) -> Void)
    
    
}

extension APIClient {
    
    typealias JSONTaskCompletionHandler = (Decodable?, APIError?) -> Void
    typealias ImageCompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    private func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let genericModel = try JSONDecoder().decode(decodingType, from: data)
                        completion(genericModel, nil)
                    } catch {
                        completion(nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, .invalidData)
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
        }
        return task
    }
    
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void) {
        let task = decodingTask(with: request, decodingType: T.self) { (json, error) in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(Result.failure(error))
                    } else {
                        completion(Result.failure(.invalidData))
                    }
                    return
                }
                if let value = decode(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(.jsonParsingFailure))
                }
            }
        }
        task.resume()
    }
    
    private func getData(from url: URL, completion: @escaping ImageCompletionHandler) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func fetchImage(from url: URL, completion: @escaping (Result<Data, APIError>) -> Void) {
        getData(from: url) { data, response, error in
            DispatchQueue.main.async() {
                guard let data = data, error == nil else {
                    completion(.failure(.requestFailed))
                    return
                }
                completion(.success(data))
            }
        }
    }
    
//    func fetchImage(from url: URL, completion: @escaping (Result<Data, APIError>) -> Void) {
//        getData(from: url) { data, response, error in
//            DispatchQueue.main.async() {
//                guard let data = data, error == nil else {
//                    completion(.failure(.requestFailed))
//                    return
//                }
//                completion(.success(data))
//            }
//        }
//    }
}
