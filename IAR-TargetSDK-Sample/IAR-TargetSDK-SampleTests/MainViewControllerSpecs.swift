//
//  IAR_TargetSDK_SampleTests.swift
//  IAR-TargetSDK-SampleTests
//
//  Created by Rogerio on 2021-12-11.
//

import XCTest
import Nimble
import Quick
import SpecLeaks

@testable import IAR_TargetSDK_Sample

class MainViewControllerSpecs: QuickSpec {
    
    private func mainVCFactory() -> MainViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(identifier: "MainScreen") as? MainViewController {
            return mainVC
        } else {
            fatalError("Failed to initialize MainViewController")
        }
    }
    
    override func spec() {
        describe("the MainViewController") {
            describe("init") {
                it("should initialize properly") {
                    let sut = self.mainVCFactory()
                    expect(sut).toNot(beNil())
                    expect(sut.view).toNot(beNil())
                }
                
                it("should not leak") {
                    let leakTest = LeakTest {
                        return self.mainVCFactory()
                    }
                    
                    let action: (MainViewController) -> () = { vc in
                        /*
                         // Add the following to MainViewController for a sample leak
                         
                         private var anyObject : AnyObject? = nil
                         
                         public func createExposedLeak() {
                         self.anyObject = self
                         }
                         */
                        
                        // and add a call to the leaking method here
                        // vc.createExposedLeak()
                        
                        let window = UIWindow()
                        let vc = self.mainVCFactory()
                        window.rootViewController = vc
                        window.makeKeyAndVisible()
                    }
                    
                    expect(leakTest).toNot(leakWhen(action))
                }
            }
        }
    }
}
