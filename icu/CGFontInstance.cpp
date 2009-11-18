// CGFontInstance.cpp

#include <ApplicationServices/ApplicationServices.h>
#include <layout/LETypes.h>
#include "CGFontInstance.h"

CGFontInstance::CGFontInstance(CGFontRef font, CGFloat scaleFactor,
                               CGFloat pointSize, LEErrorCode &status)
    : fScaleFactor(scaleFactor), fPointSize(pointSize)
{
    if (! font)
    {
        status = LE_ILLEGAL_ARGUMENT_ERROR;
        return;
    }

    cgFont = font;
    CFRetain(cgFont);

    fUnitsPerEM = CGFontGetUnitsPerEm(cgFont);

    status = initMapper();
}

CGFontInstance::~CGFontInstance()
{
    if (cgFont)
        CFRelease(cgFont);
}

LEErrorCode CGFontInstance::initMapper()
{
    LETag cmapTag = LE_CMAP_TABLE_TAG;
    const CMAPTable *cmap = (const CMAPTable *) readFontTable(cmapTag);

    if (cmap == NULL) {
        return LE_MISSING_FONT_TABLE_ERROR;
    }

    fMapper = CMAPMapper::createUnicodeMapper(cmap);

    if (fMapper == NULL) {
        return LE_MISSING_FONT_TABLE_ERROR;
    }

    return LE_NO_ERROR;
}

const void *CGFontInstance::readFontTable(LETag tableTag) const
{
    UInt8 *result = NULL;
    CFDataRef table = CGFontCopyTableForTag(cgFont, tableTag);

    fprintf(stderr, "Getting table for tag: '%c%c%c%c' = %p\n",
            tableTag >> 24, tableTag >> 16 & 0xFF, tableTag >> 8 & 0xFF, tableTag & 0xFF,
            table);

    if (! table)
        return NULL;

    CFIndex length = CFDataGetLength(table);

    if (length > 0) {
        result = (UInt8 *) malloc(length * sizeof(UInt8));
        CFDataGetBytes(table, CFRangeMake(0, length), result);
    }

    CFRelease(table);
    return result;
}

const void *CGFontInstance::getFontTable(LETag tableTag) const
{
    return FontTableCache::find(tableTag);
}

le_int32 CGFontInstance::getUnitsPerEM() const
{
    return fUnitsPerEM;
}

le_int32 CGFontInstance::getAscent() const
{
    return CGFontGetAscent(cgFont);
}

le_int32 CGFontInstance::getDescent() const
{
    return CGFontGetDescent(cgFont);
}

le_int32 CGFontInstance::getLeading() const
{
    return CGFontGetLeading(cgFont);
}

float CGFontInstance::getXPixelsPerEm() const
{
    return fPointSize;
}

float CGFontInstance::getYPixelsPerEm() const
{
    return fPointSize;
}

float CGFontInstance::getScaleFactorX() const
{
    return fScaleFactor;
}

float CGFontInstance::getScaleFactorY() const
{
    return fScaleFactor;
}

le_bool CGFontInstance::getGlyphPoint(LEGlyphID glyph, le_int32 pointNumber, LEPoint &point) const
{
    // Not supported (yet)
    return FALSE;
}

LEGlyphID CGFontInstance::mapCharToGlyph(LEUnicode32 ch) const
{
    return fMapper->unicodeToGlyph(ch);
}

void CGFontInstance::getGlyphAdvance(LEGlyphID glyph, LEPoint &advance) const
{
    CGGlyph glyphs[1];
    int advances[1];

    advance.fX = 0;
    advance.fY = 0;

    glyphs[0] = glyph;
    if (CGFontGetGlyphAdvances(cgFont, glyphs, 1, advances))
        advance.fX = advances[0] * fPointSize / fUnitsPerEM;
}

