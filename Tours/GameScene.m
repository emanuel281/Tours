//
//  GameScene.m
//  Tours
//
//  Created by Emanuel Magxothwa on 2019/09/25.
//  Copyright © 2019 Maze. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene {
    NSTimeInterval _lastUpdateTime;
//    SKShapeNode *_spinnyNode;
//    SKLabelNode *_label;
    NSMutableArray<SKShapeNode*> *_pillars;

    SKShapeNode *_diskOne;
    NSMutableArray<SKShapeNode*> *_disks;
    SKShapeNode *_disk;
    CGPoint old_pos;
}

- (void)sceneDidLoad {
    // Setup your scene here
    
    // Initialize update time
    _lastUpdateTime = 0;
    
    // Get label node from scene and store it for use later
//    _label = (SKLabelNode *)[self childNodeWithName:@"//helloLabel"];
//    
//    _label.alpha = 0.0;
//    [_label runAction:[SKAction fadeInWithDuration:2.0]];
    
//    CGFloat w = (self.size.width + self.size.height) * 0.05;

//    _spinnyNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.3];
//    _spinnyNode.lineWidth = 2.5;
//
//    [_spinnyNode runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI duration:1]]];
//    [_spinnyNode runAction:[SKAction sequence:@[
//                                                [SKAction waitForDuration:0.5],
//                                                [SKAction fadeOutWithDuration:0.5],
//                                                [SKAction removeFromParent],
//                                                ]]];

    //Disks created
    _disk = _diskOne = (SKShapeNode *)[self childNodeWithName:@"//diskOne"];
    _disks = [NSMutableArray new];
    int i = 0;
    int numOfDisks = 5;
    do {
        int yPos = 10*numOfDisks-10*i - 5;
        if (i ==  0) {
            _diskOne.position = CGPointMake(_disk.position.x, yPos);
            [_disks insertObject:_diskOne atIndex:i];
            i++;
            continue;
        }
        SKShapeNode* d = [_diskOne copy];
        d.name = @"disk";
        d.xScale += 0.2*i;
        d.yScale = 0.1;
        d.position = CGPointMake(d.position.x, yPos);
        d.userData[@"size"] = [NSNumber numberWithInt:1+i];
        [_disks insertObject:d atIndex:i];
        [self addChild:d];
        i++;
    } while (i < numOfDisks);

    
    //Pillars
    SKShapeNode* pillarOne = (SKShapeNode *)[self childNodeWithName:@"//pillarOne"];
    _pillars = [NSMutableArray new];
    for (NSInteger i = 0; i < 3; i++) {
        SKShapeNode* p = [pillarOne copy];
        p.name = @"pillar";
        p.position = CGPointMake(pillarOne.position.x+(150*i), 50);
        p.xScale = self.size.width * 0.0001;
        
        [_pillars insertObject:p atIndex:i];
        [self addChild:p];
    }

    old_pos = _disk.position;
    
}


- (void)chooseDisk: (CGPoint)pos {
    float h = 100.0;

    for (SKShapeNode* disk in _disks) {
        if ((disk.position.x-75) <= pos.x && pos.x <= (disk.position.x+75)) {
            float dh = 100 - disk.position.y;
            if (dh <= h) {
                h = dh;
                _disk = disk;
            }
        }
    }
    
}

- (NSInteger)overDisks: (CGPoint) pos {
    NSInteger multiple = 5;
    
    for (SKShapeNode* disk in _disks) {
        if (_disk != disk) {
            if ((disk.position.x-75) <= pos.x && pos.x <= (disk.position.x+75)) {
                multiple += 10;
            }
        }
    }
    
    return multiple;
}

- (int) isLegalMove {
    for (SKShapeNode* disk in _disks) {
        if (_disk != disk) {
            if ((disk.position.x-75) <= _disk.position.x && _disk.position.x <= (disk.position.x+75)) {
                if (_disk.userData[@"size"] > disk.userData[@"size"]) {
                    return 0;
                }
            }
        }
    }

    return 1;
}

- (void)touchDownAtPoint:(CGPoint)pos {
    [self chooseDisk:pos];
    
    if ((_disk.position.x-75) <= pos.x && pos.x <= (_disk.position.x+75)) {
        old_pos = _disk.position;
    }
}

- (void)touchMovedToPoint:(CGPoint)pos {
    if ((_disk.position.x-75) <= pos.x && pos.x <= (_disk.position.x+75)) {
        _disk.position = pos;
    }
    
}

- (void)touchUpAtPoint:(CGPoint)pos {
    if ((_disk.position.x-75) <= pos.x && pos.x <= (_disk.position.x+75)) {
        NSInteger multiple = [self overDisks:pos];
        NSInteger new_pos = 0;
        
        for (SKShapeNode* pillar in _pillars) {
            if (pillar.position.x-75 <= pos.x && pos.x <= pillar.position.x+75) {
                if ([self isLegalMove]) {
                    _disk.position = CGPointMake(pillar.position.x, multiple);
                    new_pos += 1;
                } else {
                    _disk.position = old_pos;
                }
            }
        }
        
        if (new_pos <= 0) {
            _disk.position = old_pos;
        }
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    switch (theEvent.keyCode) {
        case 0x31 /* SPACE */:
            // Run 'Pulse' action from 'Actions.sks'
//            [_label runAction:[SKAction actionNamed:@"Pulse"] withKey:@"fadeInOut"];
            break;
        default:
            NSLog(@"keyDown:'%@' keyCode: 0x%02X", theEvent.characters, theEvent.keyCode);
            break;
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self touchDownAtPoint:[theEvent locationInNode:self]];
}
- (void)mouseDragged:(NSEvent *)theEvent {
    [self touchMovedToPoint:[theEvent locationInNode:self]];
}
- (void)mouseUp:(NSEvent *)theEvent {
    [self touchUpAtPoint:[theEvent locationInNode:self]];
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    
    // Initialize _lastUpdateTime if it has not already been
    if (_lastUpdateTime == 0) {
        _lastUpdateTime = currentTime;
    }
    
    // Calculate time since last update
    CGFloat dt = currentTime - _lastUpdateTime;
    
    // Update entities
    for (GKEntity *entity in self.entities) {
        [entity updateWithDeltaTime:dt];
    }
    
    _lastUpdateTime = currentTime;
}

@end
