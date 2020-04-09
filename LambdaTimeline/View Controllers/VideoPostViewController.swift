//
//  VideoPostViewController.swift
//  LambdaTimeline
//
//  Created by scott harris on 4/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostViewController: UIViewController {
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var titleTextField: UITextField!
    
    private var player: AVPlayer!
    
    @IBAction func postTapped(_ sender: Any) {
        
    }
    
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            case .notDetermined: // first run user hasnt been asked to give permission
                requestPermission()
            case .restricted: // parental controls limits access to video
                fatalError("You dont have permission to use the camera, talk to your gardian")
            case .denied: // 2nd+ run,m the user didnt trust us or said no by accident(show how to enable)
                fatalError("Show them a link to settings to get access to video")
            case .authorized: // 2nd+ run, theyve given permission to use the camera
                showCamera()
            @unknown default:
                fatalError("Didn't handle a new state for AVCaptureDevice authorization")
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            guard granted else {
                fatalError("Tell user the need to give video permission")
            }
            
            DispatchQueue.main.async {
                self.showCamera()
            }
            
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "ShowCameraSegue", sender: self)
    }
    
    @IBAction func showCameraTapped(_ sender: Any) {
        requestPermissionAndShowCamera()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCameraSegue" {
            if let destinationVC = segue.destination as? CameraViewController {
                destinationVC.delegate = self
            }
        }
    }
    
    private func playMovie(url: URL) {
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerView.playerLayer.addSublayer(playerLayer)
//        playerView.layer.addSublayer(playerLayer)
        
        player.play()
    }
}

extension VideoPostViewController: CameraViewControllerDelegate {
    func sendVideo(url: URL) {
        print("Delegate called")
        playMovie(url: url)
    }
}
