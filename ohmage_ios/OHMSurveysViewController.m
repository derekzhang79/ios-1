//
//  OHMOhmletViewController.m
//  ohmage_ios
//
//  Created by Charles Forkish on 4/2/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import "OHMSurveysViewController.h"
#import "OHMSurveyTableViewCell.h"
#import "OHMSurveyDetailViewController.h"
#import "OHMSurveyItemViewController.h"
#import "OHMUserViewController.h"
#import "OHMModel.h"
#import "OHMSurvey.h"
#import "OHMReminder.h"

@interface OHMSurveysViewController () <OHMModelDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) OHMModel *model;
@property (nonatomic) NSInteger ohmletIndex;

@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, weak) UILabel *ohmletNameLabel;
@property (nonatomic, weak) UILabel *ohmletDescriptionLabel;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation OHMSurveysViewController

- (instancetype)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshSurveys) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:nil
                                                                      action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.navigationItem.title = @"ohmage";
    
    UIBarButtonItem *ohmButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ohmage_toolbar"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(userButtonPressed:)];
    self.navigationItem.leftBarButtonItem = ohmButton;
    
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"help_icon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(helpButtonPressed:)];
    self.navigationItem.rightBarButtonItem = helpButton;
    
    self.model.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName : [UIFont boldSystemFontOfSize:22]}];
    self.navigationController.navigationBar.barTintColor = [OHMAppConstants ohmageColor];
}

- (OHMModel *)model
{
    if (_model == nil) {
        _model = [OHMModel sharedModel];
    }
    return _model;
}

- (NSFetchedResultsController *)fetchedResultsController
{

    if (_fetchedResultsController == nil) {
        NSSortDescriptor *dueDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isDue" ascending:NO];
        NSSortDescriptor *indexDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@", self.model.loggedInUser];
        _fetchedResultsController = [self.model fetchedResultsControllerWithEntityName:[OHMSurvey entityName]
                                                                                       sortDescriptors:@[dueDescriptor, indexDescriptor]
                                                                                             predicate:predicate
                                                                                    sectionNameKeyPath:@"isDue"
                                                                                             cacheName:nil];
        _fetchedResultsController.delegate = self;
        [_fetchedResultsController performFetch:nil];
        
    }
    return _fetchedResultsController;

}

- (void)refreshSurveys
{
    NSLog(@"refresh surveys");
    [[OHMModel sharedModel] fetchSurveys];
}

- (void)userButtonPressed:(id)sender
{
    OHMUserViewController *vc = [[OHMUserViewController alloc] init];
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navCon animated:YES completion:nil];
}

- (void)helpButtonPressed:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://ohmage.org/"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)startSurvey:(OHMSurvey *)survey animated:(BOOL)animated
{
    OHMSurveyResponse *newResponse = [[OHMModel sharedModel] buildResponseForSurvey:survey];
    OHMSurveyItemViewController *vc = [[OHMSurveyItemViewController alloc] initWithSurveyResponse:newResponse atQuestionIndex:0];
    [self.navigationController pushViewController:vc animated:animated];
}

- (void)handleSurveyReminderNotification:(UILocalNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    OHMReminder *reminder = [[OHMModel sharedModel] reminderWithUUID:notification.userInfo.reminderID];
    [self startSurvey:reminder.survey animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MAX([[self.fetchedResultsController sections] count], 1);
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        return 1;
    }
    
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        cell = [OHMUserInterface cellWithDefaultStyleFromTableView:tableView];
        cell.textLabel.text = @"No Surveys (pull to refresh)";
    }
    else {
        cell = [OHMUserInterface cellWithSubtitleStyleFromTableView:tableView];
        [self configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row >= [[self.fetchedResultsController fetchedObjects] count]) {
        return;
    }
    
    OHMSurvey *survey = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.backgroundColor = [OHMAppConstants lightColorForSurveyIndex:survey.indexValue];
    cell.tintColor = [UIColor darkTextColor];
    cell.textLabel.text = survey.surveyName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) return;
    
    OHMSurvey *survey = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self startSurvey:survey animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    OHMSurvey *survey = [self.fetchedResultsController objectAtIndexPath:indexPath];
    OHMSurveyDetailViewController *vc = [[OHMSurveyDetailViewController alloc] initWithSurvey:survey];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        return tableView.rowHeight;
    }
    
    OHMSurvey *survey = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [OHMUserInterface heightForSubtitleCellWithTitle:survey.surveyName
                                                   subtitle:nil//survey.surveyDescription
                                              accessoryType:UITableViewCellAccessoryDetailDisclosureButton
                                              fromTableView:tableView];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.fetchedResultsController.sections.count > 1) {
        if (section == 0) {
            return @"Due Surveys:";
        }
        else {
            return @"Available Surveys:";
        }
    }
    else {
        return @"Surveys:";
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 10.0;
//    if (self.fetchedResultsController.sections.count > 1) {
//        return UITableViewAutomaticDimension;
//    }
//    else {
//        return 0.0;
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 10.0;
//}


#pragma mark - Client Delegate

- (void)OHMModelDidFetchSurveys:(OHMModel *)model
{
    [self.refreshControl endRefreshing];
}

- (void)OHMModelUserDidChange:(OHMModel *)model
{
    self.fetchedResultsController = nil;
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}


#pragma mark - NSFetchedResultsController Delegate


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

@end
