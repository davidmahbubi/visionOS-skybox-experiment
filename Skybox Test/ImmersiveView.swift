//
//  ImmersiveView.swift
//  Skybox Test
//
//  Created by David Mahbubi on 11/10/23.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct ImmersiveView: View {
    
    var beachEntity: Entity
    var lakeEntity: Entity
    
    @State var rotation: Double = 0
    
    init() {
//        self.rotation = 55
        
        beachEntity = Entity()
        beachEntity.addSkybox(for: "beach_scene", radius: 20)
        beachEntity.updateRotation(rotation: 55)
        
        lakeEntity = Entity()
        lakeEntity.addSkybox(for: "lake_scene", radius: 30)
        lakeEntity.updateRotation(rotation: 55)
    }
    
    var body: some View {
        ZStack {
            RealityView { content in
                let rootEntity = Entity()
                rootEntity.addSkybox(for: "beach_scene", radius: 20)
                rootEntity.updateRotation(rotation: 55)
                content.add(rootEntity)
            } update: { content in
                if let scene = content.entities.first {
                    print("rotation: \(rotation)")
                    let degree = Angle.degrees(rotation)
                    scene.transform.rotation = simd_quatf(angle: Float(degree.radians), axis: SIMD3<Float>(0, 1, 0))
                }
            }
            RealityView { content in
                let rootEntity = Entity()
                rootEntity.addSkybox(for: "lake_scene", radius: 10)
                content.add(rootEntity)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                if (rotation >= 360) {
                    rotation = 0
                }
                rotation += 0.2
            }
        }
    }
}


extension Entity {
    func addSkybox(for fileName: String, radius: Float) {
        let subscription = TextureResource.loadAsync(named: fileName).sink(
            receiveCompletion: {
                switch $0 {
                case .finished: break
                case .failure(let error): assertionFailure("\(error)")
                }
            },
            receiveValue: { [weak self] texture in
                guard let self = self else { return }
                var material = UnlitMaterial()
                material.color = .init(texture: .init(texture))
                self.components.set(ModelComponent(
                    mesh: .generateSphere(radius: radius), // 1E3
//                    mesh: .generateCylinder(height: 10, radius: 5),
                    materials: [material]
                ))
                self.scale *= .init(x: -1, y: 1, z: 1)
//                self.position.y = 5
                self.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)
                
                // Rotate the sphere to show the best initial view of the space.
                updateRotation()
            }
        )
        components.set(Entity.SubscriptionComponent(subscription: subscription))
    }
    
    func updateTexture(for fileName: String) {
        let subscription = TextureResource.loadAsync(named: fileName).sink(
            receiveCompletion: {
                switch $0 {
                    case .finished: break
                    case .failure(let error): assertionFailure("\(error)")
                }
            },
            receiveValue: { [weak self] texture in
                guard let self = self else { return }
                
                guard var modelComponent = self.components[ModelComponent.self] else {
                    fatalError("Should this be fatal? Probably.")
                }
                
                var material = UnlitMaterial()
                material.color = .init(texture: .init(texture))
                modelComponent.materials = [material]
                self.components.set(modelComponent)
                
                // Rotate the sphere to show the best initial view of the space.
                updateRotation()
            }
        )
        components.set(Entity.SubscriptionComponent(subscription: subscription))
    }
    
    func updateRotation(rotation: Double = 55) {
        // Rotate the immersive space around the Y-axis set the user's
        // initial view of the immersive scene.
        let angle = Angle.degrees(rotation)
        print("Updating to \(angle.radians)")
//        let rotation = simd_quatf(angle: Float(angle.radians), axis: SIMD3<Float>(0, 1, 0))
        let rotation = simd_quatf(angle: Float(angle.radians), axis: SIMD3<Float>(0, 1, 0))
        self.transform.rotation = rotation
    }
    
    /// A container for the subscription that comes from asynchronous texture loads.
    ///
    /// In order for async loading callbacks to work we need to store
    /// a subscription somewhere. Storing it on a component will keep
    /// the subscription alive for as long as the component is attached.
    struct SubscriptionComponent: Component {
        var subscription: AnyCancellable
    }
}


//#Preview {
//    ImmersiveView()
//        .previewLayout(.sizeThatFits)
//}
