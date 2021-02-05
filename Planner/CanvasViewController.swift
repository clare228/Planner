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
    
    /* --- Variables --- */
    var selectedDate: Date?
    var drawing = PKDrawing()
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHeight: CGFloat = 500
    
    /* --- Outlets --- */
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var pencilFingerButton: UIBarButtonItem!
    @IBOutlet var canvasView: PKCanvasView!
    @IBAction func fingerPencilToggle (_ sender: Any) {
        canvasView.allowsFingerDrawing.toggle()
        pencilFingerButton.title = canvasView.allowsFingerDrawing ? "Pencil" : "Finger"
    }
    
    
    
    /* ----------------------------- */
    /* --- Auto-called Functions --- */
    /* ----------------------------- */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayDateOnCanvas()
        setupCanvas()
        setupToolpicker()
        loadCanvas()
    }
    
    // hide home button on certain devices
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Adjust canvas view for rotations - called when view's bounds changes
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setCanvasScales()
        updateContentSizeForDrawing()
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
        
        // query returns [Canvas] where date = selectedDate
        let result = CanvasManager.main.check(selectedDate: selectedDate!)
    
        updateAndSaveCanvas(result: result)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Delete current canvas if it is empty
        /*
        let result = CanvasManager.main.check(selectedDate: selectedDate!)
        if canvasIsEmpty() {
            print("DELETE CANVAS")
            CanvasManager.main.delete(canvas: result[0])
        }
        */
        
        deleteCurrentCanvas()
    }
    
    /* ----------------------- */
    /* --- Other Functions --- */
    /* ----------------------- */
    
    func displayDateOnCanvas() {
        if let selectedDate = selectedDate {
            dateLabel.text = CanvasManager.main.dateToStringShow(dateDate: selectedDate)
        }
    }
    
    func setupCanvas() {
        canvasView.delegate = self
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
    }
    
    func updateContentSizeForDrawing() {
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasOverscrollHeight) * canvasView.zoomScale)
        }
        else {
            contentHeight = canvasView.bounds.height
        }
        
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale , height: contentHeight)
    }
    
    func setupToolpicker() {
        if let window = parent?.view.window,
            let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            canvasView.becomeFirstResponder()
        }
    }
    
    func loadCanvas() {
        
        // Query database, return [Canvas] with date as selectedDate
        let result = CanvasManager.main.check(selectedDate: selectedDate!)
        
        if canvasDoesNotExist(result: result) {
            createNewCanvas()
        }
        else {
            loadOldDrawing(result: result)
        }
    }
    
    func canvasDoesNotExist(result: [Canvas]) -> Bool {
        if Mirror(reflecting: result).children.count == 0 {
            return true
        }
        return false
    }
    
    func createNewCanvas() {
        print("CREATING NEW CANVAS")
        _ = CanvasManager.main.create(date: selectedDate!, drawing: drawing.dataRepresentation())
    }
    
    func loadOldDrawing(result: [Canvas]) {
        print("LOAD EXISTING CANVAS")
        
        let canvas = Canvas(id: result[0].id, date: result[0].date, drawing: result[0].drawing)
                   
        do {
            var oldDrawing = PKDrawing()

            try oldDrawing = PKDrawing.init(data: canvas.drawing)
            canvasView.drawing = oldDrawing
        }
        catch {
            print("Error info: \(error)")
        }
    }
    
    func setCanvasScales() {
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
    }
    
    func updateAndSaveCanvas(result: [Canvas]) {

        if !canvasDoesNotExist(result: result) {
            print("UPDATE CANVAS")
            
            // Create canvas object of current drawing
            let canvas = Canvas(id: result[0].id, date: result[0].date, drawing: canvasView.drawing.dataRepresentation())
            
            CanvasManager.main.save(canvas: canvas)
        }
    }
    
    func canvasIsEmpty() -> Bool {
        if canvasView.drawing.bounds.isEmpty {
            return true
        }
        return false
    }
    
    func deleteCurrentCanvas() {
        let result = CanvasManager.main.check(selectedDate: selectedDate!)
        if canvasIsEmpty() {
            print("DELETE CANVAS")
            CanvasManager.main.delete(canvas: result[0])
        }
    }
}
