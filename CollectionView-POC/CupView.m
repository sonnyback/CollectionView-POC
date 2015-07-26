//
//  CupView.m
//  CollectionView-POC
//
//  Created by Sonny Back on 4/17/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import "CupView.h"

@interface CupView()
//@property (strong, nonatomic) UIImageView *backgroundView;
//@property (strong, nonatomic) UIImage *cupImage;
@end

@implementation CupView

/*- (void)setCupImage:(UIImage *)cupImage {
    
    _cupImage = [UIImage imageNamed:@"Hot_Coffee_Cup.jpg"];
}*/

/*- (void)setBackgroundView:(UIImageView *)backgroundView {
    
    _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.width)];
    _backgroundView.contentMode = UIViewContentModeScaleAspectFit;
}*/

/*- (void)setImageView:(UIImageView *)imageView {
    
    _imageView.image = [UIImage imageNamed:@"Hot_Coffee_Cup.jpg"];
}*/

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect {
    // Drawing code
    

}*/

- (void)setup {
    
    NSLog(@"INFO: setup...");
    //self.contentMode = UIViewContentModeScaleToFill;
    //UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Hot_Coffee_Cup.jpg"]];
    //backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    //[self addSubview:backgroundView];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.width)];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImage *img = [UIImage imageNamed:@"Hot_Coffee_Cup.jpg"];
    [backgroundView setImage:img];
    self.clipsToBounds = YES;
    [self addSubview:backgroundView];
    
    //UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height)];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Show Us How to Make this Drink";
    // position the label in the center of the view above the cup image
    titleLabel.frame = CGRectMake(self.bounds.origin.x/2 + titleLabel.text.length, self.bounds.size.height/2 - (self.bounds.size.height * .95), self.bounds.size.width, self.bounds.size.height);
    NSLog(@"titleLabel size is: %lu", (unsigned long)titleLabel.text.length);
    [backgroundView addSubview:titleLabel];
}

// because this this called out of storyboard...
- (void)awakeFromNib {
    
    NSLog(@"INFO: awakeFromNib...");
    [self setup];
}

@end
