//
//  AMBubbleTableViewController.m
//  BubbleTableDemo
//
//  Created by Andrea Mazzini on 30/06/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMBubbleTableViewController.h"
#import "AMBubbleTableCell.h"

#define kInputHeight 40.0f
#define kLineHeight 30.0f
#define kButtonWidth 78.0f


@interface AMBubbleTableViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSMutableDictionary*	options;
@property (nonatomic, strong) UITableView*	tableView;
@property (nonatomic, strong) UIImageView*	imageInput;
@property (nonatomic, strong) UITextView*	textView;
@property (nonatomic, strong) UIImageView*	imageInputBack;
@property (nonatomic, strong) UIButton*		buttonSend;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, assign) float			previousTextFieldHeight;

@end

@implementation AMBubbleTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setupView];
}

- (void)setBubbleTableOptions:(NSDictionary *)options
{
	[self.options addEntriesFromDictionary:options];
}

- (NSMutableDictionary*)options
{
	if (_options == nil) {
		_options = [[NSMutableDictionary alloc]
					initWithDictionary:
					@{
					// Default options
					AMOptionsTableStyle : @(AMBubbleTableCellDefault)
					}];
	}
	return _options;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleKeyboardWillShow:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleKeyboardWillHide:)
												 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupView
{
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																						action:@selector(handleTapGesture:)];
	// Table View
    CGRect tableFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - kInputHeight);
	self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
	[self.tableView addGestureRecognizer:gestureRecognizer];
	[self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.tableView setDataSource:self];
	[self.tableView setDelegate:self];
	[self.tableView setBackgroundColor:[UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f]];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.view addSubview:self.tableView];
	
    // Input background
    CGRect inputFrame = CGRectMake(0.0f, self.view.frame.size.height - kInputHeight, self.view.frame.size.width, kInputHeight);
	
	self.imageInput = [[UIImageView alloc] initWithImage:
					   [[UIImage imageNamed:@"imageBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0f, 3.0f, 19.0f, 3.0f)]
					   ];
	[self.imageInput setFrame:inputFrame];
	[self.imageInput setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin)];
	[self.imageInput setUserInteractionEnabled:YES];
	
	[self.view addSubview:self.imageInput];
	
	// Input field
	CGFloat width = self.imageInput.frame.size.width - kButtonWidth;
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(6.0f, 3.0f, width, kLineHeight)];
    [self.textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.textView setScrollIndicatorInsets:UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f)];
    [self.textView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [self.textView setScrollEnabled:NO];
    [self.textView setScrollsToTop:NO];
    [self.textView setUserInteractionEnabled:YES];
    [self.textView setFont:[UIFont systemFontOfSize:15]];
    [self.textView setTextColor:[UIColor blackColor]];
    [self.textView setBackgroundColor:[UIColor whiteColor]];
    [self.textView setKeyboardAppearance:UIKeyboardAppearanceDefault];
    [self.textView setKeyboardType:UIKeyboardTypeDefault];
    [self.textView setReturnKeyType:UIReturnKeyDefault];
	[self.textView setDelegate:self];
    [self.imageInput addSubview:self.textView];
	self.previousTextFieldHeight = self.textView.contentSize.height;

	// Input field's background
    self.imageInputBack = [[UIImageView alloc] initWithFrame:CGRectMake(self.textView.frame.origin.x - 1.0f,
																		0.0f,
																		self.textView.frame.size.width + 2.0f,
																		self.imageInput.frame.size.height)];
    [self.imageInputBack setImage:[[UIImage imageNamed:@"imageInput"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 12.0f, 18.0f, 18.0f)]];
    [self.imageInputBack setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.imageInputBack setBackgroundColor:[UIColor clearColor]];
	[self.imageInputBack setUserInteractionEnabled:NO];
    [self.imageInput addSubview:self.imageInputBack];

	// Send button
    self.buttonSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSend setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin)];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f);
    UIImage *sendBack = [[UIImage imageNamed:@"buttonSend"] resizableImageWithCapInsets:insets];
    UIImage *sendBackHighLighted = [[UIImage imageNamed:@"buttonSendHighlighted"] resizableImageWithCapInsets:insets];
    [self.buttonSend setBackgroundImage:sendBack forState:UIControlStateNormal];
    [self.buttonSend setBackgroundImage:sendBack forState:UIControlStateDisabled];
    [self.buttonSend setBackgroundImage:sendBackHighLighted forState:UIControlStateHighlighted];
    
    NSString *title = NSLocalizedString(@"Send", nil);
    [self.buttonSend setTitle:title forState:UIControlStateNormal];
    [self.buttonSend setTitle:title forState:UIControlStateHighlighted];
    [self.buttonSend setTitle:title forState:UIControlStateDisabled];
    self.buttonSend.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    
    UIColor *titleShadow = [UIColor colorWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
    [self.buttonSend setTitleShadowColor:titleShadow forState:UIControlStateNormal];
    [self.buttonSend setTitleShadowColor:titleShadow forState:UIControlStateHighlighted];
    self.buttonSend.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);

    [self.buttonSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonSend setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.buttonSend setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    
    [self.buttonSend setEnabled:NO];
    [self.buttonSend setFrame:CGRectMake(self.imageInput.frame.size.width - 65.0f, 8.0f, 59.0f, 26.0f)];
    [self.buttonSend addTarget:self	action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
	
    [self.imageInput addSubview:self.buttonSend];
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dataSource numberOfRows];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	AMBubbleCellType type = [self.dataSource cellTypeForRowAtIndexPath:indexPath];
	NSString* cellID = [NSString stringWithFormat:@"cell_%d", type];
	
	AMBubbleTableCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	
	// TODO: parametrize style
	if (cell == nil) {
		cell = [[AMBubbleTableCell alloc] initWithStyle:AMBubbleTableCellDefault reuseIdentifier:cellID];
	}
	
	NSString* text = [self.dataSource textForRowAtIndexPath:indexPath];
	NSDate* date = [self.dataSource timestampForRowAtIndexPath:indexPath];
	
	NSString* stringDate;
	if (type == AMBubbleCellTimestamp) {
		[self.dateFormatter setDateStyle:NSDateFormatterMediumStyle]; // Jan 1, 2000
		[self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];  // 1:23 PM
		stringDate = [self.dateFormatter stringFromDate:date];
	} else {
		[self.dateFormatter setDateFormat:@"HH:mm"];
		stringDate = [self.dateFormatter stringFromDate:date];
	}

	[cell setupCellWithType:type withWidth:self.tableView.frame.size.width andParams:@{ @"text": text, @"date": stringDate }];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* text = [self.dataSource textForRowAtIndexPath:indexPath];
	
	// TODO Set SentDate height.
    
    // Set MessageCell height.
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:15]
				   constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
					   lineBreakMode:NSLineBreakByWordWrapping];
	
    return size.height + 17.0f;
}

