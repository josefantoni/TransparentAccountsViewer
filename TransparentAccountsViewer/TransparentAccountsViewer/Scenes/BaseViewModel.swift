//
//  BaseViewModel.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import Foundation
import Combine

enum eConnectionServerStatus {
    case online, offline, unknown
}

class BaseViewModel: ObservableObject {
    let myUniqueApiKey = "492e8b9e-7c57-4ddd-8ba9-ea0f8475c3a2"
    var bag = Set<AnyCancellable>()

    func createRequestWithHeader(for url: URL) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(myUniqueApiKey, forHTTPHeaderField: "WEB-API-key")
        return req
    }
    
    func handleReceivedOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
                throw URLError(.badServerResponse)
        }
        return output.data
    }
}
