#import <libactivator/libactivator.h>

@interface TUCallCenter : NSObject
+ (id)sharedInstance;
- (void)
answerCall:(id)arg1;
@end

@interface TUCall : NSObject <NSSecureCoding>
@property(nonatomic, readonly) int status;
@property(nonatomic, readonly, copy) NSString *destinationID;
@end

#define LASendEventWithName(eventName) [LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]]]

static NSString *kCallAnswer_eventName = @"CallAnswerEvent";

///////////////////////////////////////////////////////////////////////////////////////
//
//
@interface CallAnswerDataSource : NSObject <LAEventDataSource> {}
+ (id)sharedInstance;
@end

@implementation CallAnswerDataSource
+ (id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}

+ (void)load {
	[self sharedInstance];
}

- (id)init {
	if ((self = [super init])) {
		[LASharedActivator registerEventDataSource:self forEventName:kCallAnswer_eventName];
	}
	return self;
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	return @"Call Auto Answer";
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
	return @"Call Events";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	return @"Call Auto Answer";
}

- (void)dealloc {
	[LASharedActivator unregisterEventDataSourceWithEventName:kCallAnswer_eventName];
	[super dealloc];
}
@end

///////////////////////////////////////////////////////////////////////////////////////
//
//
%hook TUCallCenter
- (void)handleCallStatusChanged:(id)call userInfo:(id)info
{
	%orig;

	if ([call isKindOfClass:%c(TUCall)]) {
		// 1 = connected, 3 = initiate outgoing, 4 = initiate incoming
		if ([call status] == 4) {
			NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/net.tateu.callansweractivate.plist"];
			if (!settings) {
				return;
			}

			for (NSDictionary *numberDictionary in [settings objectForKey:@"numbers"]) {
				BOOL enabled =  [numberDictionary objectForKey:@"enabled"] ? [[numberDictionary objectForKey:@"enabled"] boolValue] : YES;
				if (!enabled) {
					continue;
				}
				NSString *number = [numberDictionary objectForKey:@"number"] ? : @"aaaaaaaaaa";
				float answerDelay = [numberDictionary objectForKey:@"answerDelay"] ? [[numberDictionary objectForKey:@"answerDelay"] floatValue] : 0.0;
				float eventDelay = [numberDictionary objectForKey:@"eventDelay"] ? [[numberDictionary objectForKey:@"eventDelay"] floatValue] : 0.0;

				if ((![call destinationID] && [[number lowercaseString] isEqualToString:@"blocked"]) || ([call destinationID] && [[call destinationID] rangeOfString:number].location != NSNotFound)) {
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, answerDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
						[self answerCall:call];

						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, eventDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
							LASendEventWithName(kCallAnswer_eventName);
						});
					});
					break;
				}
			}
		}
	}
}
%end

%ctor {
	@autoreleasepool {
		%init;
	};
}
