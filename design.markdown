Design Considerations of a Text Layout Engine
=============================================

Glyph Generation
----------------

* private Core Graphics APIs like CGFontGetGlyphsForUnicodes() and CGFontGetGlyphAdvances()
* Key problems are Unicode, ligatures and OpenType layout features
* CJK are actually simpler -- but can we extend to support bidi languages?

Line Breaking
-------------

* simple algorithms
* complex algorithms like Knuth-Plass

Memory Footprint
----------------

For embedded devices like iPhone, reducing memory footprint when formatting a document is the main goal.

* Line by line, or, paragraph by paragraph (what about special rich text cases like quotation, verses)
* Real time efficiency: parallelize processing with multi-threading, GPGPU or GCD/Blocks?
    * The challenge is about making data independent of each other
    * We could make the processing at least twice as fast!
* Special hash table to store the result?

Rendering
---------

* By blocks?

Vertical Layout
---------------

* Core Text with flags
* Ruby

