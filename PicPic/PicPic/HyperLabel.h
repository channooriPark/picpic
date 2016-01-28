//
//  HyperLabel.h
//  PicPic
//
//  Created by 김범수 on 2016. 1. 28..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HyperLabel : UILabel

@property (nonatomic) NSDictionary *linkAttributeDefault;
@property (nonatomic) NSDictionary *linkAttributeHighlight;

- (void)setLinkForRange:(NSRange)range withAttributes:(NSDictionary *)attributes andLinkHandler:(void (^)(HyperLabel *label, NSRange selectedRange))handler;
- (void)setLinkForRange:(NSRange)range withLinkHandler:(void(^)(HyperLabel *label, NSRange selectedRange))handler;

- (void)setLinkForSubstring:(NSString *)substring withAttribute:(NSDictionary *)attribute andLinkHandler:(void(^)(HyperLabel *label, NSString *substring))handler;
- (void)setLinkForSubstring:(NSString *)substring withLinkHandler:(void(^)(HyperLabel *label, NSString *substring))handler;

- (void)setLinksForSubstrings:(NSArray *)substrings withLinkHandler:(void(^)(HyperLabel *label, NSString *substring))handler;

- (void)clearActionDictionary;

@end