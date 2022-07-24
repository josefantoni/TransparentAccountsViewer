//
//  AccountDetailView.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel
    
    init(for account: Account) {
        viewModel = AccountDetailViewModel(accountDetail: account)
    }
    
    var body: some View {
        VStack {
            tableView
        }.onAppear(perform: {
            viewModel.fetchTransparentAccountDetail()
        })
    }
    
    var tableView: some View {
        List {
            listRow(topLeft: viewModel.accountDetail.name,
                    topRight: "\(viewModel.accountDetail.balance)\(viewModel.accountDetail.currency)",
                    botLeft: "\(viewModel.accountDetail.accountNumber)/\(viewModel.accountDetail.bankCode)")
            listRow(topLeft: "IBAN:",
                    topRight: viewModel.accountDetail.iban)
            listRow(topLeft: "Transparency from:",
                    topRight: viewModel.accountDetail.transparencyFrom.formatDate)
            listRow(topLeft: "Transparency to:",
                    topRight: viewModel.accountDetail.transparencyTo.formatDate)
            if !viewModel.accountDetail.description.isEmpty {
                listRow(topLeft: "Description:",
                        topRight: viewModel.accountDetail.description)
            }
            if !viewModel.accountDetail.statements.isEmpty {
                listRow(topLeft: "Statements:",
                        topRight: viewModel.accountDetail.statements.joined(separator: "\n"))
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    @ViewBuilder
    func listRow(topLeft: String? = nil,
                topRight: String? = nil,
                botLeft: String? = nil,
                botRight: String? = nil) -> some View {
        VStack {
            HStack {
                if let topLeft = topLeft {
                    Text(topLeft).fontWeight(.medium)
                    Spacer()
                }
                if let topRight = topRight {
                    Spacer()
                    Text(topRight)
                        .multilineTextAlignment(.trailing)
                }
            }
            HStack {
                if let botLeft = botLeft {
                    Text(botLeft)
                    Spacer()
                }
                if let botRight = botRight {
                    Spacer()
                    Text(botRight)
                        .multilineTextAlignment(.trailing)
                }
            }
        }.font(.subheadline)
    }
}


struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetailView(for:
                            Account(accountNumber: "000000-2906478309",
                                    bankCode: "0800",
                                    transparencyFrom: "2016-08-18T00:00:00",
                                    transparencyTo: "3000-01-01T00:00:00",
                                    publicationTo: "3000-01-01T00:00:00",
                                    actualizationDate: "2018-06-14T11:03:48",
                                    balance: 616516.73,
                                    currency: "CZK",
                                    name: "VÝCHODOČEŠI",
                                    iban: "CZ13 0800 0000 0029 0647 8309",
                                    description: "Transparentni ucet hnuti Vychodocesi",
                                    statements: []))
    }
}
