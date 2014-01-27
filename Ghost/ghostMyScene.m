//
//  ghostMyScene.m
//  Ghost
//
//  Created by Nicholas Barr on 1/21/14.
//  Copyright (c) 2014 Nicholas Barr. All rights reserved.
//

#import "ghostMyScene.h"
#import "ghostViewController.h"

static NSString * const TileLetterName = @"movable";

@interface ghostMyScene ()

@property (nonatomic, strong) SKSpriteNode *selectedNode;
@property (nonatomic, strong) SKNode *nodeToSnapTo;
@property (nonatomic) BOOL tilesAreSlidOver;
@property (nonatomic) int numberOfTilesInSlots;
@property (nonatomic) CGPoint originalLocation;
@property (nonatomic) CGFloat centerLocation;
@property (nonatomic) int distanceBetweenTileAndSlot;
@property (nonatomic, strong) NSString* currentWord;
@property (nonatomic, strong) NSString* letterToAppend;



@end

@implementation ghostMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        _numberOfTilesInSlots = 0;
        _tilesAreSlidOver = FALSE;
        _currentWord = @"this:";
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        
  //      NSMutableArray *possibleLetters = [[NSMutableArray alloc]init];
        
        NSArray *array = [NSArray arrayWithObjects:@"N",@"O",@"V",@"E",@"L",@"I", @"S", @"M", nil];
        
        int i;
        for (i = 0; i < array.count; i++) {
            CGFloat position = i*40.0f+20;
            NSString *letterToPass = [array objectAtIndex:i];
            [self generateTileWithLetter:letterToPass withXPosition:position];
            [self generateEvenSlotWithXPosition:position];
            [self generateOddSlotWithXPosition:position];
        }

        


        



    }
    return self;
}

- (void)generateEvenSlotWithXPosition:(CGFloat)point {
    
UIBezierPath *path =
[UIBezierPath bezierPathWithRect:
CGRectMake(-30.0f, -20.0f, 40.0f, 40.0f)]; // 2￼
SKShapeNode *shapeNode = [SKShapeNode node];
shapeNode.name = @"EvenSlot";
shapeNode.path = path.CGPath;
shapeNode.strokeColor = [SKColor colorWithRed:0.65 green:0.15 blue:0.15 alpha:1.0];
shapeNode.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(40,40)];
shapeNode.physicsBody.dynamic = NO;
shapeNode.lineWidth = 1;
shapeNode.position = CGPointMake(point,
                            450);
    [self addChild:shapeNode];
    shapeNode.zPosition = -10;
}

- (void)generateOddSlotWithXPosition:(CGFloat)point {
    
    UIBezierPath *path =
    [UIBezierPath bezierPathWithRect:
     CGRectMake(-30.0f, -20.0f, 40.0f, 40.0f)]; // 2￼
    SKShapeNode *shapeNode = [SKShapeNode node];
    shapeNode.name = @"OddSlot";
    shapeNode.path = path.CGPath;
    shapeNode.strokeColor = [SKColor colorWithRed:0.15 green:0.65 blue:0.15 alpha:1.0];
    shapeNode.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(40,40)];
    shapeNode.physicsBody.dynamic = NO;
    shapeNode.lineWidth = 1;
    shapeNode.position = CGPointMake(point+20,
                                     450);
    [self addChild:shapeNode];
    shapeNode.zPosition = -10;
}



- (void)generateTileWithLetter:(NSString*)string withXPosition:(CGFloat)point {
    

    SKSpriteNode *tile = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(40,40)];
    tile.position = CGPointMake(point,
                                100);
   // tile.anchorPoint = CGPointMake(0,0);
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter"];
    
    myLabel.text = string;
    myLabel.name = string;
    myLabel.fontSize = 30;
    myLabel.position = CGPointMake(0,-10);
    [tile setName:TileLetterName];
    [tile addChild:myLabel];
    [self addChild: tile];

}





-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    
    CGPoint positionInScene = [touch locationInNode:self];
    [self selectNodeForTouch:positionInScene];
}

- (void)selectNodeForTouch:(CGPoint)touchLocation {
    
    SKSpriteNode *touchedNode = nil;
    NSArray *nodes = [self nodesAtPoint:touchLocation];
    
    for (SKSpriteNode *node in nodes) {
    if ([node.name isEqualToString:TileLetterName]) {
        touchedNode = node;
    }
    else if ([node.name isEqualToString:@"tryAgain"]){
        SKScene *spaceshipScene  = [[ghostMyScene alloc] initWithSize:self.size];
        SKView * skView = (SKView *)_ghostViewController.view;
        [skView presentScene:spaceshipScene];
    }
    }
    //1
   // SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    CGPoint snapBackLocation = touchedNode.position;
    _originalLocation = snapBackLocation;
    
    //2
	if(![_selectedNode isEqual:touchedNode]) {
		[_selectedNode removeAllActions];
		[_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
        
		_selectedNode = touchedNode;
		//3
		if([[touchedNode name] isEqualToString:TileLetterName]) {
			SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degToRad(-14.0f) duration:0.1],
													  [SKAction rotateByAngle:0.0 duration:0.1],
													  [SKAction rotateByAngle:degToRad(14.0f) duration:0.1]]];
			[_selectedNode runAction:[SKAction repeatActionForever:sequence]];
		}
	}
    
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint position = [_selectedNode position];
    if([[_selectedNode name] isEqualToString:TileLetterName]) {
        [_selectedNode setPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
    }
    else {
           }
    
        }
        


