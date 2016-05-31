//
//  GameScene.swift
//  NIGHTBLASTER
//
//  Created by Austin Katz on 4/7/16.
//  Copyright (c) 2016 Austin Katz. All rights reserved.
//

import SpriteKit


//standard implementations of some vector math functions.

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

//marks GameScene as implementing the SKPhysicsContactDelegate protocol:
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //    Collision Detection and Physics: Implementation
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Monster   : UInt32 = 0b1       // 1
        static let Projectile: UInt32 = 0b10      // 2
        static let target2: UInt32 = 0b10      // 2
    }
    
    
    // 1
    
    
    
    
    let player = SKSpriteNode(imageNamed: "player1")
    
    override func didMoveToView(view: SKView)
    {
        
        let target2 = SKSpriteNode(imageNamed:"target2")
        
        target2.position = CGPointMake(self.frame.size.width/1.2, self.frame.size.height/1.01)
        let moveLeft = SKAction.moveByX(-445, y:0, duration:3.0)
        
        let moveRight = SKAction.moveByX(445, y:0, duration:3.0)
        let sequence = SKAction.sequence([moveLeft, moveRight]);
        
        let endlessAction = SKAction.repeatActionForever(sequence)
        target2.runAction(endlessAction)
        
        self.addChild(target2)
        
        let target1 = SKSpriteNode (imageNamed: "target1")
        
        target1.position = CGPointMake(self.frame.size.width/5.88, self.frame.size.height/80)
        let moveR = SKAction.moveByX(445, y:0, duration:3.0)
        let moveL = SKAction.moveByX(-445, y:0, duration:3.0)
        let sequence1 = SKAction.sequence([moveR, moveL]);
        let endlessAction1 = SKAction.repeatActionForever(sequence1)
        target1.runAction(endlessAction1)
        self.addChild(target1)
        
        
        
        var bgImage = SKSpriteNode(imageNamed: "fieldline1.png")
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        
        self.addChild(bgImage)
        
        
        // 2
        backgroundColor = SKColor.blackColor()
        // 3
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        // 4
        let rotatePlayer = SKAction.rotateToAngle(-CGFloat(M_PI)/2, duration: 0.1)
        player.runAction(rotatePlayer)
        addChild(player)
        
        
        //        applies physics to player
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                
                ])
            ))
        
        //        background music
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic) }
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
        
        
    }
    
    func addMonster() {
        
        
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "worker1")
        //        Creates a physics body for the sprite. In this case, the body is defined as a rectangle of the same size of the sprite, because that’s a decent approximation for the monster.
        //        Sets the sprite to be dynamic. This means that the physics engine will not control the movement of the monster – you will through the code you’ve already written (using move actions).
        //        Sets the category bit mask to be the monsterCategory you defined earlier.
        //        The contactTestBitMask indicates what categories of objects this object should notify the contact listener when they intersect. You choose projectiles here.
        //        The collisionBitMask indicates what categories of objects this object that the physics engine handle contact responses to (i.e. bounce off of). You don’t want the monster and projectile to bounce off each other – it’s OK for them to go right through each other in this game – so you set this to 0.
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        
        // Create the actions
        let moveout = SKAction.moveByX(-79, y:0, duration:3.0)
        let movein = SKAction.moveByX(79, y:0, duration:3.0)
        let sequence2 = SKAction.sequence([moveout, movein]);
        let endlessAction2 = SKAction.repeatActionForever(sequence2)
        monster.runAction(endlessAction2)
        // Add the monster to the scene
        addChild(monster)
        
    }
    
    
    
    
    
    //    Here you declare a private constant for the player (i.e. the ninja), which is an example of a sprite. As you can see, creating a sprite is easy – simply pass in the name of the image to use.
    //    Setting the background color of a scene in Sprite Kit is as simple as setting the backgroundColor property. Here you set it to white.
    //    You position the sprite to be 10% across vertically, and centered horizontally.
    //    To make the sprite appear on the scene, you must add it as a child of the scene. This is similar to how you make views children of other views.
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //        sound effect
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "bullet1")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 1.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    //     add a method that will be called when the projectile collides with the monster.
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
    

        func projectileDidCollideWithTarget2(projectile:SKSpriteNode, target2:SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
    
        }
    }
    
    // implement the contact delegate method. Add the following new method to the file:
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
                    
        }
        
    }
    
}