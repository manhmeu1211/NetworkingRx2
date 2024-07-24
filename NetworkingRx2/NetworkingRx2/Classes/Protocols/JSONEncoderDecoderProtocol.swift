//
//  JSONEncoderProtocol.swift
//  NetworkingRx2
//
//  Created by khanhnvm on 24/7/24.
//

import Foundation

public protocol JSONEncoderProtocol  {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

public protocol JSONDecoderProtocol {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONEncoder: JSONEncoderProtocol {}
extension JSONDecoder: JSONDecoderProtocol {}
