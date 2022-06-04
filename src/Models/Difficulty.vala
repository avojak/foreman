/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public enum Foreman.Models.Difficulty {

    PEACEFUL,
    EASY,
    NORMAL,
    HARD;

    public string get_display_string () {
        switch (this) {
            case PEACEFUL:
                return _("Peaceful");
            case EASY:
                return _("Easy");
            case NORMAL:
                return _("Normal");
            case HARD:
                return _("Hard");
            default:
                assert_not_reached ();
        }
    }

    public string get_short_name () {
        switch (this) {
            case PEACEFUL:
                return _("PEACEFUL");
            case EASY:
                return _("EASY");
            case NORMAL:
                return _("NORMAL");
            case HARD:
                return _("HARD");
            default:
                assert_not_reached ();
        }
    }

    public static Difficulty get_value_by_name (string name) {
        EnumClass enumc = (EnumClass) typeof (Difficulty).class_ref ();
        unowned EnumValue? eval = enumc.get_value_by_name (name);
        if (eval == null) {
            assert_not_reached ();
        }
        return (Difficulty) eval.value;
    }

    public static Difficulty get_value_by_short_name (string short_name) {
        switch (short_name) {
            case "PEACEFUL":
                return PEACEFUL;
            case "EASY":
                return EASY;
            case "NORMAL":
                return NORMAL;
            case "HARD":
                return HARD;
            default:
                assert_not_reached ();
        }
    }

}
