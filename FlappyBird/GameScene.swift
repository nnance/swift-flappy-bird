//
//  GameScene.swift
//  FlappyBird
//
//  Created by Nick Nance on 10/4/20.
//

import SpriteKit

func birdFactory(pos: CGPoint) -> SKSpriteNode {
    let birdTexture = SKTexture(imageNamed: "flappy1.png")
    let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
    
    let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
    let makeBirdFlap = SKAction.repeatForever(animation)

    let bird = SKSpriteNode(texture: birdTexture)
    bird.position = pos
    
    bird.run(makeBirdFlap)

    return bird
}

func backgroundFactory(y: CGFloat, height: CGFloat) -> [SKSpriteNode] {
    let bgTexture = SKTexture(imageNamed: "bg.png")

    let bgVector = CGVector(dx: -bgTexture.size().width, dy: 0)
    let moveBGAnimation = SKAction.move(by: bgVector, duration: 3)

    let shiftVector = CGVector(dx: bgTexture.size().width, dy: 0)
    let shiftBGAnimation = SKAction.move(by: shiftVector, duration: 0)

    let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))

    var i: CGFloat = 0
    var results: [SKSpriteNode] = []
    
    while i < 3 {
        let bg = SKSpriteNode(texture: bgTexture)
        bg.position = CGPoint(x: bgTexture.size().width * i, y: y)
        bg.size.height = height
        bg.zPosition = -1
        bg.run(moveBGForever)
        results.append(bg)

        i += 1
    }
    return results
}

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        let bgs = backgroundFactory(y: self.frame.midY, height: self.frame.height)
        bgs.forEach { self.addChild($0) }
        
        let bird = birdFactory(pos: CGPoint(x: self.frame.midX, y: self.frame.midY))
        self.addChild(bird)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
