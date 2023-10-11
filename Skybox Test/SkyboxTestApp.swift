//
//  Skybox_TestApp.swift
//  Skybox Test
//
//  Created by David Mahbubi on 11/10/23.
//

import SwiftUI

@main
struct SkyboxTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
