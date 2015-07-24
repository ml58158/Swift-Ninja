//
//  GameViewController.swift
//  IK-Ninja
//
//  Created by Ken Toh on 7/9/14.
//  Copyright (c) 2014 Ken Toh. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

var audioPlayer: AVAudioPlayer?

extension SKNode {
  class func unarchiveFromFile(file : NSString) -> SKNode? {
    if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
      var sceneData = NSData(contentsOfFile:path, options: .DataReadingMappedIfSafe, error: nil)
      var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
            
      archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
      let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
      archiver.finishDecoding()
      return scene
    } else {
      return nil
    }
  }
}

class GameViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

      if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
            
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
            
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
          
        // Set the view bounds dynamically
        scene.size = skView.bounds.size
          
        skView.presentScene(scene)

        startBackgroundMusic()
    }
  }

  override func shouldAutorotate() -> Bool {
    return true
  }

  override func supportedInterfaceOrientations() -> Int {
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
      return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    } else {
      return Int(UIInterfaceOrientationMask.All.rawValue)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
      // Release any cached data, images, etc that aren't in use.
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }

    func startBackgroundMusic() {
        if let path = NSBundle.mainBundle().pathForResource("bg", ofType: "mp3") {
            audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path), fileTypeHint: "mp3", error: nil)
            if let player = audioPlayer {
                player.prepareToPlay()
                player.numberOfLoops = -1
                player.play()
            }
        }
    }

}
