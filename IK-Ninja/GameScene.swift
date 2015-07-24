//
//  GameScene.swift
//  IK-Ninja
//
//  Created by Ken Toh on 7/9/14.
//  Copyright (c) 2014 Ken Toh. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var shadow: SKNode!
    var lowerTorso: SKNode!
    var upperTorso: SKNode!
    var upperArmFront: SKNode!
    var lowerArmFront: SKNode!
    var fistFront: SKNode!
    var upperArmBack: SKNode!
    var lowerArmBack: SKNode!
    var fistBack: SKNode!
    var head: SKNode!
    var upperLeg: SKNode!
    var lowerLeg: SKNode!
    var foot: SKNode!


    var rightPunch = true
    var firstTouch = false

    let upperArmAngleDeg: CGFloat = -10
    let lowerArmAngleDeg: CGFloat = 130
    let upperLegAngleDeg: CGFloat = 22
    let lowerLegAngleDeg: CGFloat = -30
    let targetNode = SKNode()

    var lastSpawnTimeInterval: NSTimeInterval = 0
    var lastUpdateTimeInterval: NSTimeInterval = 0

    var score: Int = 0
    var life: Int = 3


    let scoreLabel = SKLabelNode()
    let livesLabel = SKLabelNode()

    override func didMoveToView(view: SKView) {

    lowerTorso = childNodeWithName("torso_lower")
    lowerTorso.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame) - 30)

    shadow = childNodeWithName("shadow")
    shadow.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame) - 100)

    upperTorso = lowerTorso.childNodeWithName("torso_upper")
    upperArmFront = upperTorso.childNodeWithName("arm_upper_front")
    lowerArmFront = upperArmFront.childNodeWithName("arm_lower_front")
    fistFront = lowerArmFront.childNodeWithName("fist_front")
    upperArmBack = upperTorso.childNodeWithName("arm_upper_back")
    lowerArmBack = upperArmBack.childNodeWithName("arm_lower_back")
    fistBack = lowerArmBack.childNodeWithName("fist_back")

    head = upperTorso.childNodeWithName("head")


    let orientToNodeConstraint = SKConstraint.orientToNode(targetNode, offset: SKRange(constantValue: 0.0))
    let range = SKRange(lowerLimit: CGFloat(-50).degreesToRadians(),upperLimit: CGFloat(80).degreesToRadians())

    let rotationConstraint = SKConstraint.zRotation(range)

    rotationConstraint.enabled = false
    orientToNodeConstraint.enabled = false

    head.constraints = [orientToNodeConstraint, rotationConstraint]

    upperLeg = lowerTorso.childNodeWithName("leg_upper_back")
    lowerLeg = upperLeg.childNodeWithName("leg_lower_back")
    foot = lowerLeg.childNodeWithName("foot_back")

    lowerLeg.reachConstraints = SKReachConstraints(lowerAngleLimit: CGFloat(-45).degreesToRadians(), upperAngleLimit: 0)
    upperLeg.reachConstraints = SKReachConstraints(lowerAngleLimit: CGFloat(-45).degreesToRadians(), upperAngleLimit: CGFloat(160).degreesToRadians())

        // setup score label
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        scoreLabel.position = CGPoint(x: 10, y: size.height -  10)
        addChild(scoreLabel)

        // setup lives label
        livesLabel.fontName = "Chalkduster"
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 20
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        livesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        livesLabel.position = CGPoint(x: size.width - 10, y: size.height - 10)
        addChild(livesLabel)

    }

    func punchAtLocation(location: CGPoint, upperArmNode: SKNode, lowerArmNode: SKNode, fistNode: SKNode) {
        let punch = SKAction.reachTo(location, rootNode: upperArmNode, duration: 0.1)
        let restore = SKAction.runBlock {
            upperArmNode.runAction(SKAction.rotateToAngle(self.upperArmAngleDeg.degreesToRadians(), duration: 0.1))
            lowerArmNode.runAction(SKAction.rotateToAngle(self.lowerArmAngleDeg.degreesToRadians(), duration: 0.1))
        }

        let checkIntersection = intersectionCheckActionForNode(fistNode)
        fistNode.runAction(SKAction.sequence([punch, checkIntersection, restore]))

    }

    func punchAtLocation(location: CGPoint) {
        if rightPunch {
            punchAtLocation(location, upperArmNode: upperArmFront, lowerArmNode: lowerArmFront, fistNode: fistFront)
        }

        else {
            punchAtLocation(location, upperArmNode: upperArmBack, lowerArmNode: lowerArmBack, fistNode: fistBack)
        }
        rightPunch = !rightPunch
    }


    func addShuriken() {

        let shuriken = SKSpriteNode(imageNamed: "projectile")

        let minY = lowerTorso.position.y - 60 + shuriken.size.height/2
        let maxY = lowerTorso.position.y + 140 - shuriken.size.height/2
        let rangeY = maxY - minY
        let actualY = (CGFloat(arc4random()) % rangeY) + minY

        let left = arc4random() % 2
        var actualX = (left == 0) ? -shuriken.size.width/2 : size.width + shuriken.size.width/2

        shuriken.position = CGPointMake(actualX, actualY)
        shuriken.name = "shuriken"
        shuriken.zPosition = 1
        addChild(shuriken)

        let minDuration = 4.0
        let maxDuration = 6.0
        let rangeDuration = maxDuration - minDuration
        let actualDuration = (Double(arc4random()) % rangeDuration) + minDuration

        let actionMove = SKAction.moveTo(CGPointMake(size.width/2, actualY), duration: actualDuration)
        let actionMoveDone = SKAction.removeFromParent()

        let hitAction = SKAction.runBlock({
            // 1
            if self.life > 0 {
                self.life--
            }
            // 2
            self.livesLabel.text = "Lives: \(Int(self.life))"

            // 3
            let blink = SKAction.sequence([SKAction.fadeOutWithDuration(0.05), SKAction.fadeInWithDuration(0.05)])

            // 4
            let checkGameOverAction = SKAction.runBlock({
                if self.life <= 0 {
                    let transition = SKTransition.fadeWithDuration(1.0)
                    let skView = self.view! as SKView
                    let gameOverScene = GameOverScene(size: skView.bounds.size)
                    self.view?.presentScene(gameOverScene, transition: transition)
                }
            })
            // 5
            self.lowerTorso.runAction(SKAction.sequence([blink, blink, checkGameOverAction]))
        })

        shuriken.runAction(SKAction.sequence([actionMove, hitAction, actionMoveDone]))
        let angle = left == 0 ? CGFloat(-90).degreesToRadians() : CGFloat(90).degreesToRadians()
        let rotate = SKAction.repeatActionForever(SKAction.rotateByAngle(angle, duration: 0.2))
        shuriken.runAction(SKAction.repeatActionForever(rotate))
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {

            if !firstTouch {
                for c in head.constraints! {
                    var constraint = c as! SKConstraint
                    constraint.enabled = true
                }
                firstTouch = true
            }

            let location = touch.locationInNode(self)
            let lower = location.y < lowerTorso.position.y + 10
            if lower {
                kickAtLocation(location)
            }
            else {
                punchAtLocation(location)
            }
            targetNode.position = location

            lowerTorso.xScale = location.x < CGRectGetMidX(frame) ? abs(lowerTorso.xScale) * -1: abs(lowerTorso.xScale)
        }
    }

    func updateWithTimeSinceLastUpdate(timeSinceLast: CFTimeInterval) {
        lastSpawnTimeInterval = timeSinceLast + lastSpawnTimeInterval
        if lastSpawnTimeInterval > 0.75 {
            lastSpawnTimeInterval = 0
            addShuriken()
        }
    }

    override func update(currentTime: NSTimeInterval) {
        var timeSinceLast = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        if timeSinceLast > 1.0 {
            timeSinceLast = 1.0 / 60.0
            lastUpdateTimeInterval = currentTime
        }
        updateWithTimeSinceLastUpdate(timeSinceLast)
    }


    func intersectionCheckActionForNode(effectorNode: SKNode) -> SKAction {
        let checkIntersection = SKAction.runBlock {

            for object: AnyObject in self.children {
                // check for intersection against any sprites named "shuriken"
                if let node = object as? SKSpriteNode {
                    if node.name == "shuriken" {
                        if node.intersectsNode(effectorNode) {
                            // play a hit sound
                            self.runAction(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false))

                            // show a spark effect
                            let spark = SKSpriteNode(imageNamed: "spark")
                            spark.position = node.position
                            spark.zPosition = 60
                            self.addChild(spark)
                            let fadeAndScaleAction = SKAction.group([
                                SKAction.fadeOutWithDuration(0.2),
                                SKAction.scaleTo(0.1, duration: 0.2)])
                            let cleanUpAction = SKAction.removeFromParent()
                            spark.runAction(SKAction.sequence([fadeAndScaleAction, cleanUpAction]))

                            self.score++
                            self.scoreLabel.text = "Score: \(Int(self.score))"

                            // remove the shuriken
                            node.removeFromParent()
                        }
                        else {
                            // play a miss sound
                            self.runAction(SKAction.playSoundFileNamed("miss.mp3", waitForCompletion: false))
                        }
                    }
                }
            }
        }
        return checkIntersection
    }


    func kickAtLocation(location: CGPoint) {
        let kick = SKAction.reachTo(location, rootNode: upperLeg, duration: 0.1)

        let restore = SKAction.runBlock {
            self.upperLeg.runAction(SKAction.rotateToAngle(self.upperLegAngleDeg.degreesToRadians(), duration: 0.1))
            self.lowerLeg.runAction(SKAction.rotateToAngle(self.lowerLegAngleDeg.degreesToRadians(), duration: 0.1))
        }

        let checkIntersection = intersectionCheckActionForNode(foot)

        foot.runAction(SKAction.sequence([kick, checkIntersection, restore]))
    }



}
