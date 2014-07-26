//
//  CEIAddUserViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 15.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddUserViewController.h"
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "CEIAlertView.h"
#import "CEICustomUserFoundViewController.h"
#import "CEIAddCustomUserViewController.h"

static NSString *const kIdentifierCellUsersFound = @"kIdentifierCellUsersFound";
static NSString *const kIdentifierSegueAddUserToAddCustomUser = @"kIdentifierSegueAddUserToAddCustomUser";
static NSString *const kIdentifierSegueAddUserToCustomUserFound = @"kIdentifierSegueAddUserToCustomUserFound";

@interface CEIAddUserViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayPhoneNumbers;
@property (nonatomic, strong) NSMutableArray *arrayUsersFound;
@property (nonatomic, strong) PFUser *userSelected;

@end

@implementation CEIAddUserViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();

#warning TODO: localizations
  if (status == kABAuthorizationStatusDenied){

    [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
    
    return;
  }
  
  CFErrorRef error = NULL;
  ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
  
  if (error){
    
    NSLog(@"error: %@", CFBridgingRelease(error));
    if (addressBook) CFRelease(addressBook);
    
    return;
  }
  
  if (status == kABAuthorizationStatusNotDetermined){
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
      
      if (granted){
        
        [self listPeopleInAddressBook:addressBook];
      }
      else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
          [[[UIAlertView alloc] initWithTitle:nil
                                      message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app."
                                     delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil]
           show];
        });
      }
      
      CFRelease(addressBook);
    });
    
  }
  else
    if (status == kABAuthorizationStatusAuthorized){
      
    [self listPeopleInAddressBook:addressBook];
  }
}

#pragma mark - UITableView Datasource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  return kHeightUserCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayUsersFound.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellUsersFound
                                                          forIndexPath:indexPath];
  
  PFUser *user = [self.arrayUsersFound objectAtIndex:indexPath.row];
  
  if (user[@"image"]) {
    
    PFFile *file = user[@"image"];
    
    __weak UITableViewCell *weakCell = cell;
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
      
      weakCell.imageView.image = [UIImage imageWithData:data];
      weakCell.imageView.layer.cornerRadius = weakCell.contentView.frame.size.height * 0.5f;
      weakCell.imageView.layer.masksToBounds = YES;
    }];
    
  }
  else{
    
    cell.imageView.image = [UIImage imageNamed:@"sheepPhoto"];
    cell.imageView.layer.cornerRadius = cell.contentView.frame.size.height * 0.5f;
    cell.imageView.layer.masksToBounds = YES;
  }
  
  cell.textLabel.text = user[@"fullName"];
  cell.detailTextLabel.text = user[@"title"];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  self.userSelected = [self.arrayUsersFound objectAtIndex:indexPath.row];
  [self performSegueWithIdentifier:kIdentifierSegueAddUserToCustomUserFound sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kIdentifierSegueAddUserToAddCustomUser]) {
    
    ((CEIAddCustomUserViewController *)segue.destinationViewController).isMentor = self.isMentor;
  }
  else
    if ([segue.identifier isEqualToString:kIdentifierSegueAddUserToCustomUserFound]) {
      
      ((CEICustomUserFoundViewController *)segue.destinationViewController).isMentor = self.isMentor;
      ((CEICustomUserFoundViewController *)segue.destinationViewController).user = self.userSelected;
    }
}

#pragma mark - Convinience Methods

- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook{
  
  NSInteger numberOfPeople = ABAddressBookGetPersonCount(addressBook);
  CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
  
  for (NSInteger i = 0; i < numberOfPeople; i++){
    
    ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);

//    NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
//    NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
    for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
      
      NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));

      phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                     componentsJoinedByString:@""];

      [self.arrayPhoneNumbers addObject:phoneNumber];
    }
    
    CFRelease(phoneNumbers);
  }
  
  CFRelease(allPeople);
  [self fetchUsers];
}

- (void)fetchUsers{
  
#warning TODO: localizations
  MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  progressHUD.labelText = @"Browsing your contacts...";
  
  __weak typeof (self) weakSelf = self;
  
  PFQuery *query = [PFUser query];
  if (query && [PFUser currentUser]) {
    
//    if (self.isMentor) {
//    
//      [query whereKey:@"mentors" equalTo:[PFUser currentUser]];
//    }
//    else{
//    
//      [query whereKey:@"followers" equalTo:[PFUser currentUser]];
//    }
    
    [query whereKey:@"mobileNumber" containedIn:self.arrayPhoneNumbers];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      [progressHUD hide:YES];
      
      if (objects.count == 0) {
        
        [[[UIAlertView alloc] initWithTitle:@"No users found!"
                                    message:@"None of your contacts are using ReachOut yet! Want to add someone else?"
                                   delegate:self
                          cancelButtonTitle:@"No"
                          otherButtonTitles:@"YES", nil]
         show];
      }
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else{
        
        weakSelf.arrayUsersFound = [NSMutableArray arrayWithArray:objects];
        [weakSelf.tableView reloadData];
      }
    }];
  }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  
  if (buttonIndex == alertView.cancelButtonIndex){
    
  }
  else{
   
    [self performSegueWithIdentifier:kIdentifierSegueAddUserToAddCustomUser sender:self];
  }
}

#pragma mark - Lazy Getters

- (NSMutableArray *)arrayUsersFound{
  
  if (_arrayUsersFound == nil) {
    
    _arrayUsersFound = [[NSMutableArray alloc] init];
  }
  
  return _arrayUsersFound;
}

- (NSMutableArray *)arrayPhoneNumbers{
  
  if (_arrayPhoneNumbers == nil) {
    
    _arrayPhoneNumbers = [[NSMutableArray alloc] init];
  }
  
  return _arrayPhoneNumbers;
}

@end