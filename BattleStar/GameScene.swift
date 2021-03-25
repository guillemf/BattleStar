//
//  GameScene.swift
//  BattleStar
//
//  Created by Guillem Fernandez on 23/3/21.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    private var pilotNode : SKSpriteNode!
    private let flightAnimation = [SKTexture(imageNamed: "Fly (1)"),
                                   SKTexture(imageNamed: "Fly (2)")]
    private let shootAnimation = [SKTexture(imageNamed: "Shoot (1)"),
                                  SKTexture(imageNamed: "Shoot (2)"),
                                  SKTexture(imageNamed: "Shoot (3)"),
                                  SKTexture(imageNamed: "Shoot (4)"),
                                  SKTexture(imageNamed: "Shoot (5)"),]
    private var flyAction: SKAction!
    private var shootAction: SKAction!
    
    private let flyActionKey = "Fly"
    private let shootActionKey = "Shoot"
    private let firstMoveActionKey = "MoveFirst"

    private let motionManager = CMMotionManager()
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "Mountains")
        let bgSize = background.size
        background.size = CGSize(width: bgSize.width * 0.5,
                                 height: bgSize.height * 0.5)
        background.zPosition = -1
        addChild(background)
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.pilotNode = SKSpriteNode(imageNamed: "Fly (1)")
        self.pilotNode?.size = CGSize(width: w * 1.5, height: w)
        
        self.flyAction = SKAction.repeatForever(SKAction.animate(with: self.flightAnimation,
                                                                 timePerFrame: 0.15))
        self.shootAction = SKAction.repeatForever(SKAction.animate(with: self.shootAnimation,
                                                                   timePerFrame: 0.15))
        self.pilotNode.run(self.flyAction, withKey: self.flyActionKey)
        self.pilotNode.position = CGPoint(x: -250, y: -100)
        self.pilotNode.zPosition = 1000
        self.addChild(self.pilotNode)
        
        if let smoke = SKEmitterNode(fileNamed: "Smoke") {
            smoke.position.x = 500
            smoke.zPosition = 11
            smoke.advanceSimulationTime(10)
            addChild(smoke)
        }
        
        motionManager.startAccelerometerUpdates()
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.pilotNode.removeAction(forKey: self.flyActionKey)
            self.pilotNode.run(self.shootAction, withKey: self.shootActionKey)
            let destination = CGPoint(x: self.pilotNode.position.x,
                                      y: touch.location(in: self).y)
            let moveToPoint = SKAction.move(to: destination, duration: 0.5)
            moveToPoint.timingMode = .easeInEaseOut
            self.pilotNode.run(moveToPoint, withKey: firstMoveActionKey)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.pilotNode.removeAction(forKey: firstMoveActionKey)

            let destination = CGPoint(x: self.pilotNode.position.x,
                                      y: touch.location(in: self).y)
            let moveToPoint = SKAction.move(to: destination, duration: 0.05)
            moveToPoint.timingMode = .linear
            self.pilotNode.run(moveToPoint)

        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            self.pilotNode.removeAction(forKey: self.shootActionKey)
            self.pilotNode.run(self.flyAction, withKey: self.flyActionKey)
            self.pilotNode.removeAction(forKey: firstMoveActionKey)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.pilotNode.position.y = touch.location(in: self).y
            self.pilotNode.position.y = touch.location(in: self).y
            self.pilotNode.removeAction(forKey: self.shootActionKey)
            self.pilotNode.run(self.flyAction, withKey: self.flyActionKey)
        }
   }
    
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = self.motionManager.accelerometerData {
            let changeY = CGFloat(accelerometerData.acceleration.y) * 100
            self.pilotNode.position.y += changeY
        }
    }
}
