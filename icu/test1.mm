// test1.mm: test ICU layout engine

#import <AppKit/AppKit.h>
#include "CGFontInstance.h"
#include "layout/LETypes.h"
#include "layout/LEScripts.h"
#include "layout/LayoutEngine.h"

int main()
{
    CGFontRef cgFont = CGFontCreateWithFontName(CFSTR("Sabon LT Std"));
    CGFloat scaleFactor = [[NSScreen mainScreen] userSpaceScaleFactor];
    LEErrorCode status = LE_NO_ERROR;
    LayoutEngine *engine;
    LEFontInstance *font = new CGFontInstance(cgFont, scaleFactor, 12.0, status);
    CFStringRef str = CFSTR("ff fi fl");
    le_int32 i, count = CFStringGetLength(str), glyphCount;
    LEUnicode *chars = new LEUnicode[count];
    LEGlyphID *glyphs;
    float *positions;

    CFStringGetCharacters(str, CFRangeMake(0, count), chars);

    if (LE_FAILURE(status))
        goto cleanup1;

    engine = LayoutEngine::layoutEngineFactory(font, latnScriptCode, -1, status);
    if (LE_FAILURE(status))
        goto cleanup2;

    glyphCount = engine->layoutChars(chars, 0, count, count, FALSE, 10, 10, status);
    printf("glyphCount = %d, status = %d\n", glyphCount, status);
    if (LE_FAILURE(status))
        goto cleanup2;

    glyphs = new LEGlyphID[glyphCount];
    engine->getGlyphs(glyphs, status);
    if (LE_FAILURE(status))
        goto cleanup3;

    positions = new float[glyphCount * 2 + 2];
    engine->getGlyphPositions((float *) positions, status);
    if (LE_FAILURE(status))
        goto cleanup4;

    for (i = 0; i < glyphCount; i++)
        printf("%d (%g) ", glyphs[i], positions[i * 2]);

    printf("\n");


cleanup4:
    delete [] positions;
cleanup3:
    delete [] glyphs;
cleanup2:
    delete engine;
cleanup1:
    delete font;
    CFRelease(cgFont);
    delete [] chars;
    return 0;
}

