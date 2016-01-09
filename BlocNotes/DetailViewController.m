//
//  DetailViewController.m
//  BlocNotes
//
//  Created by Matti Salokangas on 12/30/15.
//  Copyright © 2015 Sturdy Nut. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *longGestureRecognizerForTitle;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGestureRecognizerForBody;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    self.longGestureRecognizerForTitle = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shareTitle:)];
    self.longGestureRecognizerForTitle.delegate = self;
    [self.noteTitleField addGestureRecognizer:self.longGestureRecognizerForTitle];
    
    self.longGestureRecognizerForBody = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shareBody:)];
    self.longGestureRecognizerForBody.delegate = self;
    [self.noteBodyField addGestureRecognizer:self.longGestureRecognizerForBody];
    
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.noteTitleField.text = [[self.detailItem valueForKey:@"title"] description];
        self.noteBodyField.text = [[self.detailItem valueForKey:@"body"] description];
        
        NSDate *createdOn = [self.detailItem  valueForKey:@"createdOn"];
        NSDate *modifiedOn = [self.detailItem valueForKey:@"modifiedOn"];
        
        NSDateFormatter *createdOnFormatter = [[NSDateFormatter alloc] init];
        NSDateFormatter *modifiedOnFormatter = [[NSDateFormatter alloc] init];
        
        NSString *preciseFormatString = @"MM/dd/yyyy h:mm a";
        NSString *recentFormatString = @"E h:mm a";
        
        NSString *createdOnFormatString = preciseFormatString;
        NSString *modifiedOnFormatString = preciseFormatString;
        
        int daysSinceCreated = [self daysFromToday:createdOn];
        int daysSinceModified = [self daysFromToday:modifiedOn];

        if (daysSinceCreated < 8) {
            createdOnFormatString = recentFormatString;
        }
        
        if (daysSinceModified < 8) {
            modifiedOnFormatString = recentFormatString;
        }
        
        [createdOnFormatter setDateFormat:createdOnFormatString];
        [modifiedOnFormatter setDateFormat:modifiedOnFormatString];
        
        self.createdOnLabel.text = [NSString stringWithFormat:@"%@", [createdOnFormatter stringFromDate:createdOn]];
        self.modifiedOnLabel.text = [NSString stringWithFormat:@"%@", [modifiedOnFormatter stringFromDate:modifiedOn]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // @todo:  This feels dirty, can I tie these UITextFields directly to my object?
    [self.detailItem setValue:self.noteTitleField.text forKey:@"title"];
    [self.detailItem setValue:self.noteBodyField.text forKey:@"body"];
    [self.detailItem setValue:[NSDate date] forKey:@"modifiedOn"];
    
    // Using delegation here...not sure if this is the best way.
    [self.delegate needsSaving];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Gestures

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) shareTitle:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self showSharingMenu:@[[self.detailItem valueForKey:@"title"]]];
    }
}

- (void) shareBody:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self showSharingMenu:@[[self.detailItem valueForKey:@"body"]]];
    }
}

# pragma mark Privates

- (void) showSharingMenu:(NSArray *)itemsToShare {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

// http://stackoverflow.com/questions/4739483/number-of-days-between-two-nsdates
- (int)daysFromToday:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger today=[calendar ordinalityOfUnit:NSCalendarUnitDay
                                           inUnit:NSCalendarUnitEra
                                          forDate:[NSDate date]];
    NSInteger pastDate=[calendar ordinalityOfUnit:NSCalendarUnitDay
                                         inUnit:NSCalendarUnitEra
                                        forDate:date];
    return abs(pastDate - today);
}

@end
