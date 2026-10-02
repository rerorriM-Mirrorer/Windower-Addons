# ConsoleBG+ textures

The 22 small PNG pieces embedded in `cbg_skin.lua` are unpacked here as `cbgplus_v3_*.png` on load. Existing matching files are reused; no image download or other addon is required.

The frame uses slices of XIVParty's `BgTop.png`, `BgMid.png`, and `BgBottom.png`, retaining their native stripe spacing and 64-pixel right fade. Generated pieces add the bottom glow, a title notch with fading endcaps, a compact grey input tab, and an edit-only resize handle. Attribution and redistribution terms are in `../LICENSE.txt`.

The source images are from https://github.com/Tylas11/XivParty/tree/master/assets/ffxi. Regenerate the bundle with `tools/consolebgplus/build_skin.py` from the repository root; Pillow is a development dependency only. Old `cbgplus_v2_*.png` files are unused by v0.1.2 and may remain when updating.
