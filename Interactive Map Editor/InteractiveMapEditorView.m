//
//  InteractiveMapEditorView.m
//  Interactive Map Editor
//
//  Created by Dmitry Davidov on 21.01.13.
//  Copyright (c) 2013 Dmitry Davidov. All rights reserved.
//

#import "InteractiveMapEditorView.h"

@implementation InteractiveMapEditorView
{
    NSMutableArray *graphPoints;
    NSMutableArray *controlPoints;

    NSInteger draggedControlPointIndex;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPoints];
        draggedControlPointIndex = -1;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *graphPath = [[NSBezierPath alloc] init];
    [graphPath moveToPoint:[(NSValue *)[graphPoints objectAtIndex:0] pointValue]];
    for (NSUInteger i = 0; i < [graphPoints count] - 1; ++i) {
        [graphPath curveToPoint:[(NSValue *)[graphPoints objectAtIndex:i + 1] pointValue]
            controlPoint1:[(NSValue *)[controlPoints objectAtIndex:2 * i] pointValue]
            controlPoint2:[(NSValue *)[controlPoints objectAtIndex:2 * i + 1] pointValue]];
    }
    [[NSColor blueColor] set];
    [graphPath setLineWidth:3.0f];
    [graphPath stroke];

    NSBezierPath *controlPath = [[NSBezierPath alloc] init];
    for (NSUInteger i = 0; i < [controlPoints count]; ++i) {
        [controlPath moveToPoint:[(NSValue *)[graphPoints objectAtIndex:(i / 2 + i % 2)] pointValue]];
        [controlPath lineToPoint:[(NSValue *)[controlPoints objectAtIndex:i] pointValue]];
    }
    [[NSColor redColor] set];
    [controlPath setLineWidth:1.0f];
    CGFloat dashes[] = { 4.0f, 4.0f };
    [controlPath setLineDash:dashes count:2 phase:0.0f];
    [controlPath stroke];
}

- (void)initPoints
{
    graphPoints = [NSMutableArray arrayWithObjects:[NSValue valueWithPoint:NSMakePoint(10, 100)],
              [NSValue valueWithPoint:NSMakePoint(400, 100)], nil];
    controlPoints = [NSMutableArray arrayWithObjects:[NSValue valueWithPoint:NSMakePoint(20, 20)],
                     [NSValue valueWithPoint:NSMakePoint(35, 25)], nil];
}

#pragma mark - Mouse events

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint downPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    draggedControlPointIndex = [InteractiveMapEditorView findPointInArray:controlPoints nearPoint:downPoint inRadius:5];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (draggedControlPointIndex != -1) {
        NSPoint currentPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        [controlPoints setObject:[NSValue valueWithPoint:currentPoint] atIndexedSubscript:draggedControlPointIndex];
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    draggedControlPointIndex = -1;
}

#pragma mark - Utilities

+ (NSInteger)findPointInArray:(NSArray *)points nearPoint:(NSPoint)point inRadius:(CGFloat)radius
{
    for (NSUInteger i = 0; i < [points count]; ++i) {
        NSPoint p = [(NSValue *)[points objectAtIndex:i] pointValue];
        CGFloat r = sqrt(pow(p.x - point.x, 2) + pow(p.y - point.y, 2));
        if (r <= radius) {
            return i;
        }
    }
    return -1;
}

@end
