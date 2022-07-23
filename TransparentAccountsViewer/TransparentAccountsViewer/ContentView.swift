//
//  ContentView.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = AccountViewModel()

    var body: some View {
        NavigationView {
            VStack {
                //TODO: values
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
