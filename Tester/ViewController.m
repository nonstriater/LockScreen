//
//  ViewController.m
//  Tester
//
//  Created by mac on 13-8-6.
//  Copyright (c) 2013年 xiaoran. All rights reserved.
//

#import "ViewController.h"


#define INDEX_OFFSET 10
#define SYSTEM_VERSION_BIG_THAN(v) ([[UIDevice currentDevice].systemVersion compare:v options:NSNumericSearch] == NSOrderedDescending) // 使用这个还是无法消除警告啊

#ifdef __IPHONE_6_0   // 60 or big than 6.0
#define  ALIGN_CENTER  NSTextAlignmentCenter
#else
#define ALIGN_CENTER UITextAlignmentCenter
#endif


@interface ViewController ()

@end

@implementation ViewController
@synthesize array = _array;
@synthesize currentIndex = _currentIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [filed1 becomeFirstResponder];
    self.currentIndex = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeNotificationHandler:) name:@"UITextFieldTextDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidAppear:) name:@"UIKeyboardDidShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidDisAppear:) name:@"UIKeyboardDidShowNotification" object:nil];
    
    
    
    
    self.array = [[[NSArray alloc] initWithObjects:filed1,filed2,filed3,filed4, nil] autorelease ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    
    filed1 = nil;
    filed2 = nil;
    filed3 = nil;
    filed4 = nil;
    
    [_array release];
    _array = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    [super dealloc];

}


#pragma action

- (IBAction)backButtonClicked:(UIButton *)button
{
    NSLog(@"%d",self.currentIndex);
    
    [self.array[--self.currentIndex] becomeFirstResponder];

}



#pragma mark text filed delegate

//
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentIndex = [self.array indexOfObject:textField];
    
}


//如果前面一个填了数字，才允许
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSInteger currentSelected = [self.array indexOfObject:textField] ;
    
    if (currentSelected == 0) {
        return YES;
    }
    
     NSLog(@"%d",self.currentIndex);
    id obj = self.array[currentSelected-1];
    if ([obj isKindOfClass:[UITextField class]]) {
        NSString *last =  ((UITextField *)obj).text;
        if ([last length] != 0) {
            return YES;
        }
    }
    
    return NO;


}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;

}

- (void)textChangeNotificationHandler:(NSNotification *)notification
{
//    NSUInteger tag = textField.tag - INDEX_OFFSET;
//    [(UITextField *)self.array[tag+1] becomeFirstResponder];
    NSLog(@"%@", notification.object);
    
    if ([notification.object isKindOfClass:[UITextField class]]) {
        UITextField *tf = notification.object;
        
        self.currentIndex ++;
        
        NSUInteger tag = tf.tag - INDEX_OFFSET;
        if (tag < [self.array count]-1) {
            [(UITextField *)self.array[tag+1] becomeFirstResponder];
        }else{ // tag == 3
        
            // 如果都 填入 了数字，才应该弹出action sheet
            BOOL shouldFire = YES;
            for (UITextField *tx in self.array) {
                if(tx.text==nil){
                    shouldFire = NO;
                    break;
                }
                
            }
            if (shouldFire) {
                UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancle" destructiveButtonTitle:@"Confirm" otherButtonTitles: nil] autorelease];
                [as showInView:self.view];
            }
                   
        }
        
        
        
        
    }
    
    
    
}




#pragma mark action sheet delegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {//cancel btn
        
        //[self.array makeObjectsPerformSelector:@selector(setText:)];
        for (id obj in self.array) {
            if ([obj isKindOfClass:[UITextField class]]) {
                [(UITextField *)obj setText:nil];
            }
        }
        
        
        if ([self.array count]>0) {
            [self.array[0] becomeFirstResponder];
        }
        
    }
    else if(buttonIndex == 0){ // confirm btn
    
        UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 40)];
        lab.textAlignment = ALIGN_CENTER;
        lab.font = [UIFont systemFontOfSize:20];
    
        
        NSMutableString *str = [NSMutableString stringWithString:@"YOUR PASSWORD:"]; 
        
        
        for (int i=0; i<[self.array count]; i++) {
            id obj = self.array[i];
            if ([obj isKindOfClass:[UITextField class]]) {
                [str appendString:[(UITextField *)obj text]];
            }
            if (i != [self.array count]-1) {
                [str appendString:@"-"];
            }

        }
        
        lab.text = str;
        //lab.text = str;[NSString stringWithFormat:@"YOUR PASSWORD:%@-%@-%@-%@",];
        
        [view addSubview:lab];
        [lab release];
        
        
        self.view = view;
        [view release];
        
    
    }
    

}



#pragma mark keyboard return key promble

// add the return key button
- (void)keyBoardDidAppear:(NSNotification *)notification
{
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(106*2+2, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    doneButton.backgroundColor = [UIColor yellowColor];
    //[doneButton setTitle:@"BACK" forState:UIControlStateNormal|UIControlStateSelected];
    //[doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
    //[doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // locate keyboard view
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        // keyboard found, add the button
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                [keyboard addSubview:doneButton];
        } else {
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                [keyboard addSubview:doneButton];
        }
    }
    

}

// remove the return key button
- (void)keyBoardDidDisAppear:(NSNotification *)notification
{
    
    
    
}


- (void)backClicked:(UIButton *)button
{
    NSLog(@"%d",self.currentIndex);
    
    --self.currentIndex;
    if (self.currentIndex >= 0 && self.currentIndex < [self.array count]) {
        [self.array[self.currentIndex] setText:nil]; // <iOS6.0
        [self.array[self.currentIndex] becomeFirstResponder];
    }
    
    
}


@end
