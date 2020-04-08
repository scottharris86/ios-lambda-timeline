//
//  CommentViewController.swift
//  LambdaTimeline
//
//  Created by scott harris on 4/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol CreateCommentDelegate {
    func createComment(audioURL: URL? , text: String?)
}

class CommentViewController: UIViewController {
    
    var delegate: CreateCommentDelegate?

    var commentTypeSegementedControl: UISegmentedControl = {
       let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "Text", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Audio", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(commentTypeChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    var commentTextField = UITextField()
    let recordButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.setImage(UIImage(systemName: "stop.fill"), for: .selected)
        button.addTarget(self, action: #selector(recordPressed), for: .touchUpInside)
        return button
    }()
    
//    let playButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        button.setImage(UIImage(systemName: "pause.fill"), for: .selected)
//        button.addTarget(self, action: #selector(), for: .touchUpInside)
//        return button
//    }()
    
    
    
    let textContainerView = UIView()
    let audioContainerView = UIView()
    
    var textContainerLeadingContstraint: NSLayoutConstraint!
    var audioContainerTrailingContstraint: NSLayoutConstraint!
    
    private var audioRecorder: AVAudioRecorder?
    
    var recordingURL: URL?
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCommentType()
        setupTextCommentView()
        setupAudioCommentView()
        
    }
    
    private func updateViews() {
        recordButton.isSelected = isRecording
    }
    
    private func setupCommentType() {
        view.addSubview(commentTypeSegementedControl)
        commentTypeSegementedControl.translatesAutoresizingMaskIntoConstraints = false
        commentTypeSegementedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        commentTypeSegementedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    private func setupTextCommentView() {
        view.addSubview(textContainerView)
        textContainerView.addSubview(commentTextField)
        commentTextField.borderStyle = .roundedRect
        commentTextField.isEnabled = true
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        commentTextField.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: 8).isActive =  true
        commentTextField.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -8).isActive =  true
        commentTextField.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor).isActive = true
        commentTextField.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor).isActive = true
        commentTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.topAnchor.constraint(equalTo: commentTypeSegementedControl.bottomAnchor, constant: 40).isActive = true
        textContainerLeadingContstraint = textContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 60)
        textContainerLeadingContstraint.isActive = true
        textContainerView.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60).isActive = true
        
    }
    
    private func setupAudioCommentView() {
        view.addSubview(audioContainerView)
        audioContainerView.addSubview(recordButton)

        audioContainerView.translatesAutoresizingMaskIntoConstraints = false
        audioContainerView.topAnchor.constraint(equalTo: commentTypeSegementedControl.bottomAnchor, constant: 40).isActive = true
        audioContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 60).isActive = true
        audioContainerTrailingContstraint = audioContainerView.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -view.frame.width)
        audioContainerTrailingContstraint.isActive = true
        audioContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.centerXAnchor.constraint(equalTo: audioContainerView.centerXAnchor).isActive = true
        recordButton.centerYAnchor.constraint(equalTo: audioContainerView.centerYAnchor).isActive = true
        recordButton.isHidden = true

    }
    
    @objc private func commentTypeChanged() {
        textContainerLeadingContstraint.constant = view.frame.width
        textContainerLeadingContstraint.isActive = true
        
        audioContainerTrailingContstraint.constant = -60
        audioContainerTrailingContstraint.isActive = true
        
        UIView.animate(withDuration: 0.5) {
            self.recordButton.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        print("recording URL: \(file)")
        
        return file
    }
    
    
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    guard granted == true else {
                        print("We need microphone access")
                        return
                    }
                    
                    print("Recording permission has been granted!")
                    // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
            }
            case .denied:
                print("Microphone access has been blocked.")
                
                let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                
                present(alertController, animated: true, completion: nil)
            case .granted:
                startRecording()
            @unknown default:
                break
        }
    }
    
    func startRecording() {
        let recordingURL = createNewRecordingURL()
        
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        audioRecorder = try? AVAudioRecorder(url: recordingURL, format: audioFormat)

        audioRecorder?.delegate = self
        audioRecorder?.record()
        
        updateViews()
        
        self.recordingURL = recordingURL
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        updateViews()
    }
    
    @objc func recordPressed() {
        if isRecording {
            stopRecording()
        } else {
           requestPermissionOrStartRecording()
        }
        
    }
}

extension CommentViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let delegate = delegate {
            delegate.createComment(audioURL: recordingURL, text: nil)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio recorder error: \(error)")
        }
    }
}
