//
//  GameOverScene.swift
//  IK-Ninja
//
//  Created by Matt Larkin on 7/24/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    override func didMoveToView(view: SKView) {

        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Game Over"
        myLabel.fontSize = 65
        myLabel.position = CGPoint(x:CGRectGetMidX(frame), y:CGRectGetMidY(frame))
        addChild(myLabel)

        runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock({
                let transition = SKTransition.fadeWithDuration(1.0)
                let scene = GameScene(fileNamed:"GameScene")
                let skView = self.view as SKView!
                scene.scaleMode = .AspectFill
                scene.size = skView.bounds.size
                self.view?.presentScene(scene, transition: transition)
            })]))
    }
}