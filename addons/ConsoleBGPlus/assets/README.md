# ConsoleBG+ textures

The 21 small PNG pieces embedded in `cbg_skin.lua` are unpacked here as `cbgplus_v4_*.png` on load. Existing matching files are reused; no image download or other addon is required.

The frame uses slices of XIVParty's `BgTop.png`, `BgMid.png`, and `BgBottom.png`, retaining their native stripe spacing and 64-pixel right fade. Top and bottom slices retain only the three silver rows; continuous fill and glow render beneath them. The middle slice is rotated by two rows to preserve the original body stripe phase when filling from the outer top. Generated pieces add the bottom glow, fading title endcaps, a compact grey input tab used only in native style, and an edit-only resize handle. Attribution and redistribution terms are in `../LICENSE.txt`.

The source images are from https://github.com/Tylas11/XivParty/tree/master/assets/ffxi. Regenerate the bundle with `tools/consolebgplus/build_skin.py` from the repository root; Pillow is a development dependency only. Old `cbgplus_v2_*.png` and `cbgplus_v3_*.png` files are unused by v0.1.7 and may remain when updating.
