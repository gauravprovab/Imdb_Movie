//
//  KTImageView.m
//  UniversalImageView
//
//  Created by Ashish Sharma on 05/06/15.
//  Copyright (c) 2015 KT. All rights reserved.
//

#import "KTImageView.h"


@interface KTImageView ()
{
    __block UIActivityIndicatorView *indicator;
}

- (NSString *) cacheDirPath;

@end

@implementation KTImageView

#pragma mark - Instance Methods (Public)

- (void) showImageWithBundleFilePath:(NSString*) imagePath{
    
    if (imagePath == nil){
        
        NSLog(@"#WARNING - imagePath is nil, \n%s",__PRETTY_FUNCTION__);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        
        if (imageData){
            
            UIImage *image = [UIImage imageWithData:imageData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
                
                if (indicator){
                    [indicator removeFromSuperview];
                    indicator = nil;
                }
            });
        }
    });
}

- (void) setImageWithURL:(NSURL*) url showIndicator:(BOOL) show{
    if (url == nil){
        NSLog(@"#WARNING - URL is nil, \n%s",__PRETTY_FUNCTION__);
        return;
    }
    
    
    
    NSString *urlString = [url absoluteString];
    
    NSString *lastPathComponent = [urlString lastPathComponent];
    
    NSArray *components = [lastPathComponent componentsSeparatedByString:@"&"];
    
    NSString *imagePath = [[self cacheDirPath] stringByAppendingPathComponent:[components objectAtIndex:0]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
        
        [self showImageWithBundleFilePath:imagePath];
        
    }else{
        
        if (show){
            
            indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            CGRect indicatorRect = indicator.frame;
            
//            NSLog(@"FRmae =============%@",NSStringFromCGRect(self.frame));
            
//            indicatorRect.origin.x = self.frame.size.width/2.f-indicator.frame.size.width/2.f;\
            
            float w = self.frame.size.width;
            
//            NSLog(@"w=============%f",w);

            
            indicatorRect.origin.x = w/2.f-indicator.frame.size.width/2.f;

            indicatorRect.origin.y = self.frame.size.height/2.f-indicator.frame.size.height/2.f;
//            indicator.frame = indicatorRect;
//            indicator.center= CGPointMake(self.frame.size.width/2.f,self.frame.size.height/2.f);
            
            indicator.center= CGPointMake(w/2.f,self.frame.size.height/2.f);

            [self addSubview:indicator];
            
            [indicator startAnimating];
        }
        
        NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:urlSessionConfig];
        
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
            NSError *err;
            if (location != nil) {
                if (![[NSFileManager defaultManager] moveItemAtPath:location.path toPath:imagePath error:&err]){
                    
                    NSLog(@"%@",[err localizedDescription]);
                    
                }else{
                    
                    [self showImageWithBundleFilePath:imagePath];
                }
            }
        }];
        
        [downloadTask resume];
    }
    
}

#pragma mark - Instance Methods (Private)

- (NSString *) cacheDirPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    return cachePath;
}

@end
