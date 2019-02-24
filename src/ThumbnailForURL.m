/*
 * Created 190219 lynnl
 */

#import <Foundation/Foundation.h>

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#include "utils.h"
#include "mandoc2html.h"

static OSStatus rawTextThumbnailForURL(
        void *thisInterface,
        QLThumbnailRequestRef thumbnail,
        CFURLRef url,
        CFStringRef contentTypeUTI,
        CFDictionaryRef options,
        CGSize maxSize)
{
    NSDictionary *previewProperties = nil;
    CFStringRef ext = CFURLCopyPathExtension(url);
    NSString *badge = [NSString stringWithFormat:@".%@", ext ? ext : CFSTR("")];
    NSDictionary *properties = @{
        (__bridge NSString *) kQLThumbnailPropertyExtensionKey : badge
    };

    CF_SAFE_RELEASE(ext);

    QLThumbnailRequestSetThumbnailWithURLRepresentation(
        thumbnail,
        url,
        kUTTypePlainText,
        (__bridge CFDictionaryRef) previewProperties,
        (__bridge CFDictionaryRef) properties
    );

    LOG("Thumbnail %@", url);

    return noErr;
}

static OSStatus htmlThumbnailForURL(
        void *thisInterface,
        QLThumbnailRequestRef thumbnail,
        CFURLRef url,
        CFStringRef contentTypeUTI,
        CFDictionaryRef options,
        CGSize maxSize)
{
    OSStatus e = noErr;
    NSDictionary *previewProperties = nil;
    CFStringRef ext = CFURLCopyPathExtension(url);
    NSString *badge = [NSString stringWithFormat:@".%@", ext ? ext : CFSTR("")];
    NSDictionary *properties = @{
        (__bridge NSString *) kQLThumbnailPropertyExtensionKey : badge
    };
    CFStringRef cfpath;
    const char *path;
    char *buffer = NULL;
    size_t size;
    CFDataRef cfdata;

    CF_SAFE_RELEASE(ext);

    cfpath = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    if (cfpath == NULL) {
        e = paramErr;
        LOG_ERR("CFURLCopyFileSystemPath() fail  url: %@", url);
        goto out_exit;
    }

    path = CFStringGetCStringPtr(cfpath, kCFStringEncodingUTF8);
    if (path == NULL) {
        LOG_ERR("CFStringGetCStringPtr() fail  path: %@", cfpath);
        e = paramErr;
        goto out_cfpath;
    }

    e = mandoc2html_buffer(path, &buffer, &size);
    if (e != 0) {
        LOG_ERR("mandoc2html_buffer() fail  path: %s err: %d", path, (int) e);
        e = kGeneralFailureErr;
        goto out_cfpath;
    }

    cfdata = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (UInt8 *) buffer, size, kCFAllocatorNull);
    if (cfdata == NULL) {
        e = kGeneralFailureErr;
        LOG_ERR("CFDataCreateWithBytesNoCopy() fail  path: %s", path);
        goto out_buffer;
    }

    QLThumbnailRequestSetThumbnailWithDataRepresentation(
        thumbnail,
        cfdata,
        kUTTypeHTML,
        (__bridge CFDictionaryRef) previewProperties,
        (__bridge CFDictionaryRef) properties
    );

    LOG("Thumbnail %s  html text size: %zu", path, size);

    CFRelease(cfdata);
out_buffer:
    free(buffer);
out_cfpath:
    CFRelease(cfpath);      /* XXX: cfpath & path both invalidated */
out_exit:
    return e;
}

/*
 * Generate a thumbnail for designated file as fast as possible
 */
OSStatus GenerateThumbnailForURL(
        void *thisInterface,
        QLThumbnailRequestRef thumbnail,
        CFURLRef url,
        CFStringRef contentTypeUTI,
        CFDictionaryRef options,
        CGSize maxSize)
{
    AUTORELEASEPOOL_BEGIN
    OSStatus e;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaults = [userDefaults persistentDomainForName:@"cn.junkman.quicklook.ManPageQL"];
    id isRaw = nil;

    if (defaults != nil) isRaw = [defaults valueForKey:@"RawTextForThumbnail"];

    if (isRaw != nil && [isRaw boolValue]) {
        e = rawTextThumbnailForURL(thisInterface, thumbnail, url, contentTypeUTI, options, maxSize);
    } else {
        e = htmlThumbnailForURL(thisInterface, thumbnail, url, contentTypeUTI, options, maxSize);
    }

    return e;
    AUTORELEASEPOOL_END
}

/*
 * Implement only if supported
 */
void CancelThumbnailGeneration(
        void *thisInterface,
        QLThumbnailRequestRef thumbnail)
{
    AUTORELEASEPOOL_BEGIN
    LOG_DBG("Thumbnail %p cancelled", thumbnail);
    AUTORELEASEPOOL_END
}

