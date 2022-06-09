/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.Settings.NetworkSettingsPage : Granite.SimpleSettingsPage {

    public const string NAME = "network";

    public NetworkSettingsPage () {
        Object (
            header: null,
            icon_name: "preferences-system-network",
            title: _("Network"),
            description: _("Default networking preferences for new servers"),
            activatable: false,
            expand: true
        );
    }

    construct {
        
    }

}
