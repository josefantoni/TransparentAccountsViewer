//
//  AccountListViewModel.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import Foundation
import Combine
import SwiftUI

final class AccountListViewModel: BaseViewModel {
    
    @Published var connectionServerStatus: eConnectionServerStatus = .unknown
    @Published var accounts: [Account] = []
    
    var pingToServer: AnyCancellable?
    
    override init() {
        super.init()
        setupTimerForUpdateServerStatus()
        fetchAllTransparentAccounts()
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
    
    func reloadAccounts() {
        accounts.removeAll()
        fetchAllTransparentAccounts()
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
