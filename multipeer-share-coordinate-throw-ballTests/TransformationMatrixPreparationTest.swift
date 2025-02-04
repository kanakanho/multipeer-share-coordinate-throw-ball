//
//  TransformationMatrixPreparationTest.swift
//  multipeer-share-coordinate-throw-ballTests
//
//  Created by blueken on 2025/01/22.
//

import Testing
import SwiftUI

struct HostDemoData {
    let rightIndexFingerCoordinatesCodable = RightIndexFingerCoordinatesCodable(unixTime: Int(Date().timeIntervalSince1970), rightIndexFingerCoordinates: [
            [1, 0, 0, 2],
            [0, 1, 0, 2],
            [0, 0, 1, 2],
            [0, 0, 0, 1]
        ]
    )
    
    let bothIndexFingerCoordinateCodable = BothIndexFingerCoordinateCodable(unixTime: Int(Date().timeIntervalSince1970), indexFingerCoordinate: IndexFingerCoordinateCodable(left: [
            [1, 0, 0, 2],
            [0, 1, 0, 3],
            [0, 0, 1, 2],
            [0, 0, 0, 1]
        ], right: [
            [1, 0, 0, 2],
            [0, 1, 0, 4],
            [0, 0, 1, 2],
            [0, 0, 0, 1]
        ]
    ))
}

struct ClientDemoData{
    let rightIndexFingerCoordinatesCodable = RightIndexFingerCoordinatesCodable(unixTime: Int(Date().timeIntervalSince1970), rightIndexFingerCoordinates: [
            [1, 0, 0, 3],
            [0, 1, 0, 2],
            [0, 0, 1, 2],
            [0, 0, 0, 1]
        ]
    )
    
    let bothIndexFingerCoordinateCodable = BothIndexFingerCoordinateCodable(unixTime: Int(Date().timeIntervalSince1970), indexFingerCoordinate: IndexFingerCoordinateCodable(left: [
            [1, 0, 0, 2],
            [0, 1, 0, 3],
            [0, 0, 1, 2],
            [0, 0, 0, 1]
        ], right: [
            [1, 0, 0, 2],
            [0, 1, 0, 4],
            [0, 0, 1, 2],
            [0, 0, 0, 1]
        ]
    ))
    
    
    let rightIndexFingerCoordinatesCodableJsonStr: String
    let bothIndexFingerCoordinateCodableJsonStr: String
    
    init() {
        let rightIndexFingerCoordinatesCodableJsonStr = String(data: try! JSONEncoder().encode(rightIndexFingerCoordinatesCodable), encoding: .utf8)!
        let bothIndexFingerCoordinateCodableJsonStr = String(data: try! JSONEncoder().encode(bothIndexFingerCoordinateCodable), encoding: .utf8)!
        self.rightIndexFingerCoordinatesCodableJsonStr = rightIndexFingerCoordinatesCodableJsonStr
        self.bothIndexFingerCoordinateCodableJsonStr = bothIndexFingerCoordinateCodableJsonStr
    }
}

func SelectHostPeerManager(peerManager1: PeerManager, peerManager2: PeerManager) -> PeerManager {
    return peerManager1.peerID.hash > peerManager2.peerID.hash ? peerManager1 : peerManager2
}

struct TransformationMatrixPreparationTest {
    var peerManagerHost: PeerManager
    var peerManagerClient: PeerManager

    init() {
        let peerManager1 = PeerManager()
        let peerManager2 = PeerManager()
        self.peerManagerHost = SelectHostPeerManager(peerManager1: peerManager1, peerManager2: peerManager2)
        self.peerManagerClient = self.peerManagerHost === peerManager1 ? peerManager2 : peerManager1
    }
    
    let sharedCoordinateState = Binding.constant(SharedCoordinateState.sharing)
    
    @Test func InitialViewTest() async throws {
        let initialViewHost = InitialView(peerManager: peerManagerHost)
        let initialViewClient = InitialView(peerManager: peerManagerClient)
        await initialViewHost.firstSendMessage()
        await initialViewClient.firstSendMessage()
    }
    
    @Test func SearchingPeerViewTest() async throws {
        let searchingPeerViewHost = SearchingPeerView(peerManager: peerManagerHost)
        let searchingPeerViewClient = SearchingPeerView(peerManager: peerManagerClient)
        await searchingPeerViewHost.searchPeer()
        await searchingPeerViewClient.searchPeer()
    }
    
    @Test func SearchAndShareCoordinate() async throws {
        let searchAndShareCoordinateStoryTest = SearchAndShareCoordinateStoryTest(peerManagerHost: peerManagerHost, peerManagerClient: peerManagerClient)
        try await searchAndShareCoordinateStoryTest.SelectingPeerTest()
        try await searchAndShareCoordinateStoryTest.RightIndexFingerCoordinatesTest()
        try await searchAndShareCoordinateStoryTest.BothIndexFingerCoordinateTest()
    }

//    @Test func ConfirmViewHostTest () async throws {
//        let confirmView = ConfirmView(peerManager: peerManagerHost, sharedCoordinateState: sharedCoordinateState)
//
//        print("右手の座標")
//        print("相手")
//        print(peerManagerHost.rightIndexFingerCoordinates.codable.rightIndexFingerCoordinates.description)
//        print("自分")
//        print(peerManagerHost.myRightIndexFingerCoordinates.codable.rightIndexFingerCoordinates.description)
//
//        print("両手の座標")
//        print("相手")
//        print("右手")
//        print(peerManagerHost.bothIndexFingerCoordinate.codable.indexFingerCoordinate.right.description)
//        print("左手")
//        print(peerManagerHost.bothIndexFingerCoordinate.codable.indexFingerCoordinate.left.description)
//
//        print("自分")
//        print("右手")
//        print(peerManagerHost.myBothIndexFingerCoordinate.codable.indexFingerCoordinate.right.description)
//        print("左手")
//        print(peerManagerHost.myBothIndexFingerCoordinate.codable.indexFingerCoordinate.left.description)
//
//        await confirmView.confirm()
//
//        print(peerManagerHost.transformationMatrix)
//    }
    
}

struct SearchAndShareCoordinateStoryTest {
    var peerManagerHost: PeerManager
    var peerManagerClient: PeerManager
    
    let hostDemoData = HostDemoData()
    let clientDemoData = ClientDemoData()
    
    let HostPeerId:String
    
    let selectingPeerHostView: SelectingPeerHostView
    let selectingPeerClientView: SelectingPeerClientView

    init() {
        let peerManager1 = PeerManager()
        let peerManager2 = PeerManager()
        self.peerManagerHost = SelectHostPeerManager(peerManager1: peerManager1, peerManager2: peerManager2)
        self.peerManagerClient = self.peerManagerHost === peerManager1 ? peerManager2 : peerManager1
        
        self.HostPeerId = String(peerManagerHost.peerID.hash)
        
        self.selectingPeerHostView = SelectingPeerHostView(peerManager: peerManagerHost)
        self.selectingPeerClientView = SelectingPeerClientView(peerManager: peerManagerClient)
    }
    
    init(peerManagerHost: PeerManager, peerManagerClient: PeerManager) {
        self.peerManagerHost = peerManagerHost
        self.peerManagerClient = peerManagerClient
        
        self.HostPeerId = String(peerManagerHost.peerID.hash)
        
        self.selectingPeerHostView = SelectingPeerHostView(peerManager: peerManagerHost)
        self.selectingPeerClientView = SelectingPeerClientView(peerManager: peerManagerClient)
    }
    
    @Test func SelectingPeerTest() async throws {
   
        await selectingPeerHostView.confirmSelectClient()

        await selectingPeerClientView.onChangeReceivedMessage(receivedMessage:  "selectClient:\(HostPeerId)")
    }
    
    @Test func RightIndexFingerCoordinatesTest() async throws {
        let rightIndexFingerCoordinatesHostView = RightIndexFingerCoordinatesHostView(peerManager: peerManagerHost)
        let rightIndexFingerCoordinatesClientView = RightIndexFingerCoordinatesClientView(peerManager: peerManagerClient)
        
        await rightIndexFingerCoordinatesHostView.start()
        
        await rightIndexFingerCoordinatesClientView.onChangeReceivedMessage(receivedMessage: "reqRightIndexFingerCoordinates")
        
        
        await rightIndexFingerCoordinatesHostView.onChangeReceivedMessage(receivedMessage: "resRightIndexFingerCoordinate\(clientDemoData.rightIndexFingerCoordinatesCodableJsonStr)")
        
        await rightIndexFingerCoordinatesClientView.onChangeReceivedMessage(receivedMessage: "successRightIndexFingerCoordinates")
        
        await rightIndexFingerCoordinatesHostView.onChangeReceivedMessage(receivedMessage: "receivedSuccessRightIndexFingerCoordinates")
    }
    
    @Test func BothIndexFingerCoordinateTest() async throws {
        let bothIndexFingerCoordinateHostView = BothIndexFingerCoordinateHostView(peerManager: peerManagerHost)
        let bothIndexFingerCoordinateClientView = BothIndexFingerCoordinateClientView(peerManager: peerManagerClient)
        
        await bothIndexFingerCoordinateHostView.start()
        
        await bothIndexFingerCoordinateClientView.onChangeReceivedMessage(receivedMessage: "reqBothIndexFingerCoordinate")
        
        await bothIndexFingerCoordinateHostView.onChangeReceivedMessage(receivedMessage: "resBothIndexFingerCoordinate\(clientDemoData.bothIndexFingerCoordinateCodableJsonStr)")
        
        await bothIndexFingerCoordinateClientView.onChangeReceivedMessage(receivedMessage: "successBothIndexFingerCoordinate")
        
        await bothIndexFingerCoordinateHostView.onChangeReceivedMessage(receivedMessage: "receivedSuccessBothIndexFingerCoordinate")
    }
}
