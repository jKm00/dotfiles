#!/usr/bin/env bash
# oasis.nvim — "twilight" palette, mapped to SketchyBar 0xAARRGGBB colors.
# Source: uhs-robert/oasis.nvim (color_palettes/oasis_twilight.lua)

# Backgrounds (dark plum)
export BAR_COLOR=0xf01b1320   # base #1B1320, slightly translucent
export BG_CRUST=0xff150f1a    # #150F1A (darkest)
export BG_BASE=0xff1b1320     # #1B1320
export BG_MANTLE=0xff261a32   # #261A32
export BG_SURFACE=0xff362343  # #362343 (chip background)

# Foreground (cream)
export FG=0xfff5f5dc          # #F5F5DC
export FG_STRONG=0xfffffff0   # #FFFFF0
export FG_MUTED=0xff8b80aa    # #8B80AA
export FG_DIM=0xff71609a      # #71609A

# Accents
export CORAL=0xfff7997d       # #F7997D (primary)
export CORAL_STRONG=0xffe28e6f
export LAVENDER=0xffd2adff    # #D2ADFF
export LAVENDER_STRONG=0xff9c5feb
export KHAKI=0xfff0e68c       # #F0E68C
export GREEN=0xff7fcf78       # #7FCF78
export RED=0xffff7979         # #FF7979
export YELLOW=0xfff0e68c
export BLUE=0xff81c0ff        # #81C0FF
export CYAN=0xff69c3aa        # #69C3AA

# Semantic roles
export ACCENT=$CORAL              # focused / highlight
export ITEM_BG=$BG_SURFACE        # chip background
export TRANSPARENT=0x00000000
