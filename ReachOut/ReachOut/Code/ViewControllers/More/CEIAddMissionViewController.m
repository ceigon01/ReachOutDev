//
//  CEIAddMissionViewController.m
//  ReachOut
//
//  Created by Jason Smith on 21.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddMissionViewController.h"
#import <Parse/Parse.h>
#import "CEIButtonCancel.h"
#import "CEIAlertView.h"
#import "CEIMissionsViewController.h"
#import "CEIAddFlockToMissionViewController.h"
#import "CEIAddGoalViewController.h"
#import "UIImageView+WebCache.h"
#import "CEITextField.h"
#import "UIImage+Crop.h"
#import "CEIUserTableViewCell.h"
#import "CEINotificationNames.h"

typedef NS_ENUM(NSInteger, CEIAddMissionPickerViewComponent){
  
  CEIAddMissionPickerViewComponentCounter = 0,
  CEIAddMissionPickerViewComponentTime = 1,
};
static const NSInteger kNumberOfAddMissionPickerViewComponents = 2;

typedef NS_ENUM(NSInteger, CEIAddMissionSection){
  
  CEIAddMissionSectionImage = 0,
  CEIAddMissionSectionDetails = 1,
  CEIAddMissionSectionGoals = 2,
  CEIAddMissionSectionFlock = 3,
};
static const NSInteger kNumberOfAddMissionSections = 4;

typedef NS_ENUM(NSInteger, CEIAddMissionRow){
  
  CEIAddMissionRowImage = 0,
  
  CEIAddMissionRowCaption = 0,
  CEIAddMissionRowIsNeverending = 1,
  CEIAddMissionRowEndsIn = 2,
};
static const NSInteger kNumberOfAddMissionImageRows = 0;
static const NSInteger kNumberOfAddMissionDetailRows = 3;

static const CGFloat kHeightHeaderView = 40.0f;
static const CGFloat kHeightHeaderViewImage = 100.0f;
static const CGFloat kWidthButtonEndsIs = 120.0f;
static const CGFloat kHeightDefaultCell = 44.0f;
static const CGFloat kHeightPickerView = 162.0f;
static NSString *const kIdentifierCellAddMission = @"kIdentifierCellAddMission";
static NSString *const kIdentifierSegueAddMissionToAddGoalWithEdit = @"kIdentifierSegueAddMissionToAddGoalWithEdit";
static NSString *const kNibNameCEIAddGoalView = @"CEIAddGoalView";

static NSString *const kIdentifierSegueAddMissionToAddGoal = @"kIdentifierSegueAddMissionToAddGoal";
static NSString *const kIdentifierSegueAddMissionToAddFlock = @"kIdentifierSegueAddMissionToAddFlock";

NSString *const kTitleButtonImageSourceCameraRollCameraRoll1 = @"Camera roll";
NSString *const kTitleButtonImageSourceCameraRollTakeAPicture1 = @"Take a picture";
static const NSUInteger kNumberOfRowsInPickerViewForComponent0 = 30;
static const NSUInteger kNumberOfRowsInPickerViewForComponent1 = 12;

@interface CEIAddMissionViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) CEITextField *textFieldCaption;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, strong) UISwitch *switchNeverEnding;
@property (nonatomic, strong) NSString *period;
@property (nonatomic, strong) UIImageView *imageViewHeader;
@property (nonatomic, strong) UIButton *buttonImageHeader;
@property (nonatomic, strong) CEIButtonCancel *buttonEndsIn;

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureOutsidePicker;

@property (nonatomic, assign) BOOL missionDidChange;

@end

@implementation CEIAddMissionViewController

- (void)dealloc{
  
  BOOL shouldUpdate = YES;
  
  if (self.isEditing) {
    
    shouldUpdate = self.missionDidChange;
  }
  
  if (shouldUpdate) {
  
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameMissionAdded
                                                        object:@{
                                                                 @"mission" : self.mission,
                                                                 @"goals"   : self.arrayGoals,
                                                                 @"flock"   : self.arrayFlock,
                                                                 @"editing" : [NSNumber numberWithBool:self.isEditing]
                                                                 }];
  }
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationFollowerAdded:(NSNotification *)paramNotification{
  
  self.missionDidChange = YES;
  
  self.arrayFlock = paramNotification.object;
  
  __block PFRelation *relationFlock = [self.mission relationForKey:@"usersAsignees"];
  
  [self.arrayFlock enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger idx, BOOL *stop) {
    
    [relationFlock addObject:user];
  }];
  
  [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:CEIAddMissionSectionFlock]
                withRowAnimation:UITableViewRowAnimationMiddle];
}

- (void)notificationGoalAdded:(NSNotification *)paramNotification{
  
  self.missionDidChange = YES;
  
  PFObject *goal = paramNotification.object;
  
//  __weak typeof(self) weakSelf = self;
  
  goal[@"mission"] = self.mission;
  goal[@"orderIndex"] = [NSNumber numberWithInteger:self.arrayGoals.count];
  [self.arrayGoals addObject:goal];
  [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:CEIAddMissionSectionGoals]
                withRowAnimation:UITableViewRowAnimationMiddle];
  
//  [goal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//    
//    if (error) {
//      
//      [weakSelf.arrayGoals removeObject:goal];
//      [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:CEIAddMissionSectionGoals]
//                        withRowAnimation:UITableViewRowAnimationMiddle];
//      
//      [CEIAlertView showAlertViewWithError:error];
//    }
//  }];
}

- (void)viewDidLoad{
  [super viewDidLoad];
  
  self.missionDidChange = NO;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(notificationGoalAdded:)
                                               name:kNotificationNameGoalAdded
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(notificationFollowerAdded:)
                                               name:kNotificationNameFollowerAddedToMission
                                             object:nil];
  
  self.tableView.editing = YES;
  [self.tableView registerNib:[UINib nibWithNibName:@"CEIUserTableViewCell"
                                             bundle:[NSBundle mainBundle]]
       forCellReuseIdentifier:@"kIdentifierCellAddMission3"];
  
    NSLog(@"timecount: %@",self.mission[@"timeCount"] );
    
  if (self.mission.objectId) {
   
    __weak typeof (self) weakSelf = self;
    
    PFFile *file = self.mission[@"image"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

      weakSelf.imageViewHeader.image = [UIImage imageWithData:data];
    }];

    self.textFieldCaption.text = self.mission[@"caption"];
      self.textFieldCaption.textColor = [CEIColor colorPurpleText];
    self.switchNeverEnding.on = [self.mission[@"isNeverending"] boolValue];
    
    [self.buttonEndsIn setTitle:self.mission[@"timeCount"] forState:UIControlStateNormal];
  }
  
  [self fetchGoals];
  [self fetchFlock];
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  
  [self hidePicker];
}

- (void)fetchGoals{
  
  __weak typeof (self) weakSelf = self;
  

  if (self.mission.objectId) {
    PFQuery *query = [[self.mission relationForKey:@"goals"] query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      
      [weakSelf.arrayGoals setArray:objects];
      [weakSelf.tableView reloadData];
    }];
  }
}

- (void)fetchFlock{

  __weak typeof (self) weakSelf = self;
  
  if (self.mission.objectId){

    PFRelation *relation = self.mission[@"usersAsignees"];
    PFQuery *query = [relation query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      
      [weakSelf.arrayFlock setArray:objects];
      [weakSelf.tableView reloadData];
    }];
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kIdentifierSegueAddMissionToAddFlock]) {
    
    CEIAddFlockToMissionViewController *addFlockViewController = (CEIAddFlockToMissionViewController *)segue.destinationViewController;
    
    addFlockViewController.arrayFollowersSelected = [NSMutableArray arrayWithArray:self.arrayFlock];
    addFlockViewController.mission = self.mission;
  }
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender{

  if ([fromViewController isKindOfClass:[CEIAddGoalViewController class]]) {
    
  }
  else
    if ([fromViewController isKindOfClass:[CEIAddFlockToMissionViewController class]]) {
     
    }
    else
      if ([fromViewController isKindOfClass:[CEIAddMissionViewController class]]) {
    
        return NO;
      }

  return YES;
}

