// first obj-c program.

#import <Cocoa/Cocoa.h>
#include <stdlib.h>
#include "CGFontInstance.h"
#include "layout/LETypes.h"
#include "layout/LEScripts.h"
#include "layout/LayoutEngine.h"

#define MAX_GLYPHS_COUNT 1024

static int createWindow(int width, int height);

@interface TestView: NSView {
    CGFontRef cgFont;
    CGGlyph glyphs[MAX_GLYPHS_COUNT];
    CGPoint positions[MAX_GLYPHS_COUNT];
    size_t glyphCount;
    LayoutEngine *engine;
};

@end

@implementation TestView

CGFontRef CGContextGetFont(CGContextRef);
int CGFontGetUnitsPerEm(CGFontRef);
float CGContextGetFontSize(CGContextRef);

- (BOOL) layoutString: (NSString *) str
{
    NSWindow *window = [NSApp keyWindow];

    cgFont = CGFontCreateWithFontName(CFSTR("Sabon LT Std"));
    CGFloat scaleFactor = [window userSpaceScaleFactor];
    LEErrorCode status = LE_NO_ERROR;
    LEFontInstance *font = new CGFontInstance(cgFont, scaleFactor, 32.0, status);
    NSUInteger i, count = [str length];
    LEUnicode *chars = new LEUnicode[count];
    LEGlyphID *leGlyphs;
    float *lePositions;

    [str getCharacters: chars range: NSMakeRange(0, count)];

    if (LE_FAILURE(status))
        goto cleanup1;

    engine = LayoutEngine::layoutEngineFactory(font, latnScriptCode, -1, status);
    if (LE_FAILURE(status))
        goto cleanup2;

    glyphCount = engine->layoutChars(chars, 0, count, count, FALSE, 100, 100, status);
    printf("glyphCount = %lu, status = %d\n", glyphCount, status);
    if (LE_FAILURE(status))
        goto cleanup2;

    leGlyphs = new LEGlyphID[glyphCount];
    engine->getGlyphs(leGlyphs, status);
    if (LE_FAILURE(status))
        goto cleanup3;

    lePositions = new float[glyphCount * 2 + 2];
    engine->getGlyphPositions(lePositions, status);
    if (LE_FAILURE(status))
        goto cleanup4;

    for (i = 0; i < glyphCount; i++)
    {
        printf("%d, (%g, %g)\n", leGlyphs[i], lePositions[i * 2], lePositions[i * 2 + 1]);
        glyphs[i] = leGlyphs[i];
        positions[i].x = lePositions[i * 2];
        positions[i].y = lePositions[i * 2 + 1];
    }

    engine->reset();

cleanup4:
    delete [] lePositions;
cleanup3:
    delete [] leGlyphs;
cleanup2:
    delete engine;
cleanup1:
    delete font;
    delete [] chars;

    return LE_FAILURE(status) ? NO : YES;
}

- (void) drawRect:(NSRect)rect
{
    if ([self layoutString: @"fi ff fl"] == NO)
        return;

    CGContextRef aContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    /* Set up the context. */
    CGContextSaveGState(aContext);

    CGContextSetRGBFillColor(aContext, 0.0, 0.0, 0.0, 1.0);
    CGContextSetFont(aContext, cgFont);
    CGContextSetFontSize(aContext, 32.0);

    CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
    CGContextSetTextMatrix(aContext, transform);
    CGContextSetTextPosition(aContext, 100, 100);
	/* Finally - display glyphs centered in status area. */
	CGContextShowGlyphsAtPositions(aContext, glyphs, positions, glyphCount);
    // CGContextShowGlyphs(aContext, glyphs, glyphCount);

	/* Restore the context and free our buffers. */
	CGContextRestoreGState(aContext);
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end

static int createWindow(int width, int height)
{
    NSWindow *window;
    TestView *view;

    NSRect contentRect;
    unsigned int style;

    contentRect = NSMakeRect(0, 0, width, height);
    style = NSTitledWindowMask | 
    NSMiniaturizableWindowMask | 
          NSClosableWindowMask | 
         NSResizableWindowMask;

    window = [[NSWindow alloc] initWithContentRect: contentRect 
                                         styleMask: style
                                           backing: NSBackingStoreBuffered 
                                             defer: NO];
    [window center];
    [window setTitle: @"Test App"];
    [window makeKeyAndOrderFront: nil];
    
    view = [[TestView alloc] initWithFrame: contentRect];
    [[window contentView] addSubview: view];
    [view release];

    return 1;
}

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool;
    
    pool = [NSAutoreleasePool new];

    [NSApplication sharedApplication];
    createWindow(800, 600);    

    [pool release];
    /* Start the main event loop */
    [NSApp run];

    return 0;
}

