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
    bird.name = "bird"
    bird.position = pos
    bird.size = birdTexture.size()

    bird.run(makeBirdFlap)

    return bird
}

func backgroundFactory(y: CGFloat, height: CGFloat) -> [SKSpriteNode] {
    let bgTexture = SKTexture(imageNamed: "bg.png")

    let bgVector = CGVector(dx: -bgTexture.size().width, dy: 0)
    let moveBGAnimation = SKAction.move(by: bgVector, duration: 7)

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

func groundFactory(pos: CGPoint, width: CGFloat) -> SKNode {
    let ground = SKNode()
    ground.position = pos
    ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: 1))
    ground.physicsBody?.isDynamic = false
    return ground
}

func startBird(bird: SKSpriteNode) {
    bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
    bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
}

class GameScene: SKScene {

    override func didMove(to view: SKView) {
        let bgs = backgroundFactory(y: self.frame.midY, height: self.frame.height)
        bgs.forEach { self.addChild($0) }
        
        let bird = birdFactory(pos: CGPoint(x: self.frame.midX, y: self.frame.midY))
        self.addChild(bird)
        
        let groundPos = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        let ground = groundFactory(pos: groundPos, width: self.frame.width)
        self.addChild(ground)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bird = self.childNode(withName: "bird") as! SKSpriteNode
        startBird(bird: bird)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
