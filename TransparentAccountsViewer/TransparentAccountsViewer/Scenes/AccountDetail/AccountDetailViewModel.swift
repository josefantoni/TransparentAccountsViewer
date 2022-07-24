//
//  AccountDetailViewModel.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import Foundation
import Combine

final class AccountDetailViewModel: BaseViewModel {
    @Published var accountDetail: Account
    @Published var accountTransactions: [Transaction] = []
    
    init(accountDetail: Account) {
        self.accountDetail = accountDetail
    }
        
    /*
     *  Api must be broken. Always getting exactly same account result.
     */
    func fetchTransparentAccountDetail() {
        guard let url = URL(string: ServerUrls.transparentAccounts + accountDetail.accountNumber) else {
            print("App error: invalid URL")
            return
        }
        let request = createRequestWithHeader(for: url)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .tryMap(handleReceivedOutput)
            .decode(type: Account.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    print("Transparent account detail was downloaded!")
                case .failure(let error):
                    print("Error occured while downloading an account detail: \(error)")
                }
            } receiveValue: { [weak self] fetchedAccountDetail in
                guard let self = self else { return }
                self.accountDetail = fetchedAccountDetail
            }.store(in: &bag)
    }
    
    func fetchTransactions() {
        guard var url = URLComponents(string: String(format: ServerUrls.transparentTransactionsForAccount, accountDetail.accountNumber)) else {
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
            .decode(type: AccountTransactions.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    print("Transparent account detail was downloaded!")
                case .failure(let error):
                    print("Error occured while downloading an account detail: \(error)")
                }
            } receiveValue: { [weak self] fetchedAccountTransactions in
                guard let self = self else { return }
                self.accountTransactions = fetchedAccountTransactions.transactions
            }.store(in: &bag)
    }
}
