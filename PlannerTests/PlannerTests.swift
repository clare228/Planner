//
//  PlannerTests.swift
//  PlannerTests
//
//  Created by Andrea Clare Lam on 30/12/2020.
//  Copyright © 2020 Andrea Clare Lam. All rights reserved.
//

import XCTest
import PencilKit

@testable import Planner

class PlannerTests: XCTestCase {
    
    /* --- This class tests non-UI-related functions --- */

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /* ------------------------------------------------- */
    /* --- test CanvasViewController.swift functions --- */
    /* ------------------------------------------------- */

    func test_canvasDoesNotExist_false() throws {
        let id = 0
        let date = Date.init()
        let drawing = PKDrawing()
        
        let canvas = Canvas(id: id, date: date, drawing: drawing.dataRepresentation())
        
        let result: [Canvas] = [canvas]
        let canvasView = CanvasViewController()
        
        XCTAssertFalse(canvasView.canvasDoesNotExist(result: result))
    }
    
    func test_canvasDoesNotExist_true() throws {
        
        let result: [Canvas] = []
        let canvasView = CanvasViewController()
        
        XCTAssertTrue(canvasView.canvasDoesNotExist(result: result))
    }


    /* ----------------------------------- */
    /* --- test Canvas.swift functions --- */
    /* ----------------------------------- */
    
    func test_stringToDateFormat() throws {
        let canvas = CanvasManager()
        let dateString = "2020-12-30T00:00:00Z"
        let dateDate = "2020-12-30 00:00:00 +0000"
        XCTAssertEqual(canvas.stringToDateFormat(stringDate: dateString).description, dateDate)
    }
    
    func test_dateToStringFormat() throws {
        let canvas = CanvasManager()
        let dateString = "2020-12-30T00:00:00Z"
        XCTAssertEqual(canvas.dateToStringFormat(dateDate: canvas.stringToDateFormat(stringDate: dateString)), dateString)
    }
    
    func test_dateToStringShow() throws {
        let canvas = CanvasManager()
        let dateString = "2020-12-30T00:00:00Z"
        let dateShow = "Dec 30, 2020"
        XCTAssertEqual(canvas.dateToStringShow(dateDate: canvas.stringToDateFormat(stringDate: dateString)), dateShow)
    }
    

}
