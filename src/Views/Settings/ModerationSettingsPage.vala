/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.Settings.ModerationSettingsPage : Granite.SimpleSettingsPage {

    public const string NAME = "moderation";

    public ModerationSettingsPage () {
        Object (
            header: null,
            icon_name: "preferences-system-parental-controls",
            title: _("Moderation"),
            description: _("Default moderation preferences for new servers"),
            activatable: false,
            expand: true
        );
    }

    construct {

    }

}
