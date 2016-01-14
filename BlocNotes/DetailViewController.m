//
//  DetailViewController.m
//  BlocNotes
//
//  Created by Matti Salokangas on 12/30/15.
//  Copyright © 2015 Sturdy Nut. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UIGestureRecognizerDelegate, UITextViewDelegate>

@property (strong, nonatomic) UILongPressGestureRecognizer *longGestureRecognizerForTitle;
@property (strong, nonatomic) UILongPressGestureRecognizer *longGestureRecognizerForBody;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizerForBody;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
//@todo There is a better way...
@property (strong, nonatomic) NSString *originalDetailItemTitle;
@property (strong, nonatomic) NSString *originalDetailItemBody;

@end

@implementation DetailViewController

static NSString *titleKey = @"title";
static NSString *bodyKey = @"body";
static NSString *modifiedOnKey = @"modifiedOn";
static NSString *createdOnKey = @"createdOn";
static NSString *preciseFormatString = @"MM/dd/yyyy h:mm a";
static NSString *recentFormatString = @"E h:mm a";

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureView];
    
    self.noteBodyField.delegate = self;
    self.noteBodyField.selectable = YES;
    [self toggleEditMode:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.longGestureRecognizerForTitle = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shareTitle:)];
    self.longGestureRecognizerForTitle.delegate = self;
    [self.noteTitleField addGestureRecognizer:self.longGestureRecognizerForTitle];
    
    self.longGestureRecognizerForBody = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shareBody:)];
    self.longGestureRecognizerForBody.delegate = self;
    [self.noteBodyField addGestureRecognizer:self.longGestureRecognizerForBody];
    
    self.tapGestureRecognizerForBody = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBodyText:)];
    [self.noteBodyField addGestureRecognizer:self.tapGestureRecognizerForBody];
    self.tapGestureRecognizerForBody.delegate = self;
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.detailItem setValue:self.noteTitleField.text forKey:titleKey];
    [self.detailItem setValue:self.noteBodyField.text forKey:bodyKey];
    
    if ([self hasChanges]) {
        [self.detailItem setValue:[NSDate date] forKey:modifiedOnKey];
        [self.delegate needsSaving];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.noteTitleField.text = [[self.detailItem valueForKey:titleKey] description];
        self.noteBodyField.text = [[self.detailItem valueForKey:bodyKey] description];
        
        NSDate *createdOn = [self.detailItem  valueForKey:createdOnKey];
        NSDate *modifiedOn = [self.detailItem valueForKey:modifiedOnKey];
        
        NSDateFormatter *createdOnFormatter = [[NSDateFormatter alloc] init];
        NSDateFormatter *modifiedOnFormatter = [[NSDateFormatter alloc] init];
        
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

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        self.originalDetailItemTitle = [[self.detailItem valueForKey:titleKey] description];
        self.originalDetailItemBody = [[self.detailItem valueForKey:bodyKey] description];
            
        // Update the view.
        [self configureView];
    }
}

# pragma mark Gestures

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) shareTitle:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self showSharingMenu:@[[self.detailItem valueForKey:titleKey]]];
    }
}

- (void) shareBody:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self showSharingMenu:@[[self.detailItem valueForKey:bodyKey]]];
    }
}

- (void) tappedBodyText:(UITapGestureRecognizer *)sender {
    [self toggleEditMode:YES];
    [self.noteBodyField becomeFirstResponder];
}

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

# pragma mark UITextView Delegate

-(void)textViewDidEndEditing:(UITextView *)textView {
    [self toggleEditMode:NO];
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return YES;
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
    return abs((int)pastDate - (int)today);
}

- (BOOL) hasChanges {
    NSString *title = [[self.detailItem valueForKey:titleKey] description];
    NSString *body = [[self.detailItem valueForKey:bodyKey] description];
    
    return ![title isEqualToString:self.originalDetailItemTitle]
    || ![body isEqualToString:self.originalDetailItemBody];
}

- (void) toggleEditMode:(BOOL)on {
    if (on == YES) {
        self.noteBodyField.editable = YES;
        self.noteBodyField.dataDetectorTypes = UIDataDetectorTypeNone;
    }
    else {
        self.noteBodyField.editable = NO;
        self.noteBodyField.dataDetectorTypes = UIDataDetectorTypeAll;
    }
}

@end
