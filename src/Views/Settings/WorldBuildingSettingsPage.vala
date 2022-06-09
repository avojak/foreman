/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.Settings.WorldBuildingSettingsPage : Granite.SimpleSettingsPage {

    public const string NAME = "world-building";

    public WorldBuildingSettingsPage () {
        Object (
            header: null,
            icon_name: "applications-development",
            title: _("World Building"),
            description: _("Default world-building preferences for new servers"),
            activatable: false,
            expand: true
        );
    }

    construct {
        
    }

}
