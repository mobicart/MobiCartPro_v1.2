//
//  Database.m
//  Mobicart
//
//  Created by Mobicart on 24/06/08.
//  Copyright 2008 Mobicart. All rights reserved.
//

#import "Sql_Database.h"

@interface Sql_Database (Private)
- (void)createDatabaseIfNeeded;
@end

@implementation Sql_Database

- (id)init 
{	
	[self loadDb];
	return self;
}

// Intiates a connection with the sqlite database, which is used till the application is active.
- (void)loadDb 
{
	[self createDatabaseIfNeeded];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingFormat:@"/DBMobicart.sqlite3"];
	
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) 
	{
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
		DLog(@"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

// Checks if database is not present in the aaplication installed and creates it if not present.
- (void)createDatabaseIfNeeded 
{
	// Workaround for Beta issue where Documents directory is not created during install.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingFormat:@"/DBMobicart.sqlite3"];
	BOOL exists = [fileManager fileExistsAtPath:path];
    if (!exists) 
	{
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"DBMobicart.sqlite3"];    
		BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:path error:nil];    
		if (!success) 	
		{
		}		
    }
}

- (void)dealloc 
{
    // Close the database.
    
    if (sqlite3_close(database) != SQLITE_OK) 
	{
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
	[super dealloc];
}

@end

