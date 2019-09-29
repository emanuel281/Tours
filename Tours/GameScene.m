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
    
    SKLabelNode *_title; //Game title
    SKLabelNode *scorecardLabel; //Level: 1/10
    
    NSMutableArray<SKShapeNode*> *_pillars; // All pillars
    NSMutableArray<SKShapeNode*> *_disks; //All disks
    NSMutableArray<NSMutableDictionary*> *_moves; //Moves made by player
    
    SKShapeNode *_disk; //Selected disk to be moved
    
    NSInteger _numOfDisks; //Current number of disks
    NSUInteger _maxNumOfDisks; //Maximum number of disks
    NSUInteger _minNumOfDisks; //Minimum number of disks
    
    CGPoint _oldPos; //Previous position of the selected disk
    CGFloat _yDefaultPos; //Highest position of the disk
    CGFloat _diskHeight;
    CGFloat _diskBaseWidth;
}

- (void)sceneDidLoad {
    // Setup your scene here
    
    // Initialize update time
    _lastUpdateTime = 0;

    _minNumOfDisks = 3;
    _maxNumOfDisks = 12;
    _numOfDisks = _minNumOfDisks;

    _diskHeight = self.size.height*0.02;
    _diskBaseWidth = 50.0;
    _yDefaultPos = _diskHeight*(_numOfDisks-0.5);
    
    _moves = [NSMutableArray new];
    _disks = [NSMutableArray new];
    
    [self createPillars];
    
    _title = (SKLabelNode*)[self childNodeWithName:@"//title"];
    SKShapeNode* pillar = [_pillars objectAtIndex:_pillars.count/2];
    _title.position = CGPointMake(pillar.position.x, self.size.height/1.8);
    
    SKLabelNode* menu = [SKLabelNode new];
    menu.text = @"MENU\n=============\nR * restart level\n<- * to previous level\n-> * to next level\nF * refresh scoreboard\nQ * quit";
    menu.numberOfLines = 4;
    menu.fontSize = 18;
    menu.fontName = _title.fontName;
    menu.fontColor = [NSColor blackColor];
    menu.position = CGPointMake(self.position.x, _title.position.y*0.55);
    [self addChild:menu];
    
    scorecardLabel = [SKLabelNode new];
    scorecardLabel.fontName = _title.fontName;
    scorecardLabel.fontSize = 18;
    scorecardLabel.fontColor = [NSColor systemPinkColor];
    scorecardLabel.numberOfLines = 2;

    pillar = [_pillars lastObject];
    scorecardLabel.position = CGPointMake(pillar.position.x, menu.position.y+80);
    [self addChild:scorecardLabel];
    
    [self resumeGame];
    [self initScoreboard];

}

- (void) initScoreboard {
    NSMutableDictionary<NSString*, NSNumber*> *moves;
    
    if (_moves.count < _maxNumOfDisks-(_minNumOfDisks-1)) {
        moves = [NSMutableDictionary new];
        [moves setObject:[NSNumber numberWithInt:0] forKey:@"curr"];
        [moves setObject:[NSNumber numberWithInteger:9999] forKey:@"prev"];
        for (NSInteger i = _moves.count; i < _numOfDisks-(_minNumOfDisks-1); i++) {
            [_moves addObject:moves];
        }
    }
    
    moves = [_moves objectAtIndex:_numOfDisks-_minNumOfDisks];
    
    
    NSUInteger best_sol = powl(2, _numOfDisks) - 1;
    scorecardLabel.text = [NSString stringWithFormat:@"Level: %ld/%ld  disks: %ld\nMoves: %@ curr -  %@ prev\nBest Sol.: %ld",
                   _numOfDisks-(_minNumOfDisks-1), _maxNumOfDisks-(_minNumOfDisks-1), _numOfDisks, moves[@"curr"], moves[@"prev"], best_sol];
}

- (void)updateScoreboard {
    NSMutableDictionary<NSString*, NSNumber*> *moves = [_moves objectAtIndex:_numOfDisks-_minNumOfDisks];
    moves[@"curr"] = [NSNumber numberWithInt:moves[@"curr"].intValue+1];
    [self initScoreboard];
}

- (void)zeroOutCurrMoves {
    NSMutableDictionary* moves = [_moves objectAtIndex:_numOfDisks-_minNumOfDisks];
    moves[@"curr"] = [NSNumber numberWithInt:0];
}

