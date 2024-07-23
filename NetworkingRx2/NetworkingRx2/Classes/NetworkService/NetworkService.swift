//
//  NetworkService.swift
//  NetworkingRx2
//
//  Created by khanhnvm on 22/7/24.
//

import Foundation
import UIKit

public protocol NetworkServiceUseCase {
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type, completion: @escaping(Result<T, NetworkError>) -> Void)
    func request(_ endpoint: Endpoint, completion: @escaping(Result<Void, NetworkError>) -> Void)
    func upload(_ endpoint: Endpoint, data: Data, mimeType: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
    func download(_ endpoint: Endpoint, completion: @escaping (Result<(Data, URLResponse), NetworkError>) -> Void)
}


public class NetworkService: NetworkServiceUseCase {
    private let urlSession: URLSession
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    public init(urlSession: URLSession = .shared,
         jsonEncoder: JSONEncoder = JSONEncoder(),
         jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        do {
            let request = try createURLRequest(from: endpoint)
            let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    completion(.failure(.unknownError))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unknownError))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode, data: data)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let decodedResponse = try self.jsonDecoder.decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
            task.resume()
        } catch {
            completion(.failure(.invalidURL))
        }
    }
    
    public func request(_ endpoint: Endpoint, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        do {
            let request = try createURLRequest(from: endpoint)
            let task = urlSession.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(.unknownError))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unknownError))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode, data: nil)))
                    return
                }
                
                completion(.success(()))
            }
            task.resume()
        } catch {
            completion(.failure(.invalidURL))
        }
    }
    
    public func upload(_ endpoint: Endpoint, data: Data, mimeType: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        do {
            var request = try createURLRequest(from: endpoint)
            request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
            
            let task = urlSession.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    completion(.failure(.unknownError))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unknownError))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode, data: data)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                completion(.success(data))
            }
            task.resume()
        } catch {
            completion(.failure(.invalidURL))
        }
    }
    
    public func download(_ endpoint: Endpoint, completion: @escaping (Result<(Data, URLResponse), NetworkError>) -> Void) {
        do {
            let request = try createURLRequest(from: endpoint)
            let task = urlSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(.unknownError))
                    return
                }
                
                guard let data = data, let response = response else {
                    completion(.failure(.noData))
                    return
                }
                
                completion(.success((data, response)))
            }
            task.resume()
        } catch {
            completion(.failure(.invalidURL))
        }
    }
    
    private func createURLRequest(from endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: endpoint.baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        switch endpoint.encoding {
        case .urlEncoding:
            request = try URLEncoding.encode(request, with: endpoint.parameters)
        case .jsonEncoding:
            request = try JSONEncoding.encode(request, with: endpoint.parameters, jsonEncoder: jsonEncoder)
        case .customEncoding(let encoder):
            request.httpBody = encoder()
        }
        
        return request
    }
}
