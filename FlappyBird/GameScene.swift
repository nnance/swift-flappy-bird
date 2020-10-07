//
//  GameScene.swift
//  FlappyBird
//
//  Created by Nick Nance on 10/4/20.
//

import SpriteKit

enum ColliderType: UInt32 {
    case Bird = 1
    case Object = 2
    case Gap = 4
}

func setCollision(node: SKNode, type: ColliderType) {
    node.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
    node.physicsBody?.categoryBitMask = type.rawValue
    node.physicsBody?.collisionBitMask = type.rawValue
}

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
    setCollision(node: ground, type: ColliderType.Object)
    return ground
}

func topPipeFactory(pos: CGPoint, offset: CGFloat) -> SKSpriteNode {
    let pipeTexture = SKTexture(imageNamed: "pipe1.png")
    let pipe = SKSpriteNode(texture: pipeTexture)
    pipe.position = CGPoint(x: pos.x, y: pos.y + pipeTexture.size().height / 2 + offset)
    pipe.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
    pipe.physicsBody?.isDynamic = false
    setCollision(node: pipe, type: ColliderType.Object)
    return pipe
}

func bottomPipeFactory(pos: CGPoint, offset: CGFloat) -> SKSpriteNode {
    let pipeTexture = SKTexture(imageNamed: "pipe2.png")
    let pipe = SKSpriteNode(texture: pipeTexture)
    pipe.position = CGPoint(x: pos.x, y: pos.y - pipeTexture.size().height / 2 + offset)
    pipe.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
    pipe.physicsBody?.isDynamic = false
    setCollision(node: pipe, type: ColliderType.Object)
    return pipe
}

func pipeFactory(bird: SKSpriteNode , frame: CGRect) -> [SKNode] {
    let movementAmmount = CGFloat(arc4random() % UInt32(frame.height / 2))
    let pipeOffset = movementAmmount - frame.height / 4

    let gapHeight = (bird.size.height * 4) / 2

    let pipeMove = SKAction.move(by: CGVector(dx: -2 * frame.width, dy: 0), duration: TimeInterval(frame.width / 100))
    let pipeStart = CGPoint(x: frame.midX + frame.width, y: frame.midY)
    
    let top = topPipeFactory(pos: pipeStart, offset: pipeOffset + gapHeight)
    top.run(pipeMove)

    let bottom = bottomPipeFactory(pos: pipeStart, offset: pipeOffset - gapHeight)
    bottom.run(pipeMove)
    
    let gapNode = SKNode()
    gapNode.position = CGPoint(x: frame.midX + frame.width, y: frame.midY + pipeOffset)
    gapNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: top.size.width, height: gapHeight))
    gapNode.physicsBody?.isDynamic = false
    gapNode.run(pipeMove)
    gapNode.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
    gapNode.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
    gapNode.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue

    return [top, bottom, gapNode]
}

func sceneFactory(frame: CGRect) -> [SKNode] {
    let bgs = backgroundFactory(y: frame.midY, height: frame.height)
    
    let bird = birdFactory(pos: CGPoint(x: frame.midX, y: frame.midY))
    
    let groundPos = CGPoint(x: frame.midX, y: -frame.height / 2)
    let ground = groundFactory(pos: groundPos, width: frame.width)
    
    let pipes = pipeFactory(bird: bird, frame: frame)
    
    let nodes = [bird, ground]
    return Array([ bgs, nodes, pipes ].joined())
}

func startBird(bird: SKSpriteNode) {
    bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
    bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    setCollision(node: bird, type: ColliderType.Bird)
}

func flapBird(bird: SKSpriteNode) {
    bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var started = false
    var ended = false
    
    @objc func makePipes() {
        let bird = self.childNode(withName: "bird") as! SKSpriteNode

        let pipes = pipeFactory(bird: bird, frame: self.frame)
        pipes.forEach { self.addChild($0) }
    }

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        let nodes = sceneFactory(frame: self.frame)
        nodes.forEach { self.addChild($0) }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bird = self.childNode(withName: "bird") as! SKSpriteNode
        if (!self.started) {
            startBird(bird: bird)
            self.started = true
        } else if (!self.ended) {
            flapBird(bird: bird)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            print("add one to score")
        } else {
            self.speed = 0
            self.ended = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
