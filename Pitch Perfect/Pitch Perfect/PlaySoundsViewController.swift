//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by tom on 4/2/15.
//  Copyright (c) 2015 tom. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    // outlets
    
    @IBOutlet weak var playStop: UIButton!

    // global constants
    
    let viewName = "PlaySoundsVC" // for debugging
    
    // global variables
    
    var audioPlayer: AVAudioPlayer!   // to play recording fast or slow
    var audioEngine: AVAudioEngine!   // to play chipmunk or darth vader effects
    var receivedAudio: RecordedAudio! // data passed from RecordSoundsViewController
    var audioFile: AVAudioFile!       // for differently formatted path used by AVAudioEngine
    
    
    // delegates
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        // hide the stop button when AVAudioPlayer completes
        if (flag) {
            println("AVAudioPlayer completed playing the file")
            playStop.hidden = true
       }
    }
    

    // gobal functions
    
    func audioEngineDidFinishPlayingSuccessfully() {
        // hide the stop button when AVAudioEngine completes play
        println("AVAudioEngine completed playing the file")
        playStop.hidden = true
    }
    
    
    func playWithSpeedAt(var #playRate: Float) {
        // this function starts the AVAudioPlayer audioPlayer
        // at the speed passed in as the argument.  The input is
        // clamped between 0.5 and 2.0 because these are the Min and Max
        // rates for an AVAudioPlaer object
        
        // clamp playRate between rateMin and rateMax
        if (playRate >= 2.0) {
            playRate = 2.0
        } else if (playRate <= 0.5) {
            playRate = 0.5
        }
        
        audioPlayer.stop()   // good practice before playing something new
        audioEngine.stop()
        audioEngine.reset()
        println("set rate to \(playRate)")
        audioPlayer.rate = playRate
        println("prepareToPlay")
        audioPlayer.prepareToPlay()
        println("setup delegate to recognize when play completes")
        audioPlayer.delegate = self
        println("|play|")
        audioPlayer.play()
    }
    
    
    func playAudioWithVariablePitch(pitch: Float) {
        // using AVAudioEngine for this effect
        
        audioPlayer.stop() // good practice
        audioEngine.stop()
        audioEngine.reset()
        
        // the 1st node in the audio engine is the "player" node
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // the 2nd node in the audio engine is the "pitch changer" node
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch           // set to value passed in
        audioEngine.attachNode(changePitchEffect)
        
        // connnect the nodes in the the proper sequence:
        //     (player) > (pitch changer) > (output)
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        // play the recording
        audioPlayerNode.scheduleFile(audioFile, atTime: nil,
            completionHandler: audioEngineDidFinishPlayingSuccessfully)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    
    // view functions
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("new view [vWA]: " + viewName)
        
       // initialize anything necessary for the starting view.
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        println("new view [vDL]: " + viewName)
        
        // Do any additional setup after loading the view.
        playStop.hidden = true    // hide the Stop button
        
        // init the audio player for playing different speeds
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl,
            fileTypeHint: "WAV", error: nil)
        println("audio player: enable rate adjustment")
        audioPlayer.enableRate = true
        println("audio player: unmute audio")
        audioPlayer.volume = 1.0 // full volume (probably not necessary)
        
        // init the audio engine for pitch effects
        audioEngine = AVAudioEngine()
        
        // convert the recordings NSURL to proper format for audio engine
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // actions

    @IBAction func playFast(sender: UIButton) {
        // this button plays the recording fast
        println("button press: play fast")
        playWithSpeedAt(playRate: 2.0)
        playStop.hidden = false
    }
    
    
    @IBAction func playSlow(sender: UIButton) {
        // this button plays the recording slow
        println("button press: play slow")
        playWithSpeedAt(playRate: 0.5)
        playStop.hidden = false
    }

    
    @IBAction func playChipmunk(sender: UIButton) {
        // this button plays the recording with a chipmunk effect
        println("button press: play chipmunk")
        playStop.hidden = false
        playAudioWithVariablePitch(1000.0) // raise pitch 10 semitones
    }
    
    
    @IBAction func playDarthVader(sender: UIButton) {
        // this button plays the recording with a Darth Vader effect
        println("button press: play Darth Vader")
        playStop.hidden = false
        playAudioWithVariablePitch(-1000.0) // lower pitch 10 semitones
    }
    
    
    @IBAction func stopPlay(sender: UIButton) {
        // this button stops any sound file playing
        println("button press: stop")

        // stop the sound, reset the playhead to 0, hide the stop button
        println("|stop|")
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioEngine.stop()
        audioEngine.reset()
        playStop.hidden = true
    }
}
