//
//  ViewController.swift
//  Dyslexi
//
//  Created by Veerjyot Singh on 19/03/24.
//
import UIKit
import Vision
import GoogleGenerativeAI
import AVFoundation

struct easyVariables {
    let prePrompt = "I am giving you a paragraph with broken text written by a dyslexic or a kid. Rewrite the paragraph do not changing any sense and also at end mention the mistakes in sentence paragraph:"
    let geminiKey = "AIzaSyCLlQr3VB8YPSp5o5RBLymF7M1gA3gFakU"
    let geminiModel = "gemini-pro"
    let lang = "en"
    let rate:Float = 0.55
    var dict = {}
}



class ViewController: UIViewController , AVCapturePhotoCaptureDelegate{
    
    //initializing Generative Model
    var CapturedPhoto:UIImage?
    let model = GenerativeModel(name: easyVariables().geminiModel, apiKey: easyVariables().geminiKey)
    var prompt = easyVariables().prePrompt
    var responder = ""
    
    private var captureSession = AVCaptureSession()
    private var capturePhotoOutput = AVCapturePhotoOutput()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the capture session
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("No video device available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting up camera input: \(error)")
        }
        
        if captureSession.canAddOutput(capturePhotoOutput) {
            captureSession.addOutput(capturePhotoOutput)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        
        
        // Create a button for capturing photos
        let captureButton = UIButton(type: .custom)
        captureButton.frame = CGRect(x: view.frame.width / 2, y: view.frame.height - 80, width: 80, height: 80)
        captureButton.layer.borderWidth = 4
        captureButton.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        captureButton.layer.cornerRadius = 0.5*captureButton.bounds.size.width
        captureButton.clipsToBounds = true
        captureButton.backgroundColor = UIColor.white
        captureButton.center = CGPoint(x: view.frame.width / 2, y: view.frame.height - 80)
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
    }
    
    @objc func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            CapturedPhoto = image
            imageToText(image: CapturedPhoto!)
            Task {
                do {
                    try await GeminiRequest(prompt: prompt)
                    prompt = easyVariables().prePrompt
                } catch {
                    print(error)
                }
                
            }
      }
    }
    
    

    
    // Function to make Gemini request
    func GeminiRequest(prompt: String) async throws {
        let response = try await model.generateContent(prompt)
        if let text = response.text {
            self.responder = text
            print()
            print("Gemini responded:- ")
            print(text)
            print()
        }
        performSegue(withIdentifier: "TextShow",sender: self)
    }
    
    // func controlls and sends data before segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController2 = segue.destination as? ViewController2 {
            viewController2.respond = self.responder
        }
        
    }
    
}


// extension handles image to text with func imageToText
// need to pass the UIImage to the func

extension ViewController {
    
    func imageToText(image:UIImage){
        
        //converting UIImage to cgImage
        guard let cgImage = image.cgImage else { return }

        // Create request handler with the CGImage
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        // Create text recognition request
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                return
            }
            
            // Process recognized text observations
            let text = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: ", ")

            
            // Output recognized text
            print(text)
            let corr = self.correctDyslexicText(text)
            print(corr)
            self.prompt += corr //sending generated text to promt
            print()
            print("Recogonzed text is as follow:- ")
            print(corr)
            print()
        }
        
        // Set the text recognition level
        request.recognitionLevel = .accurate

        // Perform text recognition
        do {
            try handler.perform([request])
        } catch {
            print("Error performing text recognition: \(error)")
        }
        
    }
    
}



//handles spell correction


extension ViewController{
    
    func correctDyslexicText(_ text: String) -> String {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: text.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: text, range: range, startingAt: 0, wrap: false, language: easyVariables().lang)
        
        var correctedText = text
        if misspelledRange.location != NSNotFound {
            let suggestions = checker.guesses(forWordRange: misspelledRange, in: text, language: easyVariables().lang)
            if let firstSuggestion = suggestions?.first {
                correctedText.replaceSubrange(Range(misspelledRange, in: text)!, with: firstSuggestion)
            }
        }
        print("Corrected text by spell checker is as follow :- ")
        print()
        print(correctedText)
        return correctedText
    }

}
