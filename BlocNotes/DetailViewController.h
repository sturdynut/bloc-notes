//
//  DetailViewController.h
//  BlocNotes
//
//  Created by Matti Salokangas on 12/30/15.
//  Copyright © 2015 Sturdy Nut. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailViewDelegate <NSObject>

@required
- (void) needsSaving;

@end

@interface DetailViewController : UIViewController

@property (weak, nonatomic) id <DetailViewDelegate> delegate;

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UITextField *noteTitleField;
@property (weak, nonatomic) IBOutlet UITextView *noteBodyField;
@property (weak, nonatomic) IBOutlet UILabel *createdOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifiedOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdOnValue;
@property (weak, nonatomic) IBOutlet UILabel *modifiedOnValue;

@end

