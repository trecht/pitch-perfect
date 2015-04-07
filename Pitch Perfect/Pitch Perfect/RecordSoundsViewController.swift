//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by tom on 3/14/15.
//  Copyright (c) 2015 tom. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var micLabel: UILabel!
    @IBOutlet weak var recordAudio: UIButton!
    @IBOutlet weak var recordStop: UIButton!
    
    
    // global constants
    
    let viewName = "RecordSoundsVC"       // for debugging
    let recordingLabel = "recording ..."  // mic label
    let pressLabel = "press to record"    // alternate mic label
    
    
    // global variables
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    
    // delegates

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        println("audioRecorderDidFinishRecording()")
        if (flag) {
            // success. save the recorded audio in a RecordedAudio object
            recordedAudio = RecordedAudio(recordingPath: recorder.url,
                recordingName: recorder.url.lastPathComponent!)
            println("recording complete. title: " + recordedAudio.title)
            
            // move to the next scene (perform segue)
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
        else {
            // an error. re-enable recording
            println("!!!! recording was unsuccessful")
            recordAudio.enabled = true        // re-enable the mic icon
            recordStop.hidden = true          // hide the off button
            micLabel.text = pressLabel        // update label
        }
    }

    
    // view functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("new view [vDL]: " + viewName)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // initialize anything necessary for the starting view.
        micLabel.text = pressLabel
        micLabel.hidden = false
        recordStop.hidden = true
        recordAudio.enabled = true
        println("new view [vWA]: " + viewName)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            println("prepare for segue Rec>Play")
            let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio  // // (undone) had to change 'as' to 'as?' -- why?
            playSoundsVC.receivedAudio = data
        }
    }

    
    // actions
    
    @IBAction func recordAudio(sender: UIButton) {
        println("button press: record")
        // mic label should say "recording"
        if (micLabel.text == pressLabel) {
            micLabel.text = recordingLabel
            recordStop.hidden = false
            recordAudio.enabled = false // disable pressing twice
        }

        // actually record something
        // (from Lecture notes - originally from from stackexchange.com, modified by Udacity)
    
        // locate the "documents" directory for saving the recording
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)[0] as String
    
        // construct a unique filename using system date & time (with seconds)
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
    
        // put together a full NSURL pathname
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println("new sound file: " + recordingName)

        // set up the "session" as a shared instance in the "play and record" category
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
    
        // start the recorder with recording saved in NSURL pathname with meter enabled
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self // so can recognize end of recording
        audioRecorder.meteringEnabled = true
        audioRecorder.record()
    }
    
    
    @IBAction func recordStop(sender: UIButton) {
        print("button press: off ... ")
        // switch mic label back to "press ..."
        if (micLabel.text == recordingLabel) {
            println("processing")
            micLabel.hidden = true
            recordStop.hidden = true
            recordAudio.enabled = true // re-enable recording

            //actually stop the recording
            audioRecorder.stop()
            var audioSession = AVAudioSession.sharedInstance()
            audioSession.setActive(false, error: nil)
        }
        else {
            println("not processing")
        }
    }
}

