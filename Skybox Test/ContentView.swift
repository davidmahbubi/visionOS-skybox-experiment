//
//  ContentView.swift
//  Skybox Test
//
//  Created by David Mahbubi on 11/10/23.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var enlarge = false
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @State var rotation: Double = 20

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack {
            RealityView { content in
                
                if let earthScene = try? await Entity(named: "Sun") {
//                    let degree = Angle.degrees(rotation)
//                    earthScene.transform.rotation = simd_quatf(angle: Float(degree.radians), axis: SIMD3<Float>(1, 0, 0))
                    earthScene.generateCollisionShapes(recursive: true)
//                    content.add(earthScene)
                }
                
                if let surfaceScene = try? await Entity(named: "Surface") {
                    surfaceScene.generateCollisionShapes(recursive: true)
                    surfaceScene.position = SIMD3<Float>(x: 0, y: -0.5, z: 0)
                    content.add(surfaceScene)
                }
                
            } update: { content in
                // Update the RealityKit content when SwiftUI state changes
                if let scene = content.entities.first {
                    let degree = Angle.degrees(rotation)
                    scene.transform.rotation = simd_quatf(angle: Float(degree.radians), axis: SIMD3<Float>(0, 1, 0))
                }
            }
            .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
                enlarge.toggle()
            })
            VStack {
                Toggle("Show Immersive Space", isOn: $showImmersiveSpace)
                    .toggleStyle(.button)
            }.padding().glassBackgroundEffect()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if (rotation > 360) {
                    rotation = 0
                }
                rotation += 20
            }
        }
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