- (IBAction)unwindAddGoal:(UIStoryboardSegue *)unwindSegue{
  
}

- (IBAction)unwindAddFlock:(UIStoryboardSegue *)unwindSegue{

}

#pragma mark - UITableView Datasource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  if (indexPath.section == CEIAddMissionSectionFlock) {
    
    return kHeightUserCell;
  }
  
  return kHeightDefaultCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
  
  if (section == CEIAddMissionRowImage) {
    
    return kHeightHeaderViewImage;
  }
  
  return kHeightHeaderView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return kNumberOfAddMissionSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  switch (section) {
    case CEIAddMissionSectionImage:   { return kNumberOfAddMissionImageRows; }
    case CEIAddMissionSectionDetails: { return kNumberOfAddMissionDetailRows; }
    case CEIAddMissionSectionFlock:   { return self.arrayFlock.count; }
    case CEIAddMissionSectionGoals:   { return self.arrayGoals.count; }
      
    default:
      break;
  }
  
  return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
  
#warning TODO: Localizations
  UIView *view = nil;
  
  switch (section) {
    case CEIAddMissionSectionImage:   {
      
    
      self.imageViewHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
      self.imageViewHeader.userInteractionEnabled = YES;
      self.imageViewHeader.contentMode = UIViewContentModeScaleAspectFill;
      self.imageViewHeader.clipsToBounds = YES;
      
        UIColor *colorTop = [UIColor colorWithWhite:1.0 alpha:0.1];
        UIColor *colorBottom = (self.mission[@"image"])?[UIColor colorWithWhite:0.0 alpha:0.7]:[CEIColor colorIdle];
        NSArray *colors =  [NSArray arrayWithObjects:(id)colorTop.CGColor, colorBottom.CGColor, nil];
        
        NSNumber *stopTop = [NSNumber numberWithFloat:-0.4];
        NSNumber *stopBottom = [NSNumber numberWithFloat:0.8];
        NSArray *locations = [NSArray arrayWithObjects:stopTop, stopBottom, nil];
        
        CAGradientLayer *headerLayer = [CAGradientLayer layer];
        headerLayer.colors = colors;
        headerLayer.locations = locations;
        
        headerLayer.frame = self.imageViewHeader.bounds;
        
        [self.imageViewHeader.layer insertSublayer:headerLayer atIndex:0];
        
        
      if (self.mission[@"image"]) {
        
        PFFile *file = self.mission[@"image"];
        
        self.imageViewHeader.image = [UIImage imageWithData:[file getData]];
      }
      
      self.buttonImageHeader = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonImageHeader setImage:(self.mission[@"image"])?[UIImage imageNamed:@"btnEditPhoto"]:[UIImage imageNamed:@"btnAddPhoto"] forState:UIControlStateNormal];
      [self.buttonImageHeader setAlpha:0.7f];
      self.buttonImageHeader.frame = self.imageViewHeader.bounds;
      [self.buttonImageHeader addTarget:self
                                 action:@selector(tapButtonSetImage:)
                       forControlEvents:UIControlEventTouchUpInside];
      [self.imageViewHeader addSubview:self.buttonImageHeader];
      
      view = self.imageViewHeader;
      
      break;
    }
      
    case CEIAddMissionSectionDetails: {
     
      view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, kHeightHeaderView)];
      view.backgroundColor = [CEIColor colorIdle];
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                 kHeightHeaderView * 0.25f,
                                                                 tableView.frame.size.width,
                                                                 kHeightHeaderView * 0.5f)];
      label.text = @"  Mission Details";
      label.textColor = [UIColor whiteColor];
      label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
      [view addSubview:label];
      
      break;
    }
      
    case CEIAddMissionSectionFlock:   {

      view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, kHeightHeaderView)];
      view.backgroundColor = [CEIColor colorIdle];
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                 kHeightHeaderView * 0.25f,
                                                                 tableView.frame.size.width,
                                                                 kHeightHeaderView * 0.5f)];
      label.text = @"  Followers";
      label.textColor = [UIColor whiteColor];
      label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
      [view addSubview:label];
      
      UIButton *buttonAdd = [UIButton buttonWithType:UIButtonTypeContactAdd];
      buttonAdd.frame = CGRectMake(tableView.frame.size.width - 1.5f * label.frame.size.height,
                                   0.0f,
                                   label.frame.size.height,
                                   label.frame.size.height);
      buttonAdd.tag = CEIAddMissionSectionFlock;
      [label addSubview:buttonAdd];
      
      break;
    }

    case CEIAddMissionSectionGoals:   {
     
      view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, kHeightHeaderView * 2.0f)];
      view.backgroundColor = [CEIColor colorIdle];
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                 kHeightHeaderView * 0.25f,
                                                                 tableView.frame.size.width,
                                                                 kHeightHeaderView * 0.5f)];
      label.text = @"  Goals";
      label.textColor = [UIColor whiteColor];
      label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
      [view addSubview:label];
      
      UIButton *buttonAdd = [UIButton buttonWithType:UIButtonTypeContactAdd];
      buttonAdd.frame = CGRectMake(tableView.frame.size.width - 1.5f * label.frame.size.height,
                                   0.0f,
                                   label.frame.size.height,
                                   label.frame.size.height);
      buttonAdd.tag = CEIAddMissionSectionGoals;
      [label addSubview:buttonAdd];
      
      break;
    }
      
    default:
      break;
  }
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderSection:)];
  [view addGestureRecognizer:tapGestureRecognizer];
  
  view.tag = section;
  
  return view;
}

