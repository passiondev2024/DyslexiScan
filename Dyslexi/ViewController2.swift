//
//  ViewController2.swift
//  Dyslexi
//
//  Created by Veerjyot Singh on 19/03/24.
//

import UIKit

class ViewController2: UIViewController{
    
    @IBOutlet var textView: UITextView!
    
    var respond:String?
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("got the data")
        textView.text = respond!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(respond!)
        
    }
}
