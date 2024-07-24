//
//  APIClient.swift
//  NetworkingRx2
//
//  Created by khanhnvm on 22/7/24.
//

import Foundation
import UIKit
import RxSwift

protocol APIClientProtocol {
    func performRequest<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) -> Observable<T>
    func performRequest(_ endpoint: Endpoint) -> Completable
    func upload(_ endpoint: Endpoint, data: Data, mimeType: String) -> Observable<Data>
    func download(_ endpoint: Endpoint) -> Observable<(Data, URLResponse)>
}

class APIClient: APIClientProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func performRequest<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) -> Observable<T> {
        return networkService.request(endpoint, responseType: responseType)
    }
    
    func performRequest(_ endpoint: Endpoint) -> Completable {
        return networkService.request(endpoint)
    }
    
    func upload(_ endpoint: Endpoint, data: Data, mimeType: String) -> Observable<Data> {
        return networkService.upload(endpoint, data: data, mimeType: mimeType)
    }
    
    func download(_ endpoint: Endpoint) -> Observable<(Data, URLResponse)> {
        return networkService.download(endpoint)
    }
}