- (void) resetScoreboard {
    NSMutableDictionary<NSString*, NSNumber*> *moves = [NSMutableDictionary new];
    
    for (NSInteger i = 0; i < _moves.count; i++) {
        moves = [_moves objectAtIndex:i];
        [moves setObject:[NSNumber numberWithInt:0] forKey:@"curr"];
        [moves setObject:[NSNumber numberWithInteger:9999] forKey:@"prev"];
    }
    [self restartLevel]
    ;}


- (void) createPillars {
    //Pillars
    NSInteger xVal = 150.0 + _numOfDisks * _diskBaseWidth;
    _pillars = [NSMutableArray new];
    CGFloat w = self.size.width*0.01;
    CGFloat h = self.size.height*0.25;

    for (NSInteger i = 0; i < 3; i++) {
        SKShapeNode* pillar = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, h) cornerRadius:w * 0.3];
        pillar.lineWidth = 2.5;
        pillar.fillColor = [SKColor redColor];
        pillar.name = @"pillar";
        pillar.position = CGPointMake(xVal*i, h/2);
        pillar.alpha = 0.65;
        
        [_pillars insertObject:pillar atIndex:i];
        [self addChild:pillar];
    }
}

- (void) updateDiskInfo: (NSInteger) indx {
    
    CGFloat width = _diskBaseWidth;
    if (_disks.count) {
        SKShapeNode* last = [_disks lastObject];
        width = last.frame.size.width + 20.0;
    }
    SKShapeNode* d = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(width, _diskHeight) cornerRadius:0.3];
    
    d.lineWidth = 0.5;
    d.name = @"diskN";
    d.position = CGPointMake(0, _yDefaultPos-_diskHeight*indx);
    d.userData[@"size"] = [NSNumber numberWithInteger:1+indx];
    d.fillColor = [NSColor colorWithRed:-0.01*indx green:0.1*indx blue:0.1*indx alpha:0.7];
    [_disks insertObject:d atIndex:indx];
    [self addChild:d];
}

- (BOOL) isPointOnElement: (SKShapeNode*) disk : (CGPoint) pos {
    
    CGFloat halfWidth = disk.frame.size.width/2 >= 75 ? disk.frame.size.width/2 : 75;
    CGFloat diskStart = disk.position.x-halfWidth;
    CGFloat diskEnd = disk.position.x+halfWidth;
    
    if (diskStart <= pos.x && pos.x <= diskEnd) {
        return YES;
    }
    
    return NO;
}

- (void) startLevel {
    NSInteger i = 0;
    _yDefaultPos = _diskHeight*(_numOfDisks-0.5);
    
    [self saveProgress];

    for (SKShapeNode* disk in _disks) {
        CGPoint position = CGPointMake(0, _yDefaultPos-_diskHeight*i);
        [disk runAction:[SKAction moveTo:position duration:0.8]];
        i++;
    }
    
    while (i < _numOfDisks) {
        [self updateDiskInfo:i];
        i++;
    }
    
    [self initScoreboard];
}

- (void)restartLevel {
    [self zeroOutCurrMoves];
    [self startLevel];
}

- (void) nextLevel {
    _numOfDisks = _numOfDisks < _maxNumOfDisks ? _numOfDisks+1 : _numOfDisks;
    [self startLevel];
}

- (void) prevLevel {
    if (_disks.count > _minNumOfDisks) {
        _numOfDisks = _numOfDisks > 1 ? _numOfDisks-1 : _numOfDisks;
        _yDefaultPos = _diskHeight*(_numOfDisks - 0.5);
        
        SKShapeNode* disk = [_disks lastObject];
        [self removeChildrenInArray:@[disk]];
        [_disks removeLastObject];
    }
    
    [self startLevel];
    
    [self zeroOutCurrMoves];
    [self initScoreboard];
}

- (void) saveProgress {
    if (_moves.count) {
        [self zeroOutCurrMoves];
        [_moves writeToFile:@"scoreboard.xml" atomically: YES];
    }
}

- (void) resumeGame {
    NSMutableArray<NSMutableDictionary*>* movesData = [NSMutableArray new];
    movesData = [movesData initWithContentsOfFile:@"scoreboard.xml"];
    if (movesData != nil) {
        _moves = movesData;
    }
    
    [self startLevel];
}

- (void)chooseDisk: (CGPoint)pos {
    float h = 0;

    for (SKShapeNode* disk in _disks) {
        if ([self isPointOnElement:disk :pos]) {
            if (disk.position.y >= h) {
                h = disk.position.y;
                _disk = disk;
            }
        }
    }
    
}

- (CGFloat)diskHeightLevel: (CGPoint) pos {
    // Calculate yAxis offset when dropping disk on pillar
    CGFloat multiple = _diskHeight/2;
    
    for (SKShapeNode* disk in _disks) {
        if (_disk != disk) {
            if ([self isPointOnElement:disk :pos]) {
                multiple += _diskHeight;
            }
        }
    }
    return multiple;
}

- (BOOL) moveIsLegal {
    for (SKShapeNode* disk in _disks) {
        if (_disk != disk) {
            if ([self isPointOnElement:disk :_disk.position]) {
                if (_disk.frame.size.width > disk.frame.size.width) {
                    return NO;
                }
            }
        }
    }
    if (![self isPointOnElement:_disk :_oldPos]) {
        [self updateScoreboard];
    }

    return YES;
}

- (void)levelCompleted {
    /*
     Check if level has been completed.
     If level completed, move to next level.
     */
    
    BOOL completedLevel = YES;
    SKShapeNode* lastPillar = [_pillars lastObject];

    for (SKShapeNode* disk in _disks) {
        if (disk.position.x != lastPillar.position.x) {
            completedLevel = NO;
            break;
        }
    }
    
    if (completedLevel) {
        NSMutableDictionary* moves = [_moves objectAtIndex:_numOfDisks-_minNumOfDisks];
        if (moves[@"curr"] < moves[@"prev"]) {
            moves[@"prev"] = moves[@"curr"];
            moves[@"curr"] = [NSNumber numberWithInt:0];
        }
        
        [self initScoreboard];
        
        SKLabelNode* winner = [SKLabelNode new];
        winner.text = _numOfDisks == _maxNumOfDisks ? @"Congratulations! You did!" : @"Nice Job!";
        winner.fontSize = 40;
        winner.fontName = _title.fontName;
        winner.fontColor = [NSColor systemBlueColor];
        
        [self nextLevel];
        
        SKShapeNode* pillar = [_pillars objectAtIndex:_pillars.count/2];
        winner.position = CGPointMake(pillar.position.x, _title.position.y*-0.2);
        [winner runAction:[SKAction fadeOutWithDuration:8]];
        [self addChild:winner];
        
    }

}

- (void)touchDownAtPoint:(CGPoint)pos {

    [self chooseDisk:pos];
    
    for (SKShapeNode* pillar in _pillars) {
        if ([self isPointOnElement:pillar :pos]) {
            _oldPos = CGPointMake(pillar.position.x, [self diskHeightLevel:pillar.position]);
            [_disk runAction:[SKAction moveTo:pos duration:0.01]];
        }
    }
}

- (void)touchMovedToPoint:(CGPoint)pos {
    if ((_disk.position.x-75) <= pos.x && pos.x <= (_disk.position.x+75)) {
        _disk.position = pos;
    }
    
}

- (void)touchUpAtPoint:(CGPoint)pos {
    if ((_disk.position.x-75) <= pos.x && pos.x <= (_disk.position.x+75)) {
        CGFloat multiple = [self diskHeightLevel:pos];
        BOOL positionChanged = NO;
        
        for (SKShapeNode* pillar in _pillars) {
            if (pillar.position.x-75 <= pos.x && pos.x <= pillar.position.x+75) {
                if ([self moveIsLegal]) {
                    CGPoint position = CGPointMake(pillar.position.x, multiple);
                    [_disk runAction:[SKAction moveTo:position duration:0.3] completion:^{
                        [self levelCompleted];
                    }];
                    positionChanged = YES;
                } else {
                    [_disk runAction:[SKAction moveTo:_oldPos duration:0.3]];
                }
            }
        }
        
        if (positionChanged == NO) {
            [_disk runAction:[SKAction moveTo:_oldPos duration:0.3]];
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
            [self saveProgress];
            exit(0);
            break;
        case 0x03: /* F */
            [self resetScoreboard];
            [self saveProgress];
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