- (void)tapHeaderSection:(id)paramSender{
  
  UIView *view = nil;
  
  [self hidePicker];
  [self.textFieldCaption resignFirstResponder];
  
  if ([paramSender isKindOfClass:[UITapGestureRecognizer class]]) {
    
    view = ((UITapGestureRecognizer *)paramSender).view;
  }
  else
    if ([paramSender isKindOfClass:[UIView class]]){
    
      view = (UIView *)paramSender;
    }
  
  if (view.tag == CEIAddMissionSectionGoals) {
    
    [self showAddGoal];
  }
  else
    if (view.tag == CEIAddMissionSectionFlock){
      
      [self showAddFollower];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  if (cell == nil) {
    
    cell = [self cellForIndexPath:indexPath];
  }

  if (indexPath.section == CEIAddMissionSectionFlock) {
    
    PFUser *user = [self.arrayFlock objectAtIndex:indexPath.row];
    
    CEIUserTableViewCell *cellUser = (CEIUserTableViewCell *)cell;
    [cellUser.imageView setImage:[UIImage imageNamed:@"spacer"]];
    [cellUser configureWithUser:user];
    cellUser.accessoryType = UITableViewCellAccessoryNone;
  }
  else
    if (indexPath.section == CEIAddMissionSectionGoals){
    
      PFObject *goal = [self.arrayGoals objectAtIndex:indexPath.row];
      cell.textLabel.text = goal[@"caption"];
    }
  
  return cell;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)paramIndexPath{
  
  if (paramIndexPath.section == CEIAddMissionSectionDetails) {
  
    return [NSString stringWithFormat:@"%@%d%d",kIdentifierCellAddMission,paramIndexPath.section,paramIndexPath.row];
  }
  else{
    
    return [NSString stringWithFormat:@"%@%d",kIdentifierCellAddMission,paramIndexPath.section];
  }
}

- (UITableViewCell *)cellForIndexPath:(NSIndexPath *)paramIndexPath{
  
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:[self cellIdentifierForIndexPath:paramIndexPath]];
  
  cell.textLabel.textColor = [CEIColor colorPurpleText];
  switch (paramIndexPath.section) {
    case CEIAddMissionSectionImage:{
      
      break;
    }
      
    case CEIAddMissionSectionDetails:{
      
      switch (paramIndexPath.row) {
        case CEIAddMissionRowCaption:{
          
          [cell.contentView addSubview:self.textFieldCaption];
          break;
        }
        
        case CEIAddMissionRowIsNeverending:{
          
          cell.textLabel.text = @"Neverending mission";
          cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
          cell.accessoryView = self.switchNeverEnding;
          
          break;
        }
          
        case CEIAddMissionRowEndsIn:{
          
          cell.textLabel.text = @"Ends in:";
          cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
          
          cell.accessoryView = self.buttonEndsIn;
          
          break;
        }
          
        default:
          break;
      }
      
      break;
    }

    case CEIAddMissionSectionGoals:{
      
      break;
    }

    case CEIAddMissionSectionFlock:{
      
      break;
    }

    default:
      break;
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  [self.textFieldCaption resignFirstResponder];
  [self hidePicker];
  
  self.selectedIndexPath = indexPath;
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{

  return indexPath.section == CEIAddMissionSectionGoals;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
  
  return indexPath.section == CEIAddMissionSectionGoals;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
  
  return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
  
  for (NSInteger goalCounter = sourceIndexPath.row; goalCounter<destinationIndexPath.row; goalCounter++) {
    
    PFObject *goal = [self.arrayGoals objectAtIndex:goalCounter];
    goal[@"orderIndex"] = [NSNumber numberWithInteger:goalCounter];
  }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
  
  if (proposedDestinationIndexPath.section == CEIAddMissionSectionGoals) {
    
    return proposedDestinationIndexPath;
  }
  else{
    
    return sourceIndexPath;
  }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
  
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    
    PFObject *goal = [self.arrayGoals objectAtIndex:indexPath.row];
    [goal deleteInBackground];
    [self.arrayGoals removeObjectAtIndex:indexPath.row];
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
    
    for (NSInteger goalCounter = indexPath.row; goalCounter<self.arrayGoals.count; goalCounter++) {
      
      PFObject *goal = [self.arrayGoals objectAtIndex:goalCounter];
      goal[@"orderIndex"] = [NSNumber numberWithInteger:goalCounter];
    }
  }
}

#pragma mark - Action handling

- (void)tapSwitchNeverending:(id)paramSender{
  
  self.missionDidChange = YES;
  
  [self hidePicker];
  
  self.mission[@"isNeverending"] = [NSNumber numberWithBool:self.switchNeverEnding.on];
  if (self.switchNeverEnding.on) {
    
    [self.buttonEndsIn setTitle:@"neverending" forState:self.buttonEndsIn.state];
  }
  else{
  
    [self pickerView:self.pickerView didSelectRow:[self.pickerView selectedRowInComponent:CEIAddMissionPickerViewComponentCounter]
         inComponent:CEIAddMissionPickerViewComponentCounter];
    [self pickerView:self.pickerView didSelectRow:[self.pickerView selectedRowInComponent:CEIAddMissionPickerViewComponentTime]
         inComponent:CEIAddMissionPickerViewComponentTime];
  }
}

- (void)showPicker{

  [self.textFieldCaption resignFirstResponder];
  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
  
  self.tapGestureOutsidePicker = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker)];
  [self.view addGestureRecognizer:self.tapGestureOutsidePicker];
  
  [UIView animateWithDuration:0.22f
                        delay:0.0f
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     
                     self.pickerView.frame = CGRectMake(0.0f,
                                                        self.tableView.frame.size.height - kHeightPickerView,
                                                        self.tableView.frame.size.width,
                                                        kHeightPickerView);
                   }
                   completion:NULL];
}

