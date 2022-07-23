//
//  AccountDetailView.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import SwiftUI

struct AccountDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var account: Account
    @StateObject var viewModel: AccountDetailViewModel = AccountDetailViewModel()
    
    init(for account: Account) {
        self.account = account
    }
    
    var body: some View {
        VStack {
            tableView
        }.onAppear(perform: {
            viewModel.fetchTransparentAccountDetail(for: account)
        })
    }
    
    var tableView: some View {
        List {
//            listRow(title: "Activity name:",
//                    subtitle: sportActivity.name)
//            listRow(title: "Place:",
//                    subtitle: sportActivity.place)
//            listRow(title: "Duration:",
//                    subtitle: Helper.formatDuration(from: sportActivity.duration))
//            listRow(title: "Created:",
//                    subtitle: sportActivity.created.formatDate)
//            listRow(title: "Stored:",
//                    subtitle: sportActivity.isLocalObject ? "LOCAL" : "REMOTE")
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    @ViewBuilder
    func listRow(title: String, subtitle: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(subtitle)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}
