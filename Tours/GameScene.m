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
    SKLabelNode *_title;
    NSMutableArray<SKShapeNode*> *_pillars;
    NSMutableArray<SKShapeNode*> *_disks;
    SKShapeNode *_disk;
    CGPoint old_pos;
    NSInteger _numOfDisks;
    CGFloat _yDefaultPos;
    CGFloat _diskHeight;
    CGFloat _diskBaseWidth;
}

- (void)sceneDidLoad {
    // Setup your scene here
    
    // Initialize update time
    _lastUpdateTime = 0;

    _numOfDisks = 3;
    _diskHeight = 15.0;
    _diskBaseWidth = 50;
    _yDefaultPos = _diskHeight*(_numOfDisks-0.5);
    _disks = [NSMutableArray new];
    
    [self startLevel];
    [self createPillars];
    
    _title = (SKLabelNode*)[self childNodeWithName:@"//title"];
    SKShapeNode* pillar = [_pillars objectAtIndex:_pillars.count/2];
    _title.position = CGPointMake(pillar.position.x, self.size.height/2.5);

}

- (void) createPillars {
    //Pillars
    NSInteger xVal = 150.0 + _numOfDisks * _diskBaseWidth;
    _pillars = [NSMutableArray new];
    CGFloat w = self.size.width*0.01;
    CGFloat h = self.size.height*0.15;

    for (NSInteger i = 0; i < 3; i++) {
        SKShapeNode* pillar = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, h) cornerRadius:w * 0.3];
        pillar.lineWidth = 2.5;
        pillar.fillColor = [SKColor redColor];
        pillar.name = @"pillar";
        pillar.position = CGPointMake(xVal*i, h/2);
        
        [_pillars insertObject:pillar atIndex:i];
        [self addChild:pillar];
    }
}

- (void) updateDiskInfo: (NSInteger) indx {
    
    CGFloat width = _diskBaseWidth;
    if (_disks.count) {
        SKShapeNode* last = [_disks lastObject];
        width = last.frame.size.width + 10;
    }
    SKShapeNode* d = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(width, _diskHeight) cornerRadius:0.3];
    
    d.lineWidth = 0.5;
    d.name = @"diskN";
    d.position = CGPointMake(0, _yDefaultPos-_diskHeight*indx);
    d.userData[@"size"] = [NSNumber numberWithInteger:1+indx];
    d.fillColor = [NSColor colorWithRed:0.05*indx green:0.1*indx blue:0.15*indx alpha:0.15*indx];
    [_disks insertObject:d atIndex:indx];
    [self addChild:d];
}


- (void) startLevel {
    NSInteger i = 0;
    _yDefaultPos = _diskHeight*(_numOfDisks-0.5);

    for (SKShapeNode* disk in _disks) {
        CGPoint position = CGPointMake(0, _yDefaultPos-_diskHeight*i);
        [disk runAction:[SKAction moveTo:position duration:0.3]];
        i++;
    }
    
    while (i < _numOfDisks) {
        [self updateDiskInfo:i];
        i++;
    }
}

- (void) nextLevel {
    _numOfDisks = _numOfDisks < 11 ? _numOfDisks+1 : _numOfDisks;
    [self startLevel];
    SKShapeNode* lastDisk = [_disks lastObject];
    lastDisk.alpha = 0.0;
    [lastDisk runAction:[SKAction group:@[
                                             [SKAction rotateToAngle:-M_PI duration:1],
                                             [SKAction fadeInWithDuration:1]
                                             ]]];
}

- (void) prevLevel {
    if (_disks.count > 3) {
        NSInteger i = 0;
        
        _numOfDisks = _numOfDisks > 1 ? _numOfDisks-1 : _numOfDisks;
        _yDefaultPos = _diskHeight*(_numOfDisks - 0.5);

        for (SKShapeNode* disk in _disks) {
            CGPoint position = CGPointMake(0, _yDefaultPos-_diskHeight*i);
            [disk runAction:[SKAction moveTo:position duration:0.3]];
            i++;
        }
        
        SKShapeNode* disk = [_disks lastObject];
        NSArray<SKShapeNode*> *nodes = @[disk];
        [_disks removeLastObject];
        [self removeChildrenInArray:nodes];
    }
}


- (void)chooseDisk: (CGPoint)pos {
    float h = 0;

    for (SKShapeNode* disk in _disks) {
        if ((disk.position.x-75) <= pos.x && pos.x <= (disk.position.x+75)) {
            if (disk.position.y >= h) {
                h = disk.position.y;
                _disk = disk;
            }
        }
    }
    
}

- (CGFloat)overDisks: (CGPoint) pos {
    // Calculate yAxis offset when dropping disk on pillar
    CGFloat multiple = _diskHeight/2;
    
    for (SKShapeNode* disk in _disks) {
        if (_disk != disk) {
            if ((disk.position.x-75) <= pos.x && pos.x <= (disk.position.x+75)) {
                multiple += _diskHeight;
            }
        }
    }
    
    return multiple;
}

- (BOOL) isLegalMove {
    for (SKShapeNode* disk in _disks) {
        if (_disk != disk) {
            if ((disk.position.x-75) <= _disk.position.x && _disk.position.x <= (disk.position.x+75)) {
                if (_disk.frame.size.width > disk.frame.size.width) {
                    return NO;
                }
            }
        }
    }

    return YES;
}

- (void)touchDownAtPoint:(CGPoint)pos {
    [self chooseDisk:pos];
    
    if ((_disk.position.x-75) <= pos.x && pos.x <= (_disk.position.x+75)) {
        old_pos = _disk.position;
    }
}

- (void)levelCompleted {
    /*
     Check if level has been completed.
     If level completed, move to next level.
     */
    
    SKShapeNode* lastPillar = [_pillars lastObject];
    BOOL completedLevel = YES;
    for (SKShapeNode* disk in _disks) {
        if (disk.position.x != lastPillar.position.x) {
            completedLevel = NO;
            break;
        }
    }
    
    if (completedLevel) {
        [self nextLevel];
    }

}

- (void)touchMovedToPoint:(CGPoint)pos {
    if ((_disk.position.x-75) <= pos.x && pos.x <= (_disk.position.x+75)) {
        _disk.position = pos;
    }
    
}

- (void)touchUpAtPoint:(CGPoint)pos {
    if ((_disk.position.x-75) <= pos.x && pos.x <= (_disk.position.x+75)) {
        CGFloat multiple = [self overDisks:pos];
        BOOL positionChanged = NO;
        
        for (SKShapeNode* pillar in _pillars) {
            if (pillar.position.x-75 <= pos.x && pos.x <= pillar.position.x+75) {
                if ([self isLegalMove]) {
                    CGPoint position = CGPointMake(pillar.position.x, multiple);
                    [_disk runAction:[SKAction moveTo:position duration:0.3] completion:^{
                        [self levelCompleted];
                    }];
                    positionChanged = YES;
                } else {
                    _disk.position = old_pos;
                }
            }
        }
        
        if (positionChanged == NO) {
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
        case 0x0F: /* R */
            // Needs to restart level!
            
            [self startLevel];
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
