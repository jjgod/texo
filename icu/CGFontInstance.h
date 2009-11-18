// CGFontInstance.h

#ifndef __CGFONTINSTANCE_H
#define __CGFONTINSTANCE_H

#include <ApplicationServices/ApplicationServices.h>
#include <layout/LEFontInstance.h>
#include <layout/LayoutEngine.h>
#include "FontTableCache.h"
#include "cmaps.h"

class CGFontInstance : public LEFontInstance, protected FontTableCache
{
protected:
    CGFontRef cgFont;
    CGFloat   fScaleFactor, fPointSize, fUnitsPerEM;
    CMAPMapper *fMapper;
    virtual const void *readFontTable(LETag tableTag) const;
    virtual LEErrorCode initMapper();

public:
    CGFontInstance(CGFontRef font, CGFloat scaleFactor, CGFloat pointSize, LEErrorCode &status);
    virtual ~CGFontInstance();

    virtual const void *getFontTable(LETag tableTag) const;

    virtual LEGlyphID mapCharToGlyph(LEUnicode32 ch) const;
    virtual void getGlyphAdvance(LEGlyphID glyph, LEPoint &advance) const;
    virtual le_bool getGlyphPoint(LEGlyphID glyph, le_int32 pointNumber, LEPoint &point) const;

    virtual le_int32 getUnitsPerEM() const;
    virtual le_int32 getAscent() const;
    virtual le_int32 getDescent() const;
    virtual le_int32 getLeading() const;

    float getXPixelsPerEm() const;
    float getYPixelsPerEm() const;
    float getScaleFactorX() const;
    float getScaleFactorY() const;
};

#endif

