//
//  ImmersiveView.swift
//  multipeer-share-coordinate-throw-ball
//
//  Created by blueken on 2024/12/20.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @ObservedObject var peerManager : PeerManager

    @State var latestRightIndexFingerCoordinates: simd_float4x4 = .init()
    @State var latestLeftIndexFingerCoordinates: simd_float4x4 = .init()
    
    var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    @Environment(ImmersiveViewModel.self) var model
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow

    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        }
        .task {
            do {
                if model.dataProvidersAreSupported && model.isReadyToRun {
                    try await model.session.run([model.sceneReconstruction, model.handTracking])
                } else {
                    await dismissImmersiveSpace()
                }
            } catch {
                print("Failed to start session: \(error)")
                await dismissImmersiveSpace()
                openWindow(id: "error")
            }
        }
        .task {
            await model.processHandUpdates()
        }
        .task(priority: .low) {
            await model.processReconstructionUpdates()
        }
        .task {
            await model.monitorSessionEvents()
        }
        .onChange(of: model.errorState) {
            openWindow(id: "error")
        }
        .onChange(of: model.latestRightIndexFingerCoordinates) {
            if (!peerManager.isUpdatePeerManagerBothIndexFingerCoordinate){
                return
            }
            
            latestRightIndexFingerCoordinates = model.latestRightIndexFingerCoordinates
            
            peerManager.myBothIndexFingerCoordinate = BothIndexFingerCoordinate(unixTime: Int(Date().timeIntervalSince1970), indexFingerCoordinate: IndexFingerCoordinate(left:  latestLeftIndexFingerCoordinates, right:  latestRightIndexFingerCoordinates))
            
            if (!peerManager.isUpdatePeerManagerRightIndexFingerCoordinates){
                return
            }
            
            peerManager.myRightIndexFingerCoordinates = RightIndexFingerCoordinates(unixTime: Int(Date().timeIntervalSince1970), rightIndexFingerCoordinates:  latestRightIndexFingerCoordinates)
        }
        .onChange(of: model.latestLeftIndexFingerCoordinates) {
            if (!peerManager.isUpdatePeerManagerBothIndexFingerCoordinate){
                return
            }
            latestLeftIndexFingerCoordinates = model.latestLeftIndexFingerCoordinates
            
            peerManager.myBothIndexFingerCoordinate = BothIndexFingerCoordinate(unixTime: Int(Date().timeIntervalSince1970), indexFingerCoordinate: IndexFingerCoordinate(left: latestLeftIndexFingerCoordinates, right:  latestRightIndexFingerCoordinates))
        }
        .onChange(of: peerManager.receivedMessage) {
            if (peerManager.receivedMessage.hasPrefix("matrix:")){
                let receivedMessage = peerManager.receivedMessage.replacingOccurrences(of: "matrix:", with: "")
                receiveMatrix(message: receivedMessage)
            }
        }
        .onChange(of: peerManager.transformationMatrixPreparationState) {
            if (peerManager.transformationMatrixPreparationState == .prepared) {
                if !peerManager.isHost {
                    model.entitiyOperationLock = true
                }
                model.initBall()
            }
        }
        .onReceive(timer) { _ in
            if !peerManager.isHost { return }
            if (peerManager.transformationMatrixPreparationState == .confirm) {
                sendMatrix()
            }
        }
    }
    
    func sendMatrix() {
        model.contentEntity.children.forEach { entity in
            let clientTransformMatrix =  entity.transform.matrix * peerManager.transformationMatrix
            let floatList: [Float] = clientTransformMatrix.floatList
            let floatListStr = floatList.map { String($0) }
            peerManager.sendMessage("matrix:\(entity.name),\(floatListStr)")
        }
    }
    
    func receiveMatrix(message: String){
        let matrixArray = message.components(separatedBy: ",")
        let entityName = matrixArray[0]
        guard let entityMatrix = simd_float4x4(floatListStr: Array(matrixArray[1...])) else {
            print("Failed to create matrix from string list")
            return
        }
        DispatchQueue.main.async {
            model.contentEntity.children.first(where: { $0.name == entityName })?.transform.matrix = entityMatrix
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(peerManager: PeerManager())
}
