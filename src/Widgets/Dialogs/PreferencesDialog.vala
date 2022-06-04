/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Widgets.Dialogs.PreferencesDialog : Granite.Dialog {

    public PreferencesDialog (Foreman.Windows.MainWindow main_window) {
        Object (
            title: _("%s Preferences").printf (Constants.APP_NAME),
            deletable: true,
            resizable: false,
            transient_for: main_window,
            modal: false
        );
    }

    construct {
        var stack_grid = new Gtk.Grid () {
            expand = true,
            height_request = 500,
            width_request = 500
        };

        var stack_switcher = new Gtk.StackSwitcher () {
            halign = Gtk.Align.CENTER
        };
        stack_grid.attach (stack_switcher, 0, 0, 1, 1);

        var stack = new Gtk.Stack () {
            expand = true
        };
        stack_switcher.stack = stack;

        stack.add_titled (new Foreman.Views.Settings.GameplaySettingsView (), "gameplay", _("Gameplay"));
        stack.add_titled (new Foreman.Views.Settings.WorldBuildingSettingsView (), "worldbuilding", _("World Building"));
        stack.add_titled (new Foreman.Views.Settings.NetworkSettingsView (), "network", _("Network"));
        stack.add_titled (new Foreman.Views.Settings.JavaRuntimeSettingsView (), "java", _("Java Runtime"));
        stack_grid.attach (stack, 0, 1, 1, 1);

        get_content_area ().add (stack_grid);

        var close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => {
            close ();
        });

        add_action_widget (close_button, 0);
    }

}
