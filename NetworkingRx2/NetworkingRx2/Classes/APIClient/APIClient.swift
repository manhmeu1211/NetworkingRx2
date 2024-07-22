//
//  APIClient.swift
//  NetworkingRx2
//
//  Created by khanhnvm on 22/7/24.
//

import Foundation
import UIKit

public protocol APIClientUseCase {
    func performRequest<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void)
    func performRequest(_ endpoint: Endpoint, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func upload(_ endpoint: Endpoint, data: Data, mimeType: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
    func download(_ endpoint: Endpoint, completion: @escaping (Result<(Data, URLResponse), NetworkError>) -> Void)
}

public final class APIClient: APIClientUseCase {
    private let networkService: NetworkServiceUseCase
    
    public init(networkService: NetworkServiceUseCase = NetworkService()) {
        self.networkService = networkService
    }
    
    public func performRequest<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        networkService.request(endpoint, responseType: responseType, completion: completion)
    }
    
    public func performRequest(_ endpoint: Endpoint, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkService.request(endpoint, completion: completion)
    }
    
    public func upload(_ endpoint: Endpoint, data: Data, mimeType: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        networkService.upload(endpoint, data: data, mimeType: mimeType, completion: completion)
    }
    
    public func download(_ endpoint: Endpoint, completion: @escaping (Result<(Data, URLResponse), NetworkError>) -> Void) {
        networkService.download(endpoint, completion: completion)
    }
}
