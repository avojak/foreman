/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public enum Foreman.Models.ColorPalette {

    COLOR_STRAWBERRY,
    COLOR_BANANA;
    //  COLOR_ORANGE,
    //  COLOR_LIME,
    //  COLOR_BLUEBERRY;

    public string get_value () {
        // Colors defined by the elementary OS Human Interface Guidelines
        switch (this) {
            case COLOR_STRAWBERRY:
                return "#ed5353";
            case COLOR_BANANA:
                return "#ffe16b";
            //  case COLOR_ORANGE:
            //      return prefer_dark_style ? "#ffa154" : "#cc3b02";
            //  case COLOR_LIME:
            //      return prefer_dark_style ? "#9bdb4d" : "#3a9104";
            //  case COLOR_BLUEBERRY:
            //      return prefer_dark_style ? "#64baff" : "#3689e6";
            default:
                assert_not_reached ();
        }
    }

}
