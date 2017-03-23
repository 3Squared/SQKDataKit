//
//  SQKModelMigrator.m
//  Pods
//
//  Created by Sam Oakley on 05/11/2014.
//
//

#import "SQKModelMigrator.h"

NSString *const SQKDataKitMigrationErrorDomain = @"SQKDataKitMigrationErrorDomain";

@implementation SQKModelMigrator

+ (BOOL)iterativeMigrateURL:(NSURL *)sourceStoreURL
                            ofType:(NSString *)sourceStoreType
                           toModel:(NSManagedObjectModel *)finalModel
    orderedManagedObjectModelNames:(NSArray *)modelNames
                             error:(NSError **)error
{
    // If no model names are provided, return success immediately.
    if (modelNames == nil || modelNames.count < 2)
    {
        return YES;
    }
    
    // If the persistent store does not exist at the given URL, or is a type that isn't persisted to
    // disk, assume that it hasn't yet been created and return success immediately.
    if (![[NSFileManager defaultManager] fileExistsAtPath:[sourceStoreURL path]] || [sourceStoreType isEqualToString:NSInMemoryStoreType])
    {
        return YES;
    }

    // Get the persistent store's metadata.  The metadata is used to
    // get information about the store's managed object model.
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:sourceStoreType
                                                                                              URL:sourceStoreURL
                                                                                            error:error];
    if (!sourceMetadata)
    {
        return NO;
    }

    // Check whether the final model is already compatible with the store.
    // If it is, no migration is necessary.
    if ([finalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata])
    {
        return YES;
    }

    // Find the current model used by the store.
    NSManagedObjectModel *sourceModel = [self modelForStoreMetadata:sourceMetadata error:error];
    if (!sourceModel)
    {
        return NO;
    }

    // Get NSManagedObjectModels for each of the model names given.
    NSArray *models = [self modelsNamed:modelNames error:error];
    if (!models)
    {
        return NO;
    }

    // Build an inclusive list of models between the source and final models.
    NSMutableArray *relevantModels = [NSMutableArray array];
    BOOL firstFound = NO;
    BOOL lastFound = NO;
    BOOL reverse = NO;
    for (NSManagedObjectModel *model in models)
    {
        if ([model isEqual:sourceModel] || [model isEqual:finalModel])
        {
            if (firstFound)
            {
                lastFound = YES;
                // In case a reverse migration is being performed (descending through the
                // ordered array of models), check whether the source model is found
                // after the final model.
                reverse = [model isEqual:sourceModel];
            }
            else
            {
                firstFound = YES;
            }
        }

        if (firstFound)
        {
            [relevantModels addObject:model];
        }

        if (lastFound)
        {
            break;
        }
    }

    // Ensure that the source model is at the start of the list.
    if (reverse)
    {
        relevantModels = [[[relevantModels reverseObjectEnumerator] allObjects] mutableCopy];
    }

    // Migrate through the list
    for (int i = 0; i < ([relevantModels count] - 1); i++)
    {
        NSManagedObjectModel *modelA = [relevantModels objectAtIndex:i];
        NSManagedObjectModel *modelB = [relevantModels objectAtIndex:(i + 1)];

        // Check whether a custom mapping model exists.
        NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                                forSourceModel:modelA
                                                              destinationModel:modelB];

        // If there is no custom mapping model, try to infer one.
        if (!mappingModel)
        {
            mappingModel = [NSMappingModel inferredMappingModelForSourceModel:modelA
                                                             destinationModel:modelB
                                                                        error:error];
            if (!mappingModel)
            {
                return NO;
            }
        }

        if (![self migrateURL:sourceStoreURL
                       ofType:sourceStoreType
                    fromModel:modelA
                      toModel:modelB
                 mappingModel:mappingModel
                        error:error])
        {
            return NO;
        }
    }

    return YES;
}

+ (BOOL)migrateURL:(NSURL *)sourceStoreURL
            ofType:(NSString *)sourceStoreType
         fromModel:(NSManagedObjectModel *)sourceModel
           toModel:(NSManagedObjectModel *)targetModel
      mappingModel:(NSMappingModel *)mappingModel
             error:(NSError **)error
{
    // Build a temporary path to write the migrated store.
    NSURL *tempDestinationStoreURL = [NSURL fileURLWithPath:[[sourceStoreURL path] stringByAppendingPathExtension:@"_temp"]];

    // Migrate from the source model to the target model using the mapping,
    // and store the resulting data at the temporary path.
    NSMigrationManager *migrator = [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                                                  destinationModel:targetModel];

    if (![migrator migrateStoreFromURL:sourceStoreURL
                                  type:sourceStoreType
                               options:nil
                      withMappingModel:mappingModel
                      toDestinationURL:tempDestinationStoreURL
                       destinationType:sourceStoreType
                    destinationOptions:nil
                                 error:error])
    {
        return NO;
    }

    // Move the original source store to a backup location.
    NSString *backupPath = [[sourceStoreURL path] stringByAppendingPathExtension:@"_backup"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager moveItemAtPath:[sourceStoreURL path] toPath:backupPath error:error])
    {
        // If the move fails, delete the migrated destination store.
        [fileManager moveItemAtPath:[tempDestinationStoreURL path]
                             toPath:[sourceStoreURL path]
                              error:nil];
        return NO;
    }

    // Move the destination store to the original source location.
    if ([fileManager moveItemAtPath:[tempDestinationStoreURL path]
                             toPath:[sourceStoreURL path]
                              error:error])
    {
        // If the move succeeds, delete the backup of the original store.
        [fileManager removeItemAtPath:backupPath error:nil];
    }
    else
    {
        // If the move fails, restore the original store to its original location.
        [fileManager moveItemAtPath:backupPath toPath:[sourceStoreURL path] error:nil];
        return NO;
    }

    return YES;
}

+ (NSURL *)urlForModelName:(NSString *)modelName inDirectory:(NSString *)directory
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *url = [bundle URLForResource:modelName withExtension:@"mom" subdirectory:directory];
    if (nil == url)
    {
        // Get mom file paths from momd directories.
        NSArray *momdPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd" inDirectory:directory];
        for (NSString *momdPath in momdPaths)
        {
            url = [bundle URLForResource:modelName
                           withExtension:@"mom"
                            subdirectory:[momdPath lastPathComponent]];
        }
    }

    return url;
}

+ (NSArray *)modelsNamed:(NSArray *)modelNames error:(NSError **)error
{
    NSMutableArray *models = [NSMutableArray array];
    for (NSString *modelName in modelNames)
    {
        NSURL *modelUrl = [self urlForModelName:modelName inDirectory:nil];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];

        if (!model)
        {
            *error = [NSError errorWithDomain:SQKDataKitMigrationErrorDomain
                                         code:110
                                     userInfo:@{
                                         NSLocalizedDescriptionKey : [NSString stringWithFormat:@"No model found for %@ at URL %@", modelName, modelUrl]
                                     }];
            return nil;
        }

        [models addObject:model];
    }
    return models;
}

+ (NSManagedObjectModel *)modelForStoreMetadata:(NSDictionary *)metadata error:(NSError **)error
{
    NSManagedObjectModel *sourceModel =
        [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:metadata];
    if (!sourceModel)
    {
        *error = [NSError
            errorWithDomain:SQKDataKitMigrationErrorDomain
                       code:100
                   userInfo:@{
                       NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Failed to find source model for metadata: %@", metadata]
                   }];
    }

    return sourceModel;
}

@end
