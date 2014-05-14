// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OHMReminderLocation.h instead.

#import <CoreData/CoreData.h>
#import "OHMObject.h"

extern const struct OHMReminderLocationAttributes {
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *radius;
	__unsafe_unretained NSString *streetAddress;
} OHMReminderLocationAttributes;

extern const struct OHMReminderLocationRelationships {
	__unsafe_unretained NSString *reminder;
} OHMReminderLocationRelationships;

extern const struct OHMReminderLocationFetchedProperties {
} OHMReminderLocationFetchedProperties;

@class OHMReminder;







@interface OHMReminderLocationID : NSManagedObjectID {}
@end

@interface _OHMReminderLocation : OHMObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OHMReminderLocationID*)objectID;





@property (nonatomic, strong) NSNumber* latitude;



@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* radius;



@property float radiusValue;
- (float)radiusValue;
- (void)setRadiusValue:(float)value_;

//- (BOOL)validateRadius:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* streetAddress;



//- (BOOL)validateStreetAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *reminder;

- (NSMutableSet*)reminderSet;





@end

@interface _OHMReminderLocation (CoreDataGeneratedAccessors)

- (void)addReminder:(NSSet*)value_;
- (void)removeReminder:(NSSet*)value_;
- (void)addReminderObject:(OHMReminder*)value_;
- (void)removeReminderObject:(OHMReminder*)value_;

@end

@interface _OHMReminderLocation (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveRadius;
- (void)setPrimitiveRadius:(NSNumber*)value;

- (float)primitiveRadiusValue;
- (void)setPrimitiveRadiusValue:(float)value_;




- (NSString*)primitiveStreetAddress;
- (void)setPrimitiveStreetAddress:(NSString*)value;





- (NSMutableSet*)primitiveReminder;
- (void)setPrimitiveReminder:(NSMutableSet*)value;


@end