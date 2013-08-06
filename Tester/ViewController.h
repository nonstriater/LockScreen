//
//  ViewController.h
//  Tester
//
//  Created by mac on 13-8-6.
//  Copyright (c) 2013年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController< UITextFieldDelegate,UIActionSheetDelegate>{

 IBOutlet UITextField *filed1;
 IBOutlet UITextField *filed2;

 IBOutlet UITextField *filed3;
 IBOutlet UITextField *filed4;

}

@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,retain) NSArray *array;

- (IBAction)backButtonClicked:(UIButton *)button;


@end
