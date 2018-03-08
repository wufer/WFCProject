//
//  UIView+WFDraggable.m
//  
//
//  Created by wufer on 2018/3/7.
//

#import "UIView+WFDraggable.h"

#import <objc/runtime.h>



@interface UIView ()

@property (nonatomic,strong) UIView *WF_playground;

@property (nonatomic,strong) UIDynamicAnimator *WF_animator;

@property (nonatomic,strong) UISnapBehavior *WF_snapBehavior;

@property (nonatomic,strong) UIAttachmentBehavior *WF_attachmentBehavior;

@property (nonatomic,strong) UIPanGestureRecognizer *WF_recognizer;

@property (nonatomic,assign) CGPoint WF_centerPoint;

@property (nonatomic,assign) CGFloat WF_damping;

@end

@implementation UIView (WFDraggable)

#define WF_DARAGGABLE_DAMPING 0.8

-(void)WF_makeDraggable{
    if (!self.superview) {
        NSLog(@"WF_Draggable:   superView is nil！return.");
    }
    [self WF_makeDraggableOnPlayground:self.superview damping:WF_DARAGGABLE_DAMPING];
}

-(void)WF_makeDraggableOnPlayground:(nonnull UIView *)Playground damping:(CGFloat)damping{
    if (!Playground) {
        NSLog(@"WF_Draggable:   Playground is nil！return.");
    }
    [self WF_removeDraggable];
    
    self.WF_damping = damping;
    self.WF_playground = Playground;
    
    [self createAnimator];
    [self addPanGesture];
    
    
}

-(void)WF_updateSnapPoint{
    self.WF_centerPoint = [self convertPoint:CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f) toView:self.WF_playground];
    self.WF_snapBehavior = [[UISnapBehavior alloc]initWithItem:self snapToPoint:self.WF_centerPoint];
    self.WF_snapBehavior.damping = self.WF_damping;
}

-(void)WF_removeDraggable{
    [self removeGestureRecognizer:self.WF_recognizer];
    self.WF_playground = nil;
    self.WF_animator = nil;
    self.WF_snapBehavior = nil;
    self.WF_attachmentBehavior = nil;
    self.WF_recognizer = nil;
    self.WF_centerPoint = CGPointZero;
}

-(void)addPanGesture{
    self.WF_recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:self.WF_recognizer];
}

-(void)createAnimator{
    self.WF_animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.WF_playground];
    [self WF_updateSnapPoint];
}

#pragma mark gesture
//TODO:TODO
-(void)panGesture:(UIPanGestureRecognizer *)pan{
    CGPoint panLocation = [pan locationInView:self.WF_playground];
    
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        UIOffset offset = UIOffsetMake(panLocation.x - self.WF_centerPoint.x, panLocation.y - self.WF_centerPoint.y);
        [self.WF_animator removeAllBehaviors];
        self.WF_attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self
                                                               offsetFromCenter:offset
                                                               attachedToAnchor:panLocation];
        [self.WF_animator addBehavior:self.WF_attachmentBehavior];
    }
    else if (pan.state == UIGestureRecognizerStateChanged)
    {
        [self.WF_attachmentBehavior setAnchorPoint:panLocation];
    }
    else if (pan.state == UIGestureRecognizerStateEnded ||
             pan.state == UIGestureRecognizerStateCancelled ||
             pan.state == UIGestureRecognizerStateFailed)
    {
        [self.WF_animator removeAllBehaviors];
        [self.WF_animator addBehavior:self.WF_snapBehavior];
    }
}

#pragma mark associated object
-(void)setWF_playground:(UIView *)WF_playground{
    objc_setAssociatedObject(self, @selector(WF_playground), WF_playground, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIView *)WF_playground{
    return objc_getAssociatedObject(self, @selector(WF_playground));
}

-(void)setWF_animator:(UIDynamicAnimator *)WF_animator{
    objc_setAssociatedObject(self, @selector(WF_animator), WF_animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIDynamicAnimator *)WF_animator{
   return  objc_getAssociatedObject(self, @selector(WF_animator));
}

-(void)setWF_snapBehavior:(UISnapBehavior *)WF_snapBehavior{
    objc_setAssociatedObject(self, @selector(WF_snapBehavior), WF_snapBehavior, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UISnapBehavior *)WF_snapBehavior{
    return  objc_getAssociatedObject(self, @selector(WF_snapBehavior));
}

-(void)setWF_attachmentBehavior:(UIAttachmentBehavior *)WF_attachmentBehavior{
    objc_setAssociatedObject(self, @selector(WF_attachmentBehavior), WF_attachmentBehavior, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIAttachmentBehavior *)WF_attachmentBehavior{
   return  objc_getAssociatedObject(self, @selector(WF_attachmentBehavior));
}

-(void)setWF_recognizer:(UIPanGestureRecognizer *)WF_recognizer{
    objc_setAssociatedObject(self, @selector(WF_snapBehavior), WF_recognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIPanGestureRecognizer *)WF_recognizer{
    return objc_getAssociatedObject(self, @selector(WF_recognizer));
}

-(void)setWF_centerPoint:(CGPoint)WF_centerPoint{
    objc_setAssociatedObject(self, @selector(WF_centerPoint), [NSValue valueWithCGPoint:WF_centerPoint], OBJC_ASSOCIATION_ASSIGN);
}

-(CGPoint)WF_centerPoint{
    return [objc_getAssociatedObject(self, @selector(WF_centerPoint)) CGPointValue];
}

-(void)setWF_damping:(CGFloat)WF_damping{
    objc_setAssociatedObject(self, @selector(WF_damping), [NSNumber numberWithFloat:WF_damping], OBJC_ASSOCIATION_ASSIGN);
}

-(CGFloat)WF_damping{
    return [objc_getAssociatedObject(self, @selector(WF_damping)) floatValue];
}


@end
