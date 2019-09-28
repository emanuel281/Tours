//
//  GameScene.m
//  Tours Of Something
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
    NSInteger _numOfDisks;
    NSInteger _yDefaultPos;
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

    _numOfDisks = 3;
    _yDefaultPos = 10*_numOfDisks - 5;
    _disk = _diskOne = (SKShapeNode *)[self childNodeWithName:@"//disk"];
    _disks = [NSMutableArray new];
    
    [self createDisks];
    [self createPillars];

    if (_disk != nil) {
        old_pos = _disk.position;
    }

}

- (void) createPillars {
    //Pillars
    NSInteger xVal = 150 + _numOfDisks * 10;
    SKShapeNode* pillarOne = (SKShapeNode *)[self childNodeWithName:@"//pillar"];
    pillarOne.position = CGPointMake(xVal, 50);
    _pillars = [NSMutableArray new];

    for (NSInteger i = 0; i < 3; i++) {
        SKShapeNode* p = [pillarOne copy];
        p.name = @"pillar";
        p.position = CGPointMake(xVal*i, 50);
        p.xScale = self.size.width * 0.0001;
        
        [_pillars insertObject:p atIndex:i];
        [self addChild:p];
    }
}

- (void) updateDiskInfo: (NSInteger) indx {
    SKShapeNode* d = [_diskOne copy];
    d.name = @"diskN";
    d.xScale += 0.2*indx;
    d.yScale = 0.1;
    d.position = CGPointMake(0, _yDefaultPos-10*indx);
    d.userData[@"size"] = [NSNumber numberWithInteger:1+indx];
    d.fillColor = [NSColor colorWithRed:0.05*indx green:0.1*indx blue:0.15*indx alpha:0.15*indx];
    [_disks insertObject:d atIndex:indx];
    [self addChild:d];
}

- (void) createDisks {
    //Disks created
    NSInteger i = 0;
    do {
        if (i ==  0) {
            _diskOne.position = CGPointMake(0, _yDefaultPos-10*i);
            [_disks insertObject:_diskOne atIndex:i];
            i++;
            continue;
        }
        [self updateDiskInfo:i];
        
        i++;
    } while (i < _numOfDisks);
}


- (void) restartLevel {
    NSInteger i = 0;
    _yDefaultPos = 10*_numOfDisks - 5;

    for (SKShapeNode* disk in _disks) {
        disk.position = CGPointMake(0, _yDefaultPos-10*i);
        i++;
    }
    
    while (i < _numOfDisks) {
        [self updateDiskInfo:i];
        i++;
    }
}

- (void) nextLevel {
    _numOfDisks = _numOfDisks < 11 ? _numOfDisks+1 : _numOfDisks;
    [self restartLevel];
}

- (void) prevLevel {
    if (_disks.count > 3) {
        NSInteger i = 0;
        
        _numOfDisks = _numOfDisks > 1 ? _numOfDisks-1 : _numOfDisks;
        _yDefaultPos = 10*_numOfDisks - 5;

        for (SKShapeNode* disk in _disks) {
            disk.position = CGPointMake(0, _yDefaultPos-10*i);
            i++;
        }
        
        SKShapeNode* disk = [_disks lastObject];
        NSArray<SKShapeNode*> *nodes = @[disk];
        [_disks removeLastObject];
        [self removeChildrenInArray:nodes];
    }
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
    // Calculate yAxis offset when dropping disk on pillar
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

- (short) isLegalMove {
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

- (short)isLevelCompleted {
    SKShapeNode* lastPillar = [_pillars lastObject];
    for (SKShapeNode* disk in _disks) {
        if (disk.position.x != lastPillar.position.x) {
            return 0;
        }
    }
    return 1;
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
    
    if ([self isLevelCompleted]) {
        [self nextLevel];
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    switch (theEvent.keyCode) {
        case 0x31 /* SPACE */:
            // Run 'Pulse' action from 'Actions.sks'
//            [_label runAction:[SKAction actionNamed:@"Pulse"] withKey:@"fadeInOut"];
            break;
        case 0x0F: /* R */
            // Needs to restart level!
            
            [self restartLevel];
            break;
        case 0x7C: /* right-arrow */
            // Next level
            [self nextLevel];
            break;
        case 0x7B: /* left-arrow */
            // Previous level
            [self prevLevel];
            break;
        case 0x0C: /* Q */
            exit(0);
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
