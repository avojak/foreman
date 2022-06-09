/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.Settings.JavaRuntimeSettingsPage : Granite.SimpleSettingsPage {

    public const string NAME = "java";

    public JavaRuntimeSettingsPage () {
        Object (
            header: null,
            icon_name: Constants.APP_ID + ".java",
            title: _("Java"),
            description: _("Default Java preferences for new servers"),
            activatable: false,
            expand: true
        );
    }

    construct {
        
    }

}