- (void)hidePicker{
  
  [self.view removeGestureRecognizer:self.tapGestureOutsidePicker];
  self.tapGestureOutsidePicker = nil;
  
  [UIView animateWithDuration:0.22f
                        delay:0.0f
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     
                     self.pickerView.frame = CGRectMake(0.0f,
                                                        self.tableView.frame.size.height,
                                                        self.tableView.frame.size.width,
                                                        kHeightPickerView);
                   }
                   completion:NULL];
}

- (void)tapButtonSetImage:(id)paramSender{
  
#warning TODO: localizations
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Set Photo"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                  otherButtonTitles:kTitleButtonImageSourceCameraRollCameraRoll1, kTitleButtonImageSourceCameraRollTakeAPicture1, nil];
  if (IS_IPAD) {
    
    [actionSheet showInView:self.view];
  }
  else {
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
  }
  
  [self.textFieldCaption resignFirstResponder];
  [self hidePicker];
}

- (void)showAddGoal{

  [self.textFieldCaption resignFirstResponder];
  [self hidePicker];
  
  [self performSegueWithIdentifier:kIdentifierSegueAddMissionToAddGoal sender:self];
}

- (void)showAddFollower{
  
  [self.textFieldCaption resignFirstResponder];
  [self hidePicker];
  
  [self performSegueWithIdentifier:kIdentifierSegueAddMissionToAddFlock sender:self];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
  
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    
  }
  else {
   
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:kTitleButtonImageSourceCameraRollTakeAPicture1]) {
      
      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if ([buttonTitle isEqualToString:kTitleButtonImageSourceCameraRollCameraRoll1]){

      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self.navigationController presentViewController:picker animated:YES completion:NULL];
  }
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
  
  UIImage *image = info[UIImagePickerControllerOriginalImage];
  
  self.missionDidChange = YES;
  
