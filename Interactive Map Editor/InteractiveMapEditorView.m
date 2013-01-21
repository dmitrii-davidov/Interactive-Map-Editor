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
        NSArray *cubicControlPoints = [InteractiveMapEditorView getCubicControlPointsToPoint:[(NSValue *)[graphPoints objectAtIndex:i] pointValue]
                                                                                controlPoint:[(NSValue *)[controlPoints objectAtIndex:i] pointValue]
                                                                                       point:[(NSValue *)[graphPoints objectAtIndex:i + 1] pointValue]];

        [graphPath curveToPoint:[(NSValue *)[graphPoints objectAtIndex:i + 1] pointValue]
            controlPoint1:[(NSValue *)[cubicControlPoints objectAtIndex:0] pointValue]
            controlPoint2:[(NSValue *)[cubicControlPoints objectAtIndex:1] pointValue]];
    }
    [[NSColor blueColor] set];
    [graphPath setLineWidth:3.0f];
    [graphPath stroke];

    NSBezierPath *controlPath = [[NSBezierPath alloc] init];
    for (NSUInteger i = 0; i < [controlPoints count]; ++i) {
        [controlPath moveToPoint:[(NSValue *)[graphPoints objectAtIndex:i] pointValue]];
        [controlPath lineToPoint:[(NSValue *)[controlPoints objectAtIndex:i] pointValue]];
        [controlPath lineToPoint:[(NSValue *)[graphPoints objectAtIndex:i + 1] pointValue]];
    }
    [[NSColor redColor] set];
    [controlPath setLineWidth:1.0f];
    CGFloat dashes[] = { 4.0f, 4.0f };
    [controlPath setLineDash:dashes count:2 phase:0.0f];
    [controlPath stroke];
}

- (void)initPoints
{
    graphPoints = [NSMutableArray arrayWithObjects:
                   [NSValue valueWithPoint:NSMakePoint(100, 100)],
                   [NSValue valueWithPoint:NSMakePoint(200, 120)],
                   [NSValue valueWithPoint:NSMakePoint(300, 150)],
//                   [NSValue valueWithPoint:NSMakePoint(400, 100)],
                   [NSValue valueWithPoint:NSMakePoint(500, 80)], nil];
    controlPoints = [NSMutableArray arrayWithObjects:[NSValue valueWithPoint:NSMakePoint(20, 20)], nil];
    [self recalculateControlPoints];
}

- (void)recalculateControlPoints
{
    for (NSUInteger i = 1; i < [graphPoints count] - 1; ++i) {
        CGPoint p = [(NSValue *)[graphPoints objectAtIndex:i] pointValue];
        CGPoint cp = [(NSValue *)[controlPoints objectAtIndex:i - 1] pointValue];
        [controlPoints setObject:[NSValue valueWithPoint:NSMakePoint(2 * p.x - cp.x, 2 * p.y - cp.y)] atIndexedSubscript:i];
    }
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
        if (draggedControlPointIndex == 0) {
            [self recalculateControlPoints];
        }
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

+(NSArray *)getCubicControlPointsToPoint:(NSPoint)p0 controlPoint:(NSPoint)p1 point:(NSPoint)p2
{
    CGFloat x1 = p0.x + 2 * (p1.x - p0.x) / 3;
    CGFloat y1 = p0.y + 2 * (p1.y - p0.y) / 3;
    CGFloat x2 = p1.x + (p2.x - p1.x) / 3;
    CGFloat y2 = p1.y + (p2.y - p1.y) / 3;
    return [NSArray arrayWithObjects:[NSValue valueWithPoint:NSMakePoint(x1, y1)], [NSValue valueWithPoint:NSMakePoint(x2, y2)], nil];
}

@end
