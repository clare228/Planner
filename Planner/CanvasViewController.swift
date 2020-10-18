//
//  CanvasViewController.swift
//  Planner
//
//  Created by Andrea Clare Lam on 31/08/2020.
//  Copyright © 2020 Andrea Clare Lam. All rights reserved.
//

import UIKit
import PencilKit

class CanvasViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    
    var selectedDate: Date?
    var drawing = PKDrawing()
    
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var pencilFingerButton: UIBarButtonItem!
    @IBOutlet var canvasView: PKCanvasView!
    
    @IBAction func fingerPencilToggle (_ sender: Any) {
        canvasView.allowsFingerDrawing.toggle()
        pencilFingerButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
    }
    
    // Canvas dimensions
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHeight: CGFloat = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display selected date in label
        if let selectedDate = selectedDate {
            dateLabel.text = CanvasManager.main.dateToStringShow(dateDate: selectedDate)
        }
        
        // basic set up of canvas
        canvasView.delegate = self
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        
        // set up tool picker
        if let window = parent?.view.window,
            let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            canvasView.becomeFirstResponder()
        }
        
        // Find if current date has drawing saved
        // Check if canvas for selected date has already been created
        let result = CanvasManager.main.check(selectedDate: selectedDate!)
        
        // If canvas for selected date has not yet been created
        if Mirror(reflecting: result).children.count == 0 {
            // create new canvas to store in db
            print("CREATING NEW CANVAS")
            _ = CanvasManager.main.create(date: selectedDate!, drawing: drawing.dataRepresentation())
            let _ = CanvasManager.main.check(selectedDate: selectedDate!)
        }
        else {
            // load existing drawing
            print("LOAD EXISTING CANVAS")
            let canvas = Canvas(id: result[0].id, date: result[0].date, drawing: result[0].drawing)
                       
            do {
                
                // Try to populate drawing with previous canvas drawing
                try drawing = PKDrawing.init(data: canvas.drawing)
                canvasView.drawing = drawing
            }
            catch {
                print("Error info: \(error)")
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let result = CanvasManager.main.check(selectedDate: selectedDate!)
        
        // If canvas created in database, save drawing to canvas object
        if Mirror(reflecting: result).children.count != 0 {
            print("UPDATE OR DELETE CANVAS")
            // Create canvas object of current drawing
            let canvas = Canvas(id: result[0].id, date: result[0].date, drawing: drawing.dataRepresentation())
            /*
            // if canvas is empty, delete from db
            if drawing.bounds.isEmpty {
                print("DELETE")
                CanvasManager.main.delete(canvas: canvas)
            }
            // else, update drawing
            else {
                print("UPDATE")
                CanvasManager.main.save(canvas: canvas)
            }*/
            print("UPDATING CANVAS")
            CanvasManager.main.save(canvas: canvas)
        }
    }
    
    // hide home button on certain devices
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // When rotate, need to adjust canvas view for drawing
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale // current zoom scale
        
        updateContentSizeForDrawing()
        
        // Scroll to top
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    
    // update contentsize every time drawing changes
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
    }
    
    /* ------------------------------------------------------------------------------------- */
    
    func updateContentSizeForDrawing() {
        let drawing = canvasView.drawing
        let contentHeight: CGFloat // Will be adjust depending on bounds of drawing such that bounds of drawing is always > drawing height
        
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasOverscrollHeight) * canvasView.zoomScale)
        }
        else {
            contentHeight = canvasView.bounds.height
        }
        
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale , height: contentHeight)
    }
    
    // Function to dismiss view
    func dismissView() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
