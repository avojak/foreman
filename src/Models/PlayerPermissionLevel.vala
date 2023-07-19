/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public enum Foreman.Models.PlayerPermissionLevel {

    VISITOR,
    MEMBER,
    OPERATOR;

    public string get_display_string () {
        switch (this) {
            case VISITOR:
                return _("Visitor");
            case MEMBER:
                return _("Member");
            case OPERATOR:
                return _("Operator");
            default:
                assert_not_reached ();
        }
    }

    public string get_short_name () {
        switch (this) {
            case VISITOR:
                return _("visitor");
            case MEMBER:
                return _("member");
            case OPERATOR:
                return _("operator");
            default:
                assert_not_reached ();
        }
    }

    public static PlayerPermissionLevel get_value_by_name (string name) {
        EnumClass enumc = (EnumClass) typeof (PlayerPermissionLevel).class_ref ();
        unowned EnumValue? eval = enumc.get_value_by_name (name);
        if (eval == null) {
            assert_not_reached ();
        }
        return (PlayerPermissionLevel) eval.value;
    }

    public static PlayerPermissionLevel get_value_by_short_name (string short_name) {
        switch (short_name) {
            case "visitor":
                return VISITOR;
            case "member":
                return MEMBER;
            case "operator":
                return OPERATOR;
            default:
                assert_not_reached ();
        }
    }

}