- (void)slideTilesOutOfTheWay:(SKNode*)node withXOffset:(CGFloat)point {
    SKAction *moveRight = [SKAction sequence:@[
                                               [SKAction waitForDuration:0],
                                               [SKAction moveByX:point y:0 duration:.1]]];
    [node runAction:moveRight];
}

- (void)snapSelectedTileIntoPlace:(SKNode*)tile {
    
    if (_numberOfTilesInSlots == 0) {
        [tile setPosition:CGPointMake(CGRectGetMidX(self.frame),
                                      450)];
    }
    else {
    _distanceBetweenTileAndSlot = 100;
    [self enumerateChildNodesWithName:@"immovable" usingBlock:^(SKNode *node, BOOL *stop) {
        int distanceBetween = abs(node.position.x - tile.position.x);
        if (distanceBetween < _distanceBetweenTileAndSlot) {
            _distanceBetweenTileAndSlot = distanceBetween;
            _nodeToSnapTo = node;
        }
    }];
        if (_nodeToSnapTo.position.x > tile.position.x){
    [tile setPosition:CGPointMake(_nodeToSnapTo.position.x-40,_nodeToSnapTo.position.y)];
        }
            else{
                [tile setPosition:CGPointMake(_nodeToSnapTo.position.x+40,_nodeToSnapTo.position.y)];
            }
    }
    [tile setName:@"immovable"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint positionInScene = [touch locationInNode:self];
	CGPoint previousPosition = [touch previousLocationInNode:self];
    
	CGPoint translation = CGPointMake(positionInScene.x - previousPosition.x, positionInScene.y - previousPosition.y);
    
	[self panForTranslation:translation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
     NSLog(@"touch ended");
    [_selectedNode removeAllActions];
    [_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
    SKAction *snapBack = [SKAction moveTo:_originalLocation duration:.2];
    if([[_selectedNode name] isEqualToString:TileLetterName]) {
    if (_selectedNode.position.y > 400){
       // [_selectedNode setPosition:CGPointMake(_selectedNode.position.x, 450)];
        [self snapSelectedTileIntoPlace:_selectedNode];
        _numberOfTilesInSlots = _numberOfTilesInSlots+1;
        
        for (int i = 1; i <= 320; i++) {
            
        }
        
        
        
        NSLog(@"Number of tiles in slots is %d",_numberOfTilesInSlots);
        _tilesAreSlidOver = FALSE;
         NSLog(@"sliding tiles back...");
        _selectedNode = nil;
        _currentWord = @"";
        
        //crawl from left to right (x=0 to x=320)
        //for each x if node.position.x == x then
        //enumerate children (SKLabelNode)
        //get the text of that child
        //append the text to the currentWord string
        
        NSMutableArray *fixedTiles = [[NSMutableArray alloc] init];
        [self enumerateChildNodesWithName:@"immovable" usingBlock:^(SKNode *node, BOOL *stop) {
                [fixedTiles addObject:node];
                  }];
            
        NSArray *sortedArray = [fixedTiles sortedArrayUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
            SKNode *node1 = (SKNode *)obj1;
            SKNode *node2 = (SKNode *)obj2;
            
            NSNumber *node1pos = @(node1.position.x);
            NSNumber *node2pos = @(node2.position.x);
            
            return [node1pos compare:node2pos];
        
        }];
        
        for (SKNode *node in sortedArray){
            NSArray *letterNodes = node.children;
            for (SKLabelNode *letterNode in letterNodes) {
                _letterToAppend = letterNode.name;
                _currentWord = [_currentWord stringByAppendingString:_letterToAppend];
            }
            
        }
        
        //                for (SKLabelNode *letterNode in letterNodes) {
        //                    _letterToAppend = letterNode.name;
        //                    NSLog(@"the current word is %@", _currentWord);
        //                      _currentWord = [_currentWord stringByAppendingString:_letterToAppend];
        
        NSLog(@"array: %@", sortedArray);
        NSLog(@"current word: %@", _currentWord);
        
       
        
    }

    else{
    [_selectedNode runAction: snapBack];
        
            }
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch canceled");
    [_selectedNode removeAllActions];
    [_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
    SKAction *snapBack = [SKAction moveTo:_originalLocation duration:.2];
    [_selectedNode runAction: snapBack];
}


    //
   // _didMove = FALSE;
    





-(void)update:(CFTimeInterval)currentTime {
    
    
    if(_selectedNode.position.y > 400 && ![_selectedNode.name isEqualToString:@"immovable"]) {
       // NSLog(@"is this on?");
        
        //make an array of all immovable tiles
        NSMutableArray *fixedTiles = [[NSMutableArray alloc] init];
        [self enumerateChildNodesWithName:@"immovable" usingBlock:^(SKNode *node, BOOL *stop) {
            [fixedTiles addObject:node];
        }];
        
        //add selected node to array
        [fixedTiles addObject:_selectedNode];
        
        //sort the array by position.x
        NSArray *sortedArray = [fixedTiles sortedArrayUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
            SKNode *node1 = (SKNode *)obj1;
            SKNode *node2 = (SKNode *)obj2;
            
            NSNumber *node1pos = @(node1.position.x);
            NSNumber *node2pos = @(node2.position.x);
            
            return [node1pos compare:node2pos];
            
        }];
        
        //set position.x of tiles in the sorted array, without setting the position of the selected node:
        NSLog(@"setting position");
        CGFloat anchorPosition = (self.view.frame.size.width/2)-_numberOfTilesInSlots*20;
        for (SKNode *node in sortedArray){
            if (node == _selectedNode){
            }
            else {
                // NSUInteger i = [sortedArray indexOfObject:node];
                int displacement = [sortedArray indexOfObject:node]*40;
                CGFloat newXPosition = anchorPosition + displacement;
                NSLog(@"%f",newXPosition);
                [node setPosition:CGPointMake(newXPosition, node.position.y)];
            }
        }
        
    }
    
    
    
    /* Called before each frame is rendered */
//    if (_tilesAreSlidOver == FALSE && _selectedNode.position.y > 400 && ![_selectedNode.name isEqualToString:@"immovable"]){
//            _tilesAreSlidOver = TRUE;
//        NSLog(@"sliding tiles over...");
//            [self enumerateChildNodesWithName:@"immovable" usingBlock:^(SKNode *node, BOOL *stop) {
//                if (node.position.x < _selectedNode.position.x) {
//                    [self slideTilesOutOfTheWay:node withXOffset:-20];
//                }
//                else if (node.position.x > _selectedNode.position.x) {
//                    [self slideTilesOutOfTheWay:node withXOffset:20];
//                }
//            }];
//        }
//        else if (_selectedNode.position.y <= 400 && _tilesAreSlidOver == TRUE && ![_selectedNode.name isEqualToString:@"immovable"]) {
//            NSLog(@"sliding tiles back...");
//            _tilesAreSlidOver = FALSE;
//            [self enumerateChildNodesWithName:@"immovable" usingBlock:^(SKNode *node, BOOL *stop) {
//                if (node.position.x < _selectedNode.position.x) {
//                    [self slideTilesOutOfTheWay:node withXOffset:20];
//                }
//                else if (node.position.x > _selectedNode.position.x) {
//                    [self slideTilesOutOfTheWay:node withXOffset:-20];
//                }
//                
//            }];
//
//        }
    if ([_currentWord isEqualToString:@"LOVEMINS"]){
        for (SKSpriteNode *tiles in [self children]) {
            if ([tiles.name isEqualToString:@"immovable"]){
            [tiles setColor:[SKColor greenColor]];
        }
    }
    }
    else if (_numberOfTilesInSlots == 8){
        [self tryAgainButton];
    }
    
    // if the selected node is in the tile region and not yet immovable:
    // add the node to the sorted array of fixed tiles, so that its place corresponds to its current x position
    // for all tiles in the sorted array of fixed tiles:
    // if it's the selected node, do nothing.
    // else, set the node's x position based on the number of tiles in the array + 1
        // 1 tile: x position of array[0]= midpoint
        // 2 tiles: x position of array [0] = midpoint -20
        // 3 tiles: x position of array [0] = -40
        // ...
        // 8 tiles: x position of array[0] = (8-1)*-20 = -140
    
  
    
    
}

-(void)tryAgainButton{
    [self removeAllChildren];
    SKSpriteNode *sup = [[SKSpriteNode alloc] init];
    SKLabelNode *hi = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    hi.fontSize = 20;
    hi.name = @"tryAgain";
    hi.text= @"Try Again";
    hi.position = CGPointMake((self.frame.size.width/2),
                                     self.frame.size.height/2);
    [sup addChild:hi];
    [self addChild: sup];
}


- (void)createSceneContents
{
   
}

float degToRad(float degree) {
	return degree / 180.0f * M_PI;
}


@end
