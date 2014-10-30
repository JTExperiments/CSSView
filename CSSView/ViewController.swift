//
//  ViewController.swift
//  CSSView
//
//  Created by James Tang on 29/10/14.
//  Copyright (c) 2014 James Tang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var smallButton: UIButton!
    @IBOutlet weak var bigButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var isSmall = ObservableReference<Bool>(false)
        
        Button(smallButton).bind({isSmall.value = true})
        Button(bigButton).bind({isSmall.value = false})
        
        Label(label).css(isSmall.map { $0 ? "small" : "big" })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

