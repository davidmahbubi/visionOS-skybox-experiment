//
//  Skybox_TestApp.swift
//  Skybox Test
//
//  Created by David Mahbubi on 11/10/23.
//

import SwiftUI

@main
struct SkyBoxTest: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.progressive), in: .progressive)
    }
}
