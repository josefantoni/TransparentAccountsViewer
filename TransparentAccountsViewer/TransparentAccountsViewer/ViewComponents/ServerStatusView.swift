//
//  ServerStatusView.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import SwiftUI

struct ServerStatusView: View {
    let connectionStatus: eConnectionServerStatus
    @State var isShowingConnectionStatusAlert = false
    
    var body: some View {
        ZStack {
            HStack {
                makeStatusText
                makeStatusCircle
            }
            statusAlertView
        }
    }
    
    var makeStatusText: some View {
        var text = ""
        switch connectionStatus {
        case .online:
            text = "online"
        case .offline:
            text = "offline"
        case .unknown:
            text = "unknown"
        }
        return Text(text)
    }
    
    var makeStatusCircle: some View {
        let color: Color?
        switch connectionStatus {
        case .online:
            color = .green
        case .offline:
            color = .red
        case .unknown:
            color = .gray
        }
        return Circle()
            .fill()
            .foregroundColor(color)
            .frame(width: 10, height: 10)
    }
    
    var statusAlertView: some View {
        var text = ""
        switch connectionStatus {
        case .online:
            text = "Right now, we are connected to API servers. To see a change, disconnect from the internet."
        case .offline:
            text = "Find the internet, this is not designed to be offline"
        case .unknown:
            text = "Unknown state, go check whats happening!"
        }
        return Button("") { isShowingConnectionStatusAlert = true }
            .alert(text, isPresented: $isShowingConnectionStatusAlert) {
            Button("OK") { }
        }
    }
}
