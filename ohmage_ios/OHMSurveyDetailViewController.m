//
//  OHMSurveyDetailViewController.m
//  ohmage_ios
//
//  Created by Charles Forkish on 4/8/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import "OHMSurveyDetailViewController.h"
#import "OHMSurveyItemViewController.h"
#import "OHMReminderViewController.h"
#import "OHMUserInterface.h"
#import "OHMSurvey.h"
#import "OHMSurveyResponse.h"
#import "OHMReminder.h"

static const NSInteger kRemindersSectionIndex = 0;
static const NSInteger kSurveyResponsesSectionIndex = 1;

@interface OHMSurveyDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *promptCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *takeSurveyButton;
@property (nonatomic, strong) OHMSurvey *survey;

@property (nonatomic, strong) NSFetchedResultsController *fetchedSurveyResponsesController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedRemindersController;

@end

@implementation OHMSurveyDetailViewController

- (id)initWithSurvey:(OHMSurvey *)survey
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.survey = survey;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Survey Detail";
    NSLog(@"navItem left button: %@", self.navigationItem.leftBarButtonItem.title);
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:nil
                                                                      action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    
    [self setupHeaderView];
    
    NSPredicate *sureveyResultsPredicate = [NSPredicate predicateWithFormat:@"survey == %@", self.survey];
    self.fetchedSurveyResponsesController = [[OHMClient sharedClient] fetchedResultsControllerWithEntityName:[OHMSurveyResponse entityName] sortKey:@"timestamp" predicate:sureveyResultsPredicate sectionNameKeyPath:nil cacheName:nil];
    
    NSPredicate *remindersPredicate = [NSPredicate predicateWithFormat:@"survey == %@", self.survey];
    self.fetchedRemindersController = [[OHMClient sharedClient] fetchedResultsControllerWithEntityName:[OHMReminder entityName] sortKey:@"isTimeReminder" predicate:remindersPredicate sectionNameKeyPath:nil cacheName:nil];
    
    NSLog(@"Survey: %@", self.survey);
}

- (void)setupHeaderView
{
    NSString *nameText = self.survey.surveyName;
    NSString *descriptionText = self.survey.surveyDescription;
    NSString *plural = ([self.survey.surveyItems count] == 1 ? @"Prompt" : @"Prompts");
    NSString *promptCountText = [NSString stringWithFormat:@"%lu %@", (unsigned long)[self.survey.surveyItems count], plural];
    
    CGFloat contentWidth = self.tableView.bounds.size.width - 2 * kUIViewHorizontalMargin;
    CGFloat contentHeight = kUIViewVerticalMargin;
    
    UILabel *nameLabel = [OHMUserInterface headerTitleLabelWithText:nameText width:contentWidth];
    contentHeight += nameLabel.frame.size.height + kUIViewSmallTextMargin;
    
    UILabel *descriptionLabel = [OHMUserInterface headerDescriptionLabelWithText:descriptionText width:contentWidth];
    contentHeight += descriptionLabel.frame.size.height + kUIViewSmallTextMargin;
    
    UILabel *promptCountLabel = [OHMUserInterface headerDetailLabelWithText:promptCountText width:contentWidth];
    contentHeight += promptCountLabel.frame.size.height + kUIViewVerticalMargin;
    
//    CGFloat buttonWidth = self.view.bounds.size.width - 2 * kUIViewHorizontalMargin;
    UIButton *takeSurveyButton = [OHMUserInterface buttonWithTitle:@"Take Survey" target:self action:@selector(takeSurvey:) maxWidth:contentWidth];
    takeSurveyButton.backgroundColor = [OHMAppConstants colorForRowIndex:self.survey.colorIndex];
    contentHeight += takeSurveyButton.frame.size.height + kUIViewVerticalMargin;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, contentHeight)];
    
    [headerView addSubview:nameLabel];
    [headerView addSubview:descriptionLabel];
    [headerView addSubview:promptCountLabel];
    [headerView addSubview:takeSurveyButton];
    
    [nameLabel centerHorizontallyInView:headerView];
    [descriptionLabel centerHorizontallyInView:headerView];
    [promptCountLabel centerHorizontallyInView:headerView];
    [takeSurveyButton centerHorizontallyInView:headerView];
    
    [nameLabel constrainToTopInParentWithMargin:kUIViewVerticalMargin];
    [descriptionLabel positionBelowElement:nameLabel margin:kUIViewSmallTextMargin];
    [promptCountLabel positionBelowElement:descriptionLabel margin:kUIViewSmallTextMargin];
    [takeSurveyButton positionBelowElement:promptCountLabel margin:kUIViewVerticalMargin];
    
    self.tableView.tableHeaderView = headerView;
    self.nameLabel = nameLabel;
    self.descriptionLabel = descriptionLabel;
    self.promptCountLabel = promptCountLabel;
    self.takeSurveyButton = takeSurveyButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName : [UIFont boldSystemFontOfSize:22]}];
    self.navigationController.navigationBar.barTintColor = [OHMAppConstants colorForRowIndex:self.survey.colorIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takeSurvey:(id)sender {
    
    OHMSurveyResponse *newResponse = [[OHMClient sharedClient] buildResponseForSurvey:self.survey];
    OHMSurveyItemViewController *vc = [OHMSurveyItemViewController viewControllerForSurveyResponse:newResponse atQuestionIndex:0];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)popToNavigationRootAnimated
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kRemindersSectionIndex:
            return MAX([[self.fetchedRemindersController fetchedObjects] count], 1);
        case kSurveyResponsesSectionIndex:
            return MAX([[self.fetchedSurveyResponsesController fetchedObjects] count], 1);
        default:
            return 0;
    }
    
}

