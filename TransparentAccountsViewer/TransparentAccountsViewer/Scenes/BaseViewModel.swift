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

    func createRequest(stringUrl: String,
                       withParameters: Dictionary<String, String>? = nil,
                       withHeader: Bool = true) -> URLRequest? {
        guard var url = URL(string: stringUrl),
              var urlComponents = URLComponents(url: url,
                                                resolvingAgainstBaseURL: false) else {
            print("App error: invalid URL")
            return nil
        }
        // Fill parameters
        if let parameters = withParameters {
            urlComponents.queryItems = parameters.map({ parameter in
                URLQueryItem(name: parameter.key, value: parameter.value)
            })
            guard let urlWithParameters = urlComponents.url else {
                print("App error: something went wrong while adding parameters to URL to make a request")
                return nil
            }
            url = urlWithParameters
        }
        // Fill header
        return createRequestWithHeader(for: url)
    }

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
