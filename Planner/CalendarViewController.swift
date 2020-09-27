//
//  ViewController.swift
//  Planner
//
//  Created by Andrea Clare Lam on 30/08/2020.
//  Copyright © 2020 Andrea Clare Lam. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate{
    
    @IBOutlet var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
    }
    
    // What happens when a date is selected
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        
        // perform segue to canvas view
        self.performSegue(withIdentifier: "toCanvas", sender: nil)
    }
    
    // prepare for segue, pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detail = segue.destination as? CanvasViewController {
            detail.selectedDate = calendar.selectedDate
        }
    }
}