//  image = [image imageCroppedWithRect:CGRectMake((self.imageViewHeader.frame.size.width - image.size.width) * 0.5f,
//                                                 (self.imageViewHeader.frame.size.height - image.size.height) * 0.5f,
//                                                 self.imageViewHeader.frame.size.width,
//                                                 self.imageViewHeader.frame.size.height)];
//  
  self.imageViewHeader.image = image;
  
  PFFile *imageFile = [PFFile fileWithName:@"cover.png" data:UIImageJPEGRepresentation(image, 0.5f)];
  
  self.mission[@"image"] = imageFile;
  
  [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
  
  [self hidePicker];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  
  [self.textFieldCaption resignFirstResponder];
  
  return YES;
}

- (void)didChangeText:(id)sender{
  
  self.missionDidChange = YES;
  
  self.mission[@"caption"] = self.textFieldCaption.text;
}

#pragma mark - UIPickerView Datasource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
  
  return kNumberOfAddMissionPickerViewComponents;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
  
  if (component == CEIAddMissionPickerViewComponentCounter) {
    
    if ([pickerView selectedRowInComponent:CEIAddMissionPickerViewComponentTime] == 0) {
      
      return kNumberOfRowsInPickerViewForComponent0;
    }
    else{
     
      return kNumberOfRowsInPickerViewForComponent1;
    }
  }
  else{
    
    return 2;
  }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
  
  if (component == CEIAddMissionPickerViewComponentCounter) {
    
    return [NSString stringWithFormat:@"%d",row+1];
  }
  else{
    
    if (row == 0) {
      
      return @"days";
    }
    else
      if (row == 1){
      
        return @"months";
      }
      else{
        
        return @"nope";
      }
  }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
  
  if (component == CEIAddMissionPickerViewComponentTime) {
    
    [pickerView reloadComponent:CEIAddMissionPickerViewComponentCounter];
  }
  
  NSString *counter = [self pickerView:self.pickerView
                        titleForRow:[self.pickerView selectedRowInComponent:CEIAddMissionPickerViewComponentCounter]
                       forComponent:CEIAddMissionPickerViewComponentCounter];
  
  NSString *time = [self pickerView:self.pickerView
                        titleForRow:[self.pickerView selectedRowInComponent:CEIAddMissionPickerViewComponentTime]
                       forComponent:CEIAddMissionPickerViewComponentTime];
  
  self.missionDidChange = YES;
  
  self.mission[@"timeCount"] = [NSString stringWithFormat:@"%@ %@",counter,time];
  [self.buttonEndsIn setTitle:self.mission[@"timeCount"] forState:UIControlStateNormal];
}

