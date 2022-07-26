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
        guard let request = createRequest(stringUrl: ServerUrls.transparentAccounts + accountDetail.accountNumber) else {
            return
        }
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
        guard let request = createRequest(stringUrl:
                                            String(format: ServerUrls.transparentTransactionsForAccount, accountDetail.accountNumber)
        ) else { return }
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
