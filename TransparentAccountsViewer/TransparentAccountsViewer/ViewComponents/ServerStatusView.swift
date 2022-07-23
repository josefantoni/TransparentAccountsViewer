//
//  ServerStatusView.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import SwiftUI

struct ServerStatusView: View {
    let connectionStatus: eConnectionServerStatus
    
    var body: some View {
        HStack {
            makeStatusText
            makeStatusCircle
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
}
