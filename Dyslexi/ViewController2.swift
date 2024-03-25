//
//  ViewController2.swift
//  Dyslexi
//
//  Created by Veerjyot Singh on 19/03/24.
//

import UIKit
import AVFoundation
class ViewController2: UIViewController{
    var speaking :Bool = false
    @IBOutlet var textView: UITextView!
    let synthesizer = AVSpeechSynthesizer()
    
    var respond:String?
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("got the data")
        textView.text = respond!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(respond!)
        
    }
    @IBAction func speak(_ sender: UIBarButtonItem) {
        if speaking {
            stopVoiceOutput()
            speaking = false
        }
        else{
            speakText(text: respond ?? "Sorry I didn't get that, please try again")
        }
    }
}

//make it speak
extension ViewController2{
    func speakText(text: String) {
        let utterance = AVSpeechUtterance(string: text)


        // Configure the utterance.
        utterance.rate = easyVariables().rate
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 1.0


        // Retrieve the British English voice.
        let voice = AVSpeechSynthesisVoice(language:easyVariables().lang)


        // Assign the voice to the utterance.
        utterance.voice = voice
        

        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
    
    //Stop the f***** nuisance
    func stopVoiceOutput() {
            synthesizer.stopSpeaking(at: .immediate)
        }
}
