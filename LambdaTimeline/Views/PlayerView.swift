//
//  PlayerView.swift
//  LambdaTimeline
//
//  Created by scott harris on 4/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    
//    override class var layerClass: AnyClass {
//        return AVCaptureVideoPreviewLayer.self
//    }
    
//    var videoPlayerView: AVCaptureVideoPreviewLayer {
//        return layer as! AVCaptureVideoPreviewLayer
//    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
//    var session: AVCaptureSession? {
//        get { return videoPlayerView.session }
//        set { videoPlayerView.session = newValue }
//    }
}
