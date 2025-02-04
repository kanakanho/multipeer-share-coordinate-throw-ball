//
//  multipeer_share_coordinate_throw_ballApp.swift
//  multipeer-share-coordinate-throw-ball
//
//  Created by blueken on 2024/12/20.
//

import SwiftUI

@main
struct multipeer_share_coordinate_throw_ballApp: App {
    
    @State private var appModel = AppModel()
    @StateObject private var peerManager = PeerManager()
    
    @State private var immersiveViewModel = ImmersiveViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(peerManager:peerManager)
                .environment(appModel)
        }
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView(peerManager:peerManager)
                .environment(immersiveViewModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
