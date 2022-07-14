/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public enum Foreman.Models.ServerType {

    JAVA_EDITION,
    BEDROCK;

    public string get_display_string () {
        switch (this) {
            case JAVA_EDITION:
                return _("Java Edition");
            case BEDROCK:
                return _("Bedrock");
            default:
                assert_not_reached ();
        }
    }

}
