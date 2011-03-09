#import "Newsletter.h"
#import "ImageRepositoryClient.h"
#import "NewsletterSection.h"
#import "FeedItem.h"
#import "FeedFetcher.h"
#import "NewsletterItem.h"
#import "Font.h"

@implementation Newsletter 
@dynamic name,lastPublished,logoImageUrl,logoImage,sections,summary,displayOrder,image,isFavorite;//,clearOnPublish,maxSynopsisSize,templateName,headlineColor,sectionColor,commentColor;
@dynamic titleFont,commentsFont,sectionFont,headlineFont,bodyFont,summaryFont,dateFont;

+ (Newsletter*) createInContext:(NSManagedObjectContext*)moc
{
	Newsletter * newsletter = [NSEntityDescription insertNewObjectForEntityForName:@"Newsletter" inManagedObjectContext:moc];
	return newsletter;
}

- (int) itemCount
{
	return [self entityCount:@"NewsletterItem" predicate:[NSPredicate predicateWithFormat:@"section.newsletter==%@",self]];
}

- (void) save
{
	NSError * error=nil;
	if(![[self managedObjectContext] save:&error])
	{
		if(error)
		{
			NSLog(@"Error in Newsletter.save: %@",[error userInfo]);
		}
	}
}

- (void) delete	
{
	[[self managedObjectContext] deleteObject:self];
}

- (ItemFetcher*) feedFetcher
{
	// get section fetcher
	NewsletterSectionFetcher * feedFetcher=[[NewsletterSectionFetcher alloc] init];
	feedFetcher.newsletter=self;
	//feedFetcher.newsletterName=self.name;
	return [feedFetcher autorelease];
}

- (NSArray*) sortedSections
{
	return [[self feedFetcher] items];
}

- (BOOL) needsUploadImages
{
	// push images to server if not already pushed...
	if(self.logoImage)
	{
		if(self.logoImageUrl==nil)
		{
			return YES;
		}
	}

	for(NewsletterSection * section in [self.sections allObjects])
	{
		for(FeedItem * item in [section.items allObjects])
		{
			if(item.image)
			{
				if(item.imageUrl==nil)
				{
					return YES;
				}
			}
		}
	}
	
	return NO;
}

- (void) clearAllItems
{
	for(NewsletterSection * section in [self.sections allObjects])
	{
		for(NewsletterItem * item in [section.items allObjects])
		{
			[[item managedObjectContext] deleteObject:item];
		}
		[section save];
	}
}

- (NewsletterSection*) addSection
{
	NewsletterSection * newSection = [NSEntityDescription insertNewObjectForEntityForName:@"NewsletterSection" inManagedObjectContext:[self managedObjectContext]];
	
	newSection.newsletter=self;
	
	//int numSections=[self.sections count];
	
	int numSections=[self entityCount:@"NewsletterSection" predicate:[NSPredicate predicateWithFormat:@"(newsletter.name==%@)",self.name]];
	
	NSLog(@"adding section with displayOrder: %d",numSections);
	
	newSection.displayOrder=[NSNumber numberWithInt:numSections];
	
	return newSection;
}
- (int) entityCount:(NSString*)entityName predicate:(NSPredicate*)predicate
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSManagedObjectContext * moc=[self managedObjectContext];
	[request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
	
	[request setIncludesSubentities:NO];
	
	if(predicate!=nil)
	{
		[request setPredicate:predicate];
	}
	
	NSError *err;
	
	NSUInteger count = [moc countForFetchRequest:request error:&err];
	if(count == NSNotFound) {
		//Handle error
		count=0;
	}
	
	[request release];
	
	return count;
}

- (void) uploadImages
{
	// push images to server if not already pushed...
	if(self.logoImage)
	{
		if(self.logoImageUrl==nil)
		{
			// upload logo image
			self.logoImageUrl=[ImageRepositoryClient putImage:self.logoImage];
			NSError * error=nil;
			if(![[self managedObjectContext] save:&error])
			{
				if(error)
				{
					NSLog(@"Failed to save in Newsletter.uploadImages: %@",[error userInfo]);
				}
			}
		}
	}
	
	for(NewsletterSection * section in [self.sections allObjects])
	{
		for(FeedItem * item in [section.items allObjects])
		{
			if(item.image)
			{
				if(item.imageUrl==nil)
				{
					item.imageUrl=[ImageRepositoryClient putImage:item.image];
				}
			}
		}
		[section save];
	}
}

@end
