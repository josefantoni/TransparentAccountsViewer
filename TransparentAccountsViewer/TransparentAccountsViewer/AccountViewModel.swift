//
//  AccountViewModel.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import Foundation
import Combine
import SwiftUI

final class AccountViewModel: ObservableObject {
    let api = "https://webapi.developers.erstegroup.com/api/csas/public/sandbox/v3/transparentAccounts/"
    let myUniqueApiKey = "492e8b9e-7c57-4ddd-8ba9-ea0f8475c3a2"
    
    @Published var accounts: [Account] = []
    
    var bag = Set<AnyCancellable>()
    
    init() {
        fetchAllTransparentAccounts()
    }
    
    private func fetchAllTransparentAccounts() {
        guard var url = URLComponents(string: api) else {
            print("App error: invalid URL")
            return
        }
        // Fill parameters
        url.queryItems = [
            /*
             * Right now server does not returning paging values, broken Api, future TODO?
             */
            URLQueryItem(name: "page", value: "0"),
            URLQueryItem(name: "size", value: "10"),
        ]
        // Fill header
        guard let urlWithParameters = url.url else {
            print("App error: parameters in URL are invalid")
            return
        }
        var req = URLRequest(url: urlWithParameters)
        req.httpMethod = "GET"
        req.setValue(myUniqueApiKey, forHTTPHeaderField: "WEB-API-key")

        URLSession.shared.dataTaskPublisher(for: req)
            .receive(on: DispatchQueue.main)
            .tryMap(handleReceivedOutput)
            .decode(type: Accounts.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    print("Transparent account page was downloaded!")
                case .failure(let error):
                    print("Error occured while downloading a new account page: \(error)")
                }
            } receiveValue: { [weak self] pageWithAccounts in
                guard let self = self else { return }
                self.accounts.append(contentsOf: pageWithAccounts.accounts)
            }.store(in: &bag)
    }
    
    private func handleReceivedOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
                throw URLError(.badServerResponse)
        }
        return output.data
    }
}
