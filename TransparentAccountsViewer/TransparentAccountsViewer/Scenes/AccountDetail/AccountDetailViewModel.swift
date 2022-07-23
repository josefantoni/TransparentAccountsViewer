//
//  AccountDetailViewModel.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import Foundation
import Combine

final class AccountDetailViewModel: BaseViewModel {
    @Published var accountDetail: Account?
    
    func fetchTransparentAccountDetail(for account: Account) {
        guard let url = URL(string: ServerUrls.transparentAccounts + account.accountNumber) else {
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
}
