/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public enum Foreman.Models.ServerAuthoritativeMovement {

    CLIENT_AUTH,
    SERVER_AUTH,
    SERVER_AUTH_WITH_REWIND;

    public string get_display_string () {
        switch (this) {
            case CLIENT_AUTH:
                return _("Client Auth");
            case SERVER_AUTH:
                return _("Server Auth");
            case SERVER_AUTH_WITH_REWIND:
                return _("Server Auth with Rewind");
            default:
                assert_not_reached ();
        }
    }

    public string get_short_name () {
        switch (this) {
            case CLIENT_AUTH:
                return "client-auth";
            case SERVER_AUTH:
                return "server-auth";
            case SERVER_AUTH_WITH_REWIND:
                return "server-auth-with-rewind";
            default:
                assert_not_reached ();
        }
    }

    public static ServerAuthoritativeMovement get_value_by_name (string name) {
        EnumClass enumc = (EnumClass) typeof (ServerAuthoritativeMovement).class_ref ();
        unowned EnumValue? eval = enumc.get_value_by_name (name);
        if (eval == null) {
            assert_not_reached ();
        }
        return (ServerAuthoritativeMovement) eval.value;
    }

    public static ServerAuthoritativeMovement get_value_by_short_name (string short_name) {
        switch (short_name) {
            case "client-auth":
                return CLIENT_AUTH;
            case "server-auth":
                return SERVER_AUTH;
            case "server-auth-with-rewind":
                return SERVER_AUTH_WITH_REWIND;
            default:
                assert_not_reached ();
        }
    }

}
