//
//  UIView+WFDraggable.h
//  
//
//  Created by wufer on 2018/3/7.
//

#import <UIKit/UIKit.h>

@interface UIView (WFDraggable)

-(void)WF_makeDraggable;

-(void)WF_makeDraggableOnPlayground:(nonnull UIView *)Playground damping:(CGFloat)damping;

-(void)WF_removeDraggable;

-(void)WF_updateSnapPoint;


@end
