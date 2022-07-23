//
//  AccountListView.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import SwiftUI

struct AccountListView: View {
    @StateObject var viewModel = AccountListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                tableView
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    ServerStatusView(connectionStatus: viewModel.connectionServerStatus)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var tableView: some View {
        List {
            ForEach(viewModel.accounts, id: \.accountNumber) { account in
                NavigationLink {
                    AccountDetailView(for: account)
                } label: {
                    listRow(accountNumber: "\(account.accountNumber)/\(account.bankCode)",
                            	owner: account.name)
                }
            }
        }
        .refreshable {
            viewModel.reloadAccounts()
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    @ViewBuilder
    func listRow(accountNumber: String, owner: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(accountNumber)
                .font(.subheadline)
            Text(owner)
                .font(.subheadline)
                .fontWeight(.medium)	
        }
        .padding([.vertical, .horizontal], 3)
        .frame(minHeight: 50, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AccountListView()
    }
}