#pragma mark - Lazy Getters

- (UISwitch *)switchNeverEnding{
  
  if (_switchNeverEnding == nil) {
    
    _switchNeverEnding = [[UISwitch alloc] init];
    [_switchNeverEnding addTarget:self
                           action:@selector(tapSwitchNeverending:)
                 forControlEvents:UIControlEventValueChanged];
  }
  
  return _switchNeverEnding;
}

- (NSMutableArray *)arrayGoals{
  
  if (_arrayGoals == nil) {
    
    _arrayGoals = [[NSMutableArray alloc] init];
  }
  
  return _arrayGoals;
}

- (NSMutableArray *)arrayFlock{
  
  if (_arrayFlock == nil) {
    
    _arrayFlock = [[NSMutableArray alloc] init];
  }
  
  return _arrayFlock;
}

- (PFObject *)mission{
  
  if (_mission == nil) {
    
    _mission = [PFObject objectWithClassName:@"Mission"];
  }
  
  return _mission;
}

- (UIPickerView *)pickerView{
  
  if (_pickerView == nil) {
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 self.view.frame.size.height,
                                                                 self.view.frame.size.width,
                                                                 kHeightPickerView)];
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.layer.borderColor = [CEIColor colorBlue].CGColor;
    _pickerView.layer.borderWidth = 2.0f;
    [self.view addSubview:_pickerView];
  }
  
  return _pickerView;
}

- (CEITextField *)textFieldCaption{
  
  if (_textFieldCaption == nil) {
    
    _textFieldCaption = [[CEITextField alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width * 0.04f,
                                                                       kHeightDefaultCell * 0.1f,
                                                                       self.tableView.frame.size.width * 0.92f,
                                                                       kHeightDefaultCell * 0.8f)];
    _textFieldCaption.placeholder = @"Mission Title";
    [_textFieldCaption setBorderStyle:UITextBorderStyleRoundedRect];
    _textFieldCaption.delegate = self;
    [_textFieldCaption addTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
  }
 
  return _textFieldCaption;
}

- (CEIButtonCancel *)buttonEndsIn{
  
  if (_buttonEndsIn == nil) {

    _buttonEndsIn = [[CEIButtonCancel alloc] initWithFrame:CGRectMake(0.0f,
                                                               kHeightDefaultCell * 0.1f,
                                                               kWidthButtonEndsIs,
                                                               kHeightDefaultCell * 0.8f)];
      
    //[_buttonEndsIn setBackgroundImage:[UIImage imageNamed:@"btnBckgndSide"] forState:UIControlStateNormal];
    //[_buttonEndsIn setTitleColor:[CEIColor colorBlue] forState:UIControlStateNormal];
    if (!self.mission[@"timeCount"]) {
      
      self.mission[@"timeCount"] = @"30 days";
    }
    [_buttonEndsIn setTitle:self.mission[@"timeCount"] forState:UIControlStateNormal];
    [_buttonEndsIn addTarget:self action:@selector(showPicker) forControlEvents:UIControlEventTouchUpInside];
  }
  
  return _buttonEndsIn;
}

@end
