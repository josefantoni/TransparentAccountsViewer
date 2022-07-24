//
//  NavigationLazyView.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 24.07.2022.
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}
