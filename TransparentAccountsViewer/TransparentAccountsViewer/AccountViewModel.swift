//
//  AccountViewModel.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import Foundation
import Combine
import SwiftUI

enum eConnectionServerStatus {
    case online, offline, unknown
}

struct ServerUrls {
    static let transparentAccounts = "https://webapi.developers.erstegroup.com/api/csas/public/sandbox/v3/transparentAccounts/"
    static let connectionServerStatus = transparentAccounts + "health"
}

final class AccountViewModel: ObservableObject {
    let myUniqueApiKey = "492e8b9e-7c57-4ddd-8ba9-ea0f8475c3a2"
    
    @Published var connectionServerStatus: eConnectionServerStatus = .unknown
    @Published var accounts: [Account] = []
    
    var bag = Set<AnyCancellable>()
    var pingToServer: AnyCancellable?
    
    init() {
        setupTimerForUpdateServerStatus()
        fetchAllTransparentAccounts()
    }
    
    private func createRequestWithHeader(for url: URL) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(myUniqueApiKey, forHTTPHeaderField: "WEB-API-key")
        return req
    }
    
    private func fetchAllTransparentAccounts() {
        guard var url = URLComponents(string: ServerUrls.transparentAccounts) else {
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
        let request = createRequestWithHeader(for: urlWithParameters)
        
        URLSession.shared.dataTaskPublisher(for: request)
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
    
    private func fetchConnectionServerStatus() {
        guard let url = URL(string: ServerUrls.connectionServerStatus) else {
            print("App error: invalid URL")
            return
        }
        let request = createRequestWithHeader(for: url)
        
        if let ping = pingToServer {
            bag.remove(ping)
            pingToServer = nil
        }
        let newPingToServer = URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .tryMap{ (data, response) -> Bool in
                // according to documentation, http code: 204 is the only value OK we get
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 204 else {
                    throw URLError(.badServerResponse)
                }
                return true
            }
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.connectionServerStatus = .online
                    print("OK, connection to server is alive'!")
                case .failure(let error):
                    self.connectionServerStatus = .offline
                    print("Connection failed! Error: \(error)")
                }
            } receiveValue: { _ in }
        newPingToServer.store(in: &bag)
        pingToServer = newPingToServer
    }
    
    private func setupTimerForUpdateServerStatus() {
        Timer
            .publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .prepend(Date()) // fire now!
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.fetchConnectionServerStatus()
            }.store(in: &bag)
    }

}
