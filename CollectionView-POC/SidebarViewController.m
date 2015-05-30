//
//  SidebarViewController.m
//  SidebarDemo
//
//  Created by Simon on 29/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "SidebarViewController.h"
#import "Constants.h"

@interface SidebarViewController()
@property (strong, nonatomic) NSArray *headerItems;
@property (strong, nonatomic) NSArray *sortedHeaderItems;
@property (strong, nonatomic) NSDictionary *menuDictionary;
@end

@implementation SidebarViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"SidebarViewController.viewDidLoad...");
    
    self.menuDictionary = @{ BLANK    : @[SELECT_INGREDIENTS],
                             ESPRESSO : @[SINGLE_SHOT, DOUBLE_SHOT, ONE_THIRD],
                             MILK     : @[STEAMED_MILK, MILK_FOAM],
                             SYRUP    : @[WHITE_CHOCOLATE, CARAMEL, VANILLA, HAZELNUT, MOCHA, CHOCOLATE, PEPPERMINT]};
    
    self.headerItems = [self.menuDictionary allKeys]; // keys from the dictionary will be ingredient headers
    //NSLog(@"Displaying the Menu Items: %@", self.menuDictionary);
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:BLANK ascending:YES];
    self.headerItems = [self.headerItems sortedArrayUsingDescriptors:@[sortDescriptor]];
    for (NSString *key in self.headerItems) {
        NSLog(@"sorted key: %@", key);
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //return 1;
    return [self.headerItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return 10;
    /*__block NSUInteger numberOfRows = 0;
    
    [self.menuDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //NSLog(@"%@ = %@", key, obj);
        NSLog(@"Array count for key: %lu", (unsigned long)[[self.menuDictionary objectForKey:key] count]);
        numberOfRows += [[self.menuDictionary objectForKey:key] count];
    }];
    
    numberOfRows += [[self.menuDictionary allKeys] count];
    
    NSLog(@"numberOfRows: %lu", (unsigned long)numberOfRows);
    return numberOfRows;*/
    
    NSString *sectionHeader = [self.headerItems objectAtIndex:section];
    NSArray *sectionIngredients = [self.menuDictionary objectForKey:sectionHeader];
    return [sectionIngredients count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [self.headerItems objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIFont *cellFontSize = [UIFont systemFontOfSize:14.0];
    
    /*if (indexPath.row == 0) { // shade the first row and do not use for ingredients list
        //cell.backgroundColor = [UIColor lightGrayColor];
        cell.contentView.userInteractionEnabled = NO;
    } else if (indexPath.row == 1) { // instructional heading
        cell.textLabel.font = cellFontSize;
        cell.textLabel.text = @"Select Drink Ingredients";
        cell.contentView.userInteractionEnabled = NO;
    } else {
        cell.textLabel.font = cellFontSize;
        cell.textLabel.text = [NSString stringWithFormat:@"Row %ld", (long)indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"Right4-12.png"];
    }*/
    

    NSString *sectionTitle = [self.headerItems objectAtIndex:indexPath.section];
    NSArray *ingredientsForSection = self.menuDictionary[sectionTitle];
    NSString *ingredient = ingredientsForSection[indexPath.row];
    cell.textLabel.font = cellFontSize;
    cell.textLabel.text = ingredient;
    // don't show arrow image for this header item
    if (![ingredient isEqualToString:SELECT_INGREDIENTS]) {
        cell.imageView.image = [UIImage imageNamed:@"Right4-12.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    //NSLog(@"Selected row is %ld", (long)indexPath.row);
    if (!(indexPath.section == 0 && indexPath.row == 0))
        selectedCell.imageView.image = [UIImage imageNamed:@"Down4-12.png"];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (!(indexPath.section == 0 && indexPath.row == 0))
        selectedCell.imageView.image = [UIImage imageNamed:@"Right4-12.png"];
}

@end
