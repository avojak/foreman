/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public enum Foreman.Models.WorldPreset {

    NORMAL,
    FLAT,
    LARGE_BIOMES,
    AMPLIFIED,
    SINGLE_BIOME_SURFACE;

    public string get_display_string () {
        switch (this) {
            case NORMAL:
                return _("Normal");
            case FLAT:
                return _("Flat");
            case LARGE_BIOMES:
                return _("Large Biomes");
            case AMPLIFIED:
                return _("Amplified");
            case SINGLE_BIOME_SURFACE:
                return _("Single Biome");
            default:
                assert_not_reached ();
        }
    }

    public string get_short_name () {
        switch (this) {
            case NORMAL:
                return _("normal");
            case FLAT:
                return _("flat");
            case LARGE_BIOMES:
                return _("large_biomes");
            case AMPLIFIED:
                return _("amplified");
            case SINGLE_BIOME_SURFACE:
                return _("single_biome_surface");
            default:
                assert_not_reached ();
        }
    }

    public static WorldPreset get_value_by_name (string name) {
        EnumClass enumc = (EnumClass) typeof (WorldPreset).class_ref ();
        unowned EnumValue? eval = enumc.get_value_by_name (name);
        if (eval == null) {
            assert_not_reached ();
        }
        return (WorldPreset) eval.value;
    }

    public static WorldPreset get_value_by_short_name (string short_name) {
        switch (short_name) {
            case "normal":
                return NORMAL;
            case "flat":
                return FLAT;
            case "large_biomes":
                return LARGE_BIOMES;
            case "amplified":
                return AMPLIFIED;
            case "single_biome_surface":
                return SINGLE_BIOME_SURFACE;
            default:
                assert_not_reached ();
        }
    }

}