- (void)configureReminderCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    if (row == 0) {
        cell.textLabel.text = @"Add reminder";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if ([[self.fetchedSurveyResponsesController fetchedObjects] count] >= row) {
        OHMReminder *reminder = [self.fetchedSurveyResponsesController objectAtIndexPath:[NSIndexPath indexPathForRow:row - 1 inSection:0]];
        cell.textLabel.text = [reminder labelText];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)configureSurveyResponseCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    if ([[self.fetchedSurveyResponsesController fetchedObjects] count]) {
        OHMSurveyResponse *response = [self.fetchedSurveyResponsesController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        cell.textLabel.text = [OHMUserInterface formattedDate:response.timestamp];
    }
    else {
        cell.textLabel.text = @"No responses logged yet.";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case kRemindersSectionIndex:
            [self configureReminderCell:cell forRow:indexPath.row];
            break;
        case kSurveyResponsesSectionIndex:
            [self configureSurveyResponseCell:cell forRow:indexPath.row];
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kRemindersSectionIndex:
            return @"Reminders";
        case kSurveyResponsesSectionIndex:
            return @"Survey Responses";
        default:
            return nil;
            break;
    }
}

- (void)didSelectReminderCellAtRow:(NSInteger)row
{
    OHMReminder *reminder = nil;
    if (row == 0) {
        reminder = [[OHMClient sharedClient] buildNewReminderForSurvey:self.survey];
    }
    else if ([[self.fetchedSurveyResponsesController fetchedObjects] count] >= row) {
        reminder = [self.fetchedSurveyResponsesController objectAtIndexPath:[NSIndexPath indexPathForRow:row - 1 inSection:0]];
    }
    
    OHMReminderViewController *vc = [[OHMReminderViewController alloc] initWithReminder:reminder];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didSelectSurveyResponseCellAtRow:(NSInteger)row
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kRemindersSectionIndex:
            [self didSelectReminderCellAtRow:indexPath.row];
            break;
        case kSurveyResponsesSectionIndex:
            [self didSelectSurveyResponseCellAtRow:indexPath.row];
            break;
        default:
            break;
    }
}
//
//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    OHMSurvey *survey = [self.surveys objectAtIndex:indexPath.row];
//    OHMSurveyDetailViewController *vc = [[OHMSurveyDetailViewController alloc] initWithSurvey:survey];
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    OHMSurvey *survey = self.surveys[indexPath.row];
//    return [OHMUserInterface heightForSubtitleCellWithTitle:survey.surveyName
//                                                   subtitle:survey.surveyDescription
//                                              accessoryType:UITableViewCellAccessoryDetailDisclosureButton
//                                              fromTableView:tableView];
//}


@end
