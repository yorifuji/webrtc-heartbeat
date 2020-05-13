//
//  FirstViewController.swift
//  webrtc-heartbeat
//
//  Created by yorifuji on 2020/04/29.
//  Copyright © 2020 yorifuji. All rights reserved.
//

import UIKit
import SkyWay

class FirstViewController: UIViewController {

    @IBOutlet weak var remoteHBM: UILabel!
    @IBOutlet weak var remoteName: UILabel!
    @IBOutlet weak var remoteOffLine: UILabel!
    @IBOutlet weak var remoteHeartMark: UIImageView!
    @IBOutlet weak var remoteStreamView: SKWVideo!

    @IBOutlet weak var localHBM: UILabel!
    @IBOutlet weak var localName: UILabel!
    @IBOutlet weak var localOffLine: UILabel!
    @IBOutlet weak var localHeartMark: UIImageView!
    @IBOutlet weak var localStreamView: SKWVideo!

    private var peer: SKWPeer?
    private var mediaConnection: SKWMediaConnection?
    private var localStream: SKWMediaStream?
    private var remoteStream: SKWMediaStream?
    private var meshRoom: SKWRoom?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.localOffLine.isHidden = true
//        self.remoteOffLine.isHidden = true
        self.setup()
    }
}

// MARK: setup skyway

extension FirstViewController {
    
    func setup(){
        
        guard let apikey = (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey, let domain = (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain else{
            print("Not set apikey or domain")
            return
        }
        
        let option: SKWPeerOption = SKWPeerOption.init();
        option.key = apikey
        option.domain = domain
        
        peer = SKWPeer(options: option)
        
        if let _peer = peer{
            self.setupPeerCallBacks(peer: _peer)
            self.setupStream(peer: _peer)
        }else{
            print("failed to create peer setup")
        }
    }
    
    func setupStream(peer:SKWPeer){
        SKWNavigator.initialize(peer);
        let constraints:SKWMediaConstraints = SKWMediaConstraints()
        constraints.minFrameRate = 30
        constraints.maxFrameRate = 30
//        constraints.minWidth = 1280
//        constraints.minHeight = 720
        self.localStream = SKWNavigator.getUserMedia(constraints)
        self.localStream?.addVideoRenderer(self.localStreamView, track: 0)
    }
    
    func call(targetPeerId:String){
        let option = SKWCallOption()
        
        if let mediaConnection = self.peer?.call(withId: targetPeerId, stream: self.localStream, options: option){
            self.mediaConnection = mediaConnection
            self.setupMediaConnectionCallbacks(mediaConnection: mediaConnection)
        }else{
            print("failed to call :\(targetPeerId)")
        }
    }

    func join(targetRoom: String) {
        let option = SKWRoomOption()
        option.mode = .ROOM_MODE_MESH
        option.stream = self.localStream

        self.meshRoom = self.peer?.joinRoom(withName: targetRoom, options: option)
        if let room = self.meshRoom {
            self.setupRoomCallbacks(room)
        }
        else {
            print("failed to join room :\(targetRoom)")
        }
    }

    func send(_ data: NSObject) {
        self.meshRoom?.send(data)
    }
}

// MARK: skyway callbacks

extension FirstViewController {
    
    func setupPeerCallBacks(peer:SKWPeer){
        
        // MARK: PEER_EVENT_ERROR
        peer.on(SKWPeerEventEnum.PEER_EVENT_ERROR, callback:{ (obj) -> Void in
            if let error = obj as? SKWPeerError{
                print("\(error)")
            }
        })
        
        // MARK: PEER_EVENT_OPEN
        peer.on(SKWPeerEventEnum.PEER_EVENT_OPEN,callback:{ (obj) -> Void in
            if let peerId = obj as? String{
                DispatchQueue.main.async {
//                    self.myPeerIdLabel.text = peerId
//                    self.myPeerIdLabel.textColor = UIColor.darkGray
                    self.join(targetRoom: Setting.shared.room)
                }
                print("your peerId: \(peerId)")
            }
        })
        
        // MARK: PEER_EVENT_CONNECTION
        peer.on(SKWPeerEventEnum.PEER_EVENT_CALL, callback: { (obj) -> Void in
            if let connection = obj as? SKWMediaConnection{
                self.setupMediaConnectionCallbacks(mediaConnection: connection)
                self.mediaConnection = connection
                connection.answer(self.localStream)
            }
        })
    }
    
    func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){
        
        // MARK: MEDIACONNECTION_EVENT_STREAM
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM, callback: { (obj) -> Void in
            if let msStream = obj as? SKWMediaStream{
                self.remoteStream = msStream
                DispatchQueue.main.async {
//                    self.targetPeerIdLabel.text = self.remoteStream?.peerId
//                    self.targetPeerIdLabel.textColor = UIColor.darkGray
                    self.remoteOffLine.isHidden = true
                    self.remoteStream?.addVideoRenderer(self.remoteStreamView, track: 0)
                }
//                self.changeConnectionStatusUI(connected: true)
            }
        })
        
        // MARK: MEDIACONNECTION_EVENT_CLOSE
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
            if let _ = obj as? SKWMediaConnection{
                DispatchQueue.main.async {
                    self.remoteStream?.removeVideoRenderer(self.remoteStreamView, track: 0)
                    self.remoteStream = nil
                    self.mediaConnection = nil
                    self.remoteOffLine.isHidden = false
                }
//                self.changeConnectionStatusUI(connected: false)
            }
        })
    }

    func setupRoomCallbacks(_ room: SKWRoom) {
        room.on(.ROOM_EVENT_OPEN) { obj in
            print("ROOM_EVENT_OPEN: \(String(describing: obj))")
        }

        room.on(.ROOM_EVENT_CLOSE) { obj in
            print("ROOM_EVENT_CLOSE")
        }

        room.on(.ROOM_EVENT_ERROR) { obj in
            print("ROOM_EVENT_ERROR")
        }

        room.on(.ROOM_EVENT_STREAM) { obj in
            print("ROOM_EVENT_STREAM")
            self.remoteStream = obj as? SKWMediaStream
            DispatchQueue.main.async {
                self.remoteOffLine.isHidden = true
                self.remoteStream?.addVideoRenderer(self.remoteStreamView, track: 0)
            }
        }

        room.on(.ROOM_EVENT_REMOVE_STREAM) { obj in
            print("ROOM_EVENT_REMOVE_STREAM")
            DispatchQueue.main.async {
                self.remoteStream?.removeVideoRenderer(self.remoteStreamView, track: 0)
                self.remoteStream = nil
                self.remoteOffLine.isHidden = false
            }
        }

        room.on(.ROOM_EVENT_PEER_JOIN) { obj in
            print("ROOM_EVENT_PEER_JOIN")
        }

        room.on(.ROOM_EVENT_PEER_LEAVE) { obj in
            print("ROOM_EVENT_PEER_LEAVE")
            DispatchQueue.main.async {
                self.remoteStream?.removeVideoRenderer(self.remoteStreamView, track: 0)
                self.remoteStream = nil
                self.remoteOffLine.isHidden = false
            }
        }

        room.on(.ROOM_EVENT_DATA) { obj in
            print("ROOM_EVENT_DATA")
        }
    }
}


