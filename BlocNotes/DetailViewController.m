//
//  DetailViewController.m
//  BlocNotes
//
//  Created by Matti Salokangas on 12/30/15.
//  Copyright © 2015 Sturdy Nut. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()


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
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.noteTitleField.text = [[self.detailItem valueForKey:@"title"] description];
        self.noteBodyField.text = [[self.detailItem valueForKey:@"body"] description];
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

@end