#pragma mark - Keyboard Handlers

- (void)handleKeyboardWillShow:(NSNotification *)notification
{
	[self resizeView:notification];
	[self scrollToBottomAnimated:YES];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
	[self resizeView:notification];	
}

- (void)resizeView:(NSNotification*)notification
{
	CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:curve << 16
                     animations:^{
                         CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
                         
                         CGRect inputViewFrame = self.imageInput.frame;
                         CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                         
                         self.imageInput.frame = CGRectMake(inputViewFrame.origin.x,
                                                           inputViewFrameY,
                                                           inputViewFrame.size.width,
                                                           inputViewFrame.size.height);
                         
                         UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                                                0.0f,
                                                                self.view.frame.size.height - self.imageInput.frame.origin.y - kInputHeight,
                                                                0.0f);
						 
                         self.tableView.contentInset = insets;
                         self.tableView.scrollIndicatorInsets = insets;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)resizeTextViewByHeight:(CGFloat)delta
{
	int numLines = self.textView.contentSize.height / self.textView.font.lineHeight;
    
    self.textView.frame = CGRectMake(self.textView.frame.origin.x,
                                     self.textView.frame.origin.y,
                                     self.textView.frame.size.width,
                                     self.textView.frame.size.height + delta);
    
    self.textView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
    
    self.textView.scrollEnabled = (numLines >= 4);
	
	self.imageInput.frame = CGRectMake(self.imageInput.frame.origin.x,
                                     self.imageInput.frame.origin.y - delta,
                                     self.imageInput.frame.size.width,
                                     self.imageInput.frame.size.height + delta);
	
	UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
										   0.0f,
										   self.view.frame.size.height - self.imageInput.frame.origin.y - kInputHeight,
										   0.0f);
	
	self.tableView.contentInset = insets;
	self.tableView.scrollIndicatorInsets = insets;
}

- (void)handleTapGesture:(UIGestureRecognizer*)gesture
{
	[self.textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
	[self.buttonSend setEnabled:(textView.text.length > 0)];
	
	CGFloat textViewContentHeight = textView.contentSize.height;

	if (textViewContentHeight != self.previousTextFieldHeight) {
		[self resizeTextViewByHeight:textViewContentHeight - self.previousTextFieldHeight];
	}
	
	self.previousTextFieldHeight = textView.contentSize.height;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger bottomRow = [self.dataSource numberOfRows] - 1;
    if (bottomRow >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
							  atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)sendPressed:(id)sender
{
	[self.delegate didSendText:self.textView.text];
	[self.textView setText:@""];
	[self resizeTextViewByHeight:self.textView.contentSize.height - self.previousTextFieldHeight];
	self.previousTextFieldHeight = self.textView.contentSize.height;
    [self.buttonSend setEnabled:NO];
	[self scrollToBottomAnimated:YES];
}

- (void)reloadTableScrollingToBottom:(BOOL)scroll
{
	[self.tableView reloadData];
	if (scroll) {
		[self scrollToBottomAnimated:YES];
	}
}

- (NSDateFormatter*)dateFormatter
{
	if (_dateFormatter == nil) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]]];
	}
	return _dateFormatter;
}

@end