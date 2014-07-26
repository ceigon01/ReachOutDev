//
//  CEIPhonePrefixPickerViewController.m
//  ReachOut
//
//  Created by Jason Smith on 12.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIPhonePrefixPickerViewController.h"

static NSString *const kIdentifierCellPhonePrefix = @"kIdentifierCellPhonePrefix";

@interface CEIPhonePrefixPickerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayPhonePrefixes;
@property (nonatomic, strong) NSMutableDictionary *dictionaryPhonePrefixes;

@end

@implementation CEIPhonePrefixPickerViewController

- (void)viewDidLoad{
  [super viewDidLoad];

}

#pragma mark - UITableView Datasource & Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
  
  return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
  
  return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
  
  return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return [[UILocalizedIndexedCollation currentCollation] sectionTitles].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  NSString *letter = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
  
  NSArray *array = [self.dictionaryPhonePrefixes objectForKey:letter];
  
  return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellPhonePrefix
                                                          forIndexPath:indexPath];
  
  NSMutableArray *arrayCountries = [self.dictionaryPhonePrefixes objectForKey:[[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:indexPath.section]];
  
  NSDictionary *dictionary = [arrayCountries objectAtIndex:indexPath.row];
  
  cell.textLabel.text = [dictionary objectForKey:@"countryShort"];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"+ %@",[dictionary objectForKey:@"code"]];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  NSMutableArray *arrayCountries = [self.dictionaryPhonePrefixes objectForKey:[[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:indexPath.section]];
  
  self.dictionarySelected = [arrayCountries objectAtIndex:indexPath.row];
  
  [self.navigationItem.leftBarButtonItem.target performSelector:self.navigationItem.leftBarButtonItem.action];
}

#pragma mark - Convinience Methods

#warning TODO: come on, implement it properly later ;-)

- (NSMutableDictionary *)dictionaryPhonePrefixes{
  
  if (_dictionaryPhonePrefixes == nil) {
    
    _dictionaryPhonePrefixes = [NSMutableDictionary dictionary];

    [self.arrayPhonePrefixes enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
  
      NSString *firstLetter = [[dictionary objectForKey:@"countryShort"] substringToIndex:1];
      
      NSMutableArray *arrayCountriesForLetter = [_dictionaryPhonePrefixes valueForKey:firstLetter];
      if (arrayCountriesForLetter == nil) {
        
        arrayCountriesForLetter = [[NSMutableArray alloc] init];
        [_dictionaryPhonePrefixes setObject:arrayCountriesForLetter forKey:firstLetter];
      }
      
      [arrayCountriesForLetter addObject:dictionary];
    }];
  }
  
  return _dictionaryPhonePrefixes;
}

- (NSArray *)arrayPhonePrefixes{

#warning TODO: this should get done better
  
  if (_arrayPhonePrefixes == nil) {
    
    NSMutableArray *arrayCodes = [[NSMutableArray alloc] initWithObjects:
                                  [[NSDictionary alloc]initWithObjectsAndKeys:@"USA",@"countryShort",@"1",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"AFG",@"countryShort",@"93",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ALB",@"countryShort",@"355",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"DZA",@"countryShort",@"213",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ASM",@"countryShort",@"1684",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"AND",@"countryShort",@"376",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"AGO",@"countryShort",@"244",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"AIA",@"countryShort",@"1264",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ATA",@"countryShort",@"672",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ATG",@"countryShort",@"1268",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ARG",@"countryShort",@"54",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ARM",@"countryShort",@"374",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ABW",@"countryShort",@"297",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"AUS",@"countryShort",@"61",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"AUT",@"countryShort",@"43",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"AZE",@"countryShort",@"994",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BHS",@"countryShort",@"1242",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BHR",@"countryShort",@"973",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BGD",@"countryShort",@"880",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BRB",@"countryShort",@"1246",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BLR",@"countryShort",@"375",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BEL",@"countryShort",@"32",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BLZ",@"countryShort",@"501",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BEN",@"countryShort",@"229",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BMU",@"countryShort",@"1441",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BTN",@"countryShort",@"975",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BOL",@"countryShort",@"591",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BIH",@"countryShort",@"387",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BWA",@"countryShort",@"267",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BRA",@"countryShort",@"55",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"IOT",@"countryShort",@"246",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"VGB",@"countryShort",@"1284",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BRN",@"countryShort",@"673",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BGR",@"countryShort",@"359",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BFA",@"countryShort",@"226",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MMR",@"countryShort",@"95",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BDI",@"countryShort",@"257",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"KHM",@"countryShort",@"855",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CMR",@"countryShort",@"237",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CAN",@"countryShort",@"1",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CPV",@"countryShort",@"238",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CYM",@"countryShort",@"1345",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CAF",@"countryShort",@"236",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TCD",@"countryShort",@"235",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CHL",@"countryShort",@"56",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CHN",@"countryShort",@"86",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CXR",@"countryShort",@"61",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CCK",@"countryShort",@"61",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"COL",@"countryShort",@"57",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"COM",@"countryShort",@"269",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"COG",@"countryShort",@"242",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"COK",@"countryShort",@"682",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CR",@"countryShort",@"506",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"HRV",@"countryShort",@"385",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CUB",@"countryShort",@"53",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CYP",@"countryShort",@"357",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CZE",@"countryShort",@"420",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"COD",@"countryShort",@"243",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"DNK",@"countryShort",@"45",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"DJI",@"countryShort",@"253",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"DMA",@"countryShort",@"1767",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"DOM",@"countryShort",@"1809",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ECU",@"countryShort",@"593",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"EGY",@"countryShort",@"20",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SLV",@"countryShort",@"503",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GNQ",@"countryShort",@"240",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ERI",@"countryShort",@"291",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"EST",@"countryShort",@"372",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ETH",@"countryShort",@"251",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"FLK",@"countryShort",@"500",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"FRO",@"countryShort",@"298",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"FJI",@"countryShort",@"679",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"FIN",@"countryShort",@"358",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"FRA",@"countryShort",@"33",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PYF",@"countryShort",@"689",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GAB",@"countryShort",@"241",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GMB",@"countryShort",@"220",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GAZA",@"countryShort",@"970",@"code",@"Gaza Strip",@"countryLong",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GEO",@"countryShort",@"995",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"DEU",@"countryShort",@"49",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GHA",@"countryShort",@"233",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GIB",@"countryShort",@"350",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GRC",@"countryShort",@"30",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GRL",@"countryShort",@"299",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GRD",@"countryShort",@"1473",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GUM",@"countryShort",@"1671",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GTM",@"countryShort",@"502",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GIN",@"countryShort",@"224",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GNB",@"countryShort",@"245",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GUY",@"countryShort",@"592",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"HTI",@"countryShort",@"509",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"VAT",@"countryShort",@"39",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"HND",@"countryShort",@"504",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"HKG",@"countryShort",@"852",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"HUN",@"countryShort",@"36",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"IS",@"countryShort",@"354",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"IND",@"countryShort",@"91",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"IDN",@"countryShort",@"62",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"IRN",@"countryShort",@"98",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"IRQ",@"countryShort",@"964",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"IRL",@"countryShort",@"353",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"IMN",@"countryShort",@"44",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ISR",@"countryShort",@"972",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ITA",@"countryShort",@"39",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CIV",@"countryShort",@"225",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"JAM",@"countryShort",@"1 876",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"JPN",@"countryShort",@"81",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"JEY",@"countryShort",@"44",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"JOR",@"countryShort",@"962",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"KAZ",@"countryShort",@"7",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"KEN",@"countryShort",@"254",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"KIR",@"countryShort",@"686",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"KOS",@"countryShort",@"381",@"code",@"Kosovo",@"countryLong",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"KWT",@"countryShort",@"965",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"KGZ",@"countryShort",@"996",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LAO",@"countryShort",@"856",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LVA",@"countryShort",@"371",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LBN",@"countryShort",@"961",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LSO",@"countryShort",@"266",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LBR",@"countryShort",@"231",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LBY",@"countryShort",@"218",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LIE",@"countryShort",@"423",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LTU",@"countryShort",@"370",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LUX",@"countryShort",@"352",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MAC",@"countryShort",@"853",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MKD",@"countryShort",@"389",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MDG",@"countryShort",@"261",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MWI",@"countryShort",@"265",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MYS",@"countryShort",@"60",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MDV",@"countryShort",@"960",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MLI",@"countryShort",@"223",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MLT",@"countryShort",@"356",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MHL",@"countryShort",@"692",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MRT",@"countryShort",@"222",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MUS",@"countryShort",@"230",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MYT",@"countryShort",@"262",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MEX",@"countryShort",@"52",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"FSM",@"countryShort",@"691",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MDA",@"countryShort",@"373",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MCO",@"countryShort",@"377",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MNG",@"countryShort",@"976",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MNE",@"countryShort",@"382",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MSR",@"countryShort",@"1664",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MAR",@"countryShort",@"212",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MOZ",@"countryShort",@"258",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NAM",@"countryShort",@"264",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NRU",@"countryShort",@"674",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NPL",@"countryShort",@"977",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NLD",@"countryShort",@"31",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ANT",@"countryShort",@"599",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NCL",@"countryShort",@"687",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NZL",@"countryShort",@"64",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NIC",@"countryShort",@"505",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NER",@"countryShort",@"227",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NGA",@"countryShort",@"234",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NIU",@"countryShort",@"683",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NFK",@"countryShort",@"672",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PRK",@"countryShort",@"850",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MNP",@"countryShort",@"1670",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"NOR",@"countryShort",@"47",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"OMN",@"countryShort",@"968",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PAK",@"countryShort",@"92",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PLW",@"countryShort",@"680",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PAN",@"countryShort",@"507",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PNG",@"countryShort",@"675",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PRY",@"countryShort",@"595",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PER",@"countryShort",@"51",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PHL",@"countryShort",@"63",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PCN",@"countryShort",@"870",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"POL",@"countryShort",@"48",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PRT",@"countryShort",@"351",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"PRI",@"countryShort",@"1",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"QAT",@"countryShort",@"974",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ROU",@"countryShort",@"40",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"RUS",@"countryShort",@"7",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"RWA",@"countryShort",@"250",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"BLM",@"countryShort",@"590",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SHN",@"countryShort",@"290",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"KNA",@"countryShort",@"1869",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LCA",@"countryShort",@"1758",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"MAF",@"countryShort",@"1599",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SPM",@"countryShort",@"508",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"VCT",@"countryShort",@"1784",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"WSM",@"countryShort",@"685",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SMR",@"countryShort",@"378",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"STP",@"countryShort",@"239",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SAU",@"countryShort",@"966",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SEN",@"countryShort",@"221",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SRB",@"countryShort",@"381",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SYC",@"countryShort",@"248",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SLE",@"countryShort",@"232",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SGP",@"countryShort",@"65",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SVK",@"countryShort",@"421",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SVN",@"countryShort",@"386",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SLB",@"countryShort",@"677",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SOM",@"countryShort",@"252",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ZAF",@"countryShort",@"27",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"KOR",@"countryShort",@"82",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ESP",@"countryShort",@"34",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"LKA",@"countryShort",@"94",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SDN",@"countryShort",@"249",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SUR",@"countryShort",@"597",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SJM",@"countryShort",@"47",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SWZ",@"countryShort",@"268",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SWE",@"countryShort",@"46",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"CHE",@"countryShort",@"41",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"SYR",@"countryShort",@"963",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TWN",@"countryShort",@"886",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TJK",@"countryShort",@"992",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TZA",@"countryShort",@"255",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"THA",@"countryShort",@"66",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TLS",@"countryShort",@"670",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TGO",@"countryShort",@"228",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TKL",@"countryShort",@"690",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TON",@"countryShort",@"676",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TTO",@"countryShort",@"1868",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TUN",@"countryShort",@"216",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TUR",@"countryShort",@"90",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TKM",@"countryShort",@"993",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TCA",@"countryShort",@"1649",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"TUV",@"countryShort",@"688",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"UGA",@"countryShort",@"256",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"UKR",@"countryShort",@"380",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ARE",@"countryShort",@"971",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"GBR",@"countryShort",@"44",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"USA",@"countryShort",@"1",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"URY",@"countryShort",@"598",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"VIR",@"countryShort",@"1340",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"UZB",@"countryShort",@"998",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"VUT",@"countryShort",@"678",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"VEN",@"countryShort",@"58",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"VNM",@"countryShort",@"84",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"WLF",@"countryShort",@"681",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"WEST",@"countryShort",@"970",@"code",@"West Bank",@"countryLong",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ESH",@"countryShort",@"*",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"YEM",@"countryShort",@"967",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ZMB",@"countryShort",@"260",@"code",nil],
                          [[NSDictionary alloc]initWithObjectsAndKeys:@"ZWE",@"countryShort",@"263",@"code",nil],
                          nil];
    
    [arrayCodes sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dict1, NSDictionary *dict2) {
      
      NSString *code1 = [dict1 objectForKey:@"countryShort"];
      NSString *code2 = [dict2 objectForKey:@"countryShort"];
      
      return [code1 compare:code2];
    }];
    
    _arrayPhonePrefixes = [NSArray arrayWithArray:arrayCodes];
  }

  return _arrayPhonePrefixes;
}

@end
