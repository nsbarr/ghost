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
        
        //reset stuff
        _numberOfTilesInSlots = 0;
        _tilesAreSlidOver = FALSE;
        _currentWord = @"";
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        
        //starting array of letters
        NSArray *array = [NSArray arrayWithObjects:@"C",@"Y",@"F",@"E",@"K",@"S", @"U", @"!", nil];
        
        //generate the tiles with letters
        int i;
        for (i = 0; i < array.count; i++) {
            CGFloat position = i*40.0f+20;
            NSString *letterToPass = [array objectAtIndex:i];
            [self generateTileWithLetter:letterToPass withXPosition:position];

        }
    }
    return self;
}


- (void)generateTileWithLetter:(NSString*)string withXPosition:(CGFloat)point {
    
    //called by initWithSize
    SKSpriteNode *tile = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(40,40)];
    tile.position = CGPointMake(point,100);
    [tile setName:TileLetterName];
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter"];
    myLabel.text = string;
    myLabel.name = string;
    myLabel.fontSize = 30;
    myLabel.position = CGPointMake(0,-10);
    
    [tile addChild:myLabel];
    [self addChild: tile];

}




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    [self selectNodeForTouch:positionInScene];
}

- (void)selectNodeForTouch:(CGPoint)touchLocation {
    
    // not totally sure how this works. see http://www.raywenderlich.com/44270/sprite-kit-tutorial-how-to-drag-and-drop-sprites
    
    SKSpriteNode *touchedNode = nil;
    NSArray *nodes = [self nodesAtPoint:touchLocation];
    
    for (SKSpriteNode *node in nodes) {
        
        //only accept Tile nodes (ie., not immovable tiles)
        if ([node.name isEqualToString:TileLetterName]) {
        
            touchedNode = node;
        }
        
        // game over behavior, currently broken
        else if ([node.name isEqualToString:@"tryAgain"]){
            NSLog(@"refreshing scene");
        
            SKScene *spaceshipScene  = [[ghostMyScene alloc] initWithSize:self.size];
            [self.view presentScene:spaceshipScene];
        }
    }
   
    // provides the location to return the Tile to in case it's not dragged to the Board
    CGPoint snapBackLocation = touchedNode.position;
    _originalLocation = snapBackLocation;
    
    // disables the shiver action on previously touched node when a new node is touched
	if(![_selectedNode isEqual:touchedNode]) {
		[_selectedNode removeAllActions];
		[_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
        
		_selectedNode = touchedNode;
		
        // shivers the selected node
		if([[touchedNode name] isEqualToString:TileLetterName]) {
			SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degToRad(-14.0f) duration:0.1],
													  [SKAction rotateByAngle:0.0 duration:0.1],
													  [SKAction rotateByAngle:degToRad(14.0f) duration:0.1]]];
			[_selectedNode runAction:[SKAction repeatActionForever:sequence]];
		}
	}
    
}

// gets called by touchesMoved, moves the selected node
- (void)panForTranslation:(CGPoint)translation {
    CGPoint position = [_selectedNode position];
    if([[_selectedNode name] isEqualToString:TileLetterName]) {
        [_selectedNode setPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
    }
}


//this code gets called by touchesEnded, snaps the selected node into place on the Board

- (void)snapSelectedTileIntoPlace:(SKNode*)tile {
    
    //special behavior for first tile
    if (_numberOfTilesInSlots == 0) {
        [tile setPosition:CGPointMake(CGRectGetMidX(self.frame),
                                      450)];
    }
    
    else {
        _distanceBetweenTileAndSlot = 100; //arbitrary #, not sure if this is necessary
        
        //this block finds the closest tile to the tile that has just been let go of
        [self enumerateChildNodesWithName:@"immovable" usingBlock:^(SKNode *node, BOOL *stop) {
            int distanceBetween = abs(node.position.x - tile.position.x);
            if (distanceBetween < _distanceBetweenTileAndSlot) {
                _distanceBetweenTileAndSlot = distanceBetween;
                _nodeToSnapTo = node;
            }
        }];
        
        // snap it to the right or left of the closest tile, based on relative positioning
        if (_nodeToSnapTo.position.x > tile.position.x){
            [tile setPosition:CGPointMake(_nodeToSnapTo.position.x-40,_nodeToSnapTo.position.y)];
        }
        else{
            [tile setPosition:CGPointMake(_nodeToSnapTo.position.x+40,_nodeToSnapTo.position.y)];
            }
    }
    
    // set the tile name to "immovable" so it gets handled properly going forward
    [tile setName:@"immovable"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
    // don't totally get this, see wenderlich url in panForTranslation
    UITouch *touch = [touches anyObject];
	CGPoint positionInScene = [touch locationInNode:self];
	CGPoint previousPosition = [touch previousLocationInNode:self];
	CGPoint translation = CGPointMake(positionInScene.x - previousPosition.x, positionInScene.y - previousPosition.y);
	[self panForTranslation:translation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // stop shivering, and straighten the node once it's not being dragged
    [_selectedNode removeAllActions];
    [_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
    
    SKAction *snapBack = [SKAction moveTo:_originalLocation duration:.2];
    
    
    // if the node is an active Tile and is high enough, then snap it into place on the Board
    if([[_selectedNode name] isEqualToString:TileLetterName] && (_selectedNode.position.y > 400)) {
      
        [self snapSelectedTileIntoPlace:_selectedNode];
        
        _numberOfTilesInSlots = _numberOfTilesInSlots+1; // increment tiles on Board count
        
        _selectedNode = nil; // unselect node
        
        [self spellOutWord]; // find out what the new word is
        
    }

    else {
        
        [_selectedNode runAction: snapBack];
    }
}


//gets called by touchesEnded to find out the new word

-(void)spellOutWord{
    
    _currentWord = @""; //wipe the previous word

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
    
    NSLog(@"current word: %@", _currentWord);
    [self isGameOver];

}

// not sure when/why this would get called but snaps back the selected tile

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch cancelled");
    [_selectedNode removeAllActions];
    [_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
    SKAction *snapBack = [SKAction moveTo:_originalLocation duration:.2];
    [_selectedNode runAction: snapBack];
}







-(void)update:(CFTimeInterval)currentTime {
    
    
    
    if(_selectedNode.position.y > 400 && ![_selectedNode.name isEqualToString:@"immovable"]) {
        
        _tilesAreSlidOver = TRUE;
        
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
                //do nothing
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
    
    //behavior to return tiles to previous location on Board if the selected tile leaves the Board area
    else if (_tilesAreSlidOver && _selectedNode.position.y < 400) {
        
        //make an array of all immovable tiles
        NSMutableArray *fixedTiles = [[NSMutableArray alloc] init];
        [self enumerateChildNodesWithName:@"immovable" usingBlock:^(SKNode *node, BOOL *stop) {
            [fixedTiles addObject:node];
        }];
        
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
        CGFloat anchorPosition = (self.view.frame.size.width/2)-(_numberOfTilesInSlots-1)*20;
        for (SKNode *node in sortedArray){
            
                int displacement = [sortedArray indexOfObject:node]*40;
                CGFloat newXPosition = anchorPosition + displacement;
                NSLog(@"%f",newXPosition);
                [node setPosition:CGPointMake(newXPosition, node.position.y)];
        }
    }
}

-(void)isGameOver{
    if ([_currentWord isEqualToString:@"FUCKYES!"]){
        for (SKSpriteNode *tiles in [self children]) {
            if ([tiles.name isEqualToString:@"immovable"]){
                [tiles setColor:[SKColor greenColor]];
            }
        }
    }
    else if (_numberOfTilesInSlots == 8){
        [self tryAgainButton];
    }
    
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
