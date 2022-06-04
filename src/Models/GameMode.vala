/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public enum Foreman.Models.GameMode {

    SURVIVAL,
    CREATIVE,
    ADVENTURE,
    SPECTATOR;

    public string get_display_string () {
        switch (this) {
            case SURVIVAL:
                return _("Survival");
            case CREATIVE:
                return _("Creative");
            case ADVENTURE:
                return _("Adventure");
            case SPECTATOR:
                return _("Spectator");
            default:
                assert_not_reached ();
        }
    }

    public string get_short_name () {
        switch (this) {
            case SURVIVAL:
                return _("SURVIVAL");
            case CREATIVE:
                return _("CREATIVE");
            case ADVENTURE:
                return _("ADVENTURE");
            case SPECTATOR:
                return _("SPECTATOR");
            default:
                assert_not_reached ();
        }
    }

    public static GameMode get_value_by_name (string name) {
        EnumClass enumc = (EnumClass) typeof (GameMode).class_ref ();
        unowned EnumValue? eval = enumc.get_value_by_name (name);
        if (eval == null) {
            assert_not_reached ();
        }
        return (GameMode) eval.value;
    }

    public static GameMode get_value_by_short_name (string short_name) {
        switch (short_name) {
            case "SURVIVAL":
                return SURVIVAL;
            case "CREATIVE":
                return CREATIVE;
            case "ADVENTURE":
                return ADVENTURE;
            case "SPECTATOR":
                return SPECTATOR;
            default:
                assert_not_reached ();
        }
    }

}