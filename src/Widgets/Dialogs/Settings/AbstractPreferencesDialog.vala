/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public abstract class Foreman.Widgets.Dialogs.AbstractPreferencesDialog : Hdy.Window {

    private static Gtk.CssProvider provider;

    public unowned Foreman.Windows.MainWindow main_window { get; construct; }

    private Gtk.Stack stack;

    AbstractPreferencesDialog (Foreman.Windows.MainWindow main_window) {
        Object (
            title: _("%s Preferences").printf (Constants.APP_NAME),
            application: Foreman.Application.get_instance (),
            resizable: true,
            transient_for: main_window,
            main_window: main_window,
            border_width: 0,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/foreman/SettingsSidebar.css");
    }

    construct {
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        stack = new Gtk.Stack () {
            expand = true
        };
        var settings_sidebar = new Granite.SettingsSidebar (stack) {
            expand = true
        };
        settings_sidebar.get_style_context ().add_class ("settings-sidebar");

        var primary_header_bar = new Hdy.HeaderBar () {
            title = _("Preferences"),
            has_subtitle = false,
            show_close_button = true
        };
        primary_header_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        var secondary_header_bar = new Hdy.HeaderBar () {
            has_subtitle = false,
            show_close_button = true
        };
        secondary_header_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        var header_group = new Hdy.HeaderGroup ();
        header_group.add_header_bar (secondary_header_bar);
        header_group.add_header_bar (primary_header_bar);

        var main_grid = new Gtk.Grid () {
            expand = true
        };
        main_grid.attach (primary_header_bar, 0, 0);
        main_grid.attach (stack, 0, 1);

        var side_panel = new Gtk.Grid () {
            expand = true
        };
        side_panel.get_style_context ().add_class (Gtk.STYLE_CLASS_SIDEBAR);
        side_panel.attach (secondary_header_bar, 0, 0);
        side_panel.attach (settings_sidebar, 0, 1);
        //  side_panel.attach (new Foreman.Widgets.NewServerActionBar (), 0, 2);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 200
        };
        paned.pack1 (side_panel, false, false);
        paned.pack2 (main_grid, true, false);

        add (paned);

        stack.add_named (new Foreman.Views.Settings.GameplaySettingsPage (), Foreman.Views.Settings.GameplaySettingsPage.NAME);
        stack.add_named (new Foreman.Views.Settings.WorldBuildingSettingsPage (), Foreman.Views.Settings.WorldBuildingSettingsPage.NAME);
        stack.add_named (new Foreman.Views.Settings.NetworkSettingsPage (), Foreman.Views.Settings.NetworkSettingsPage.NAME);
        stack.add_named (new Foreman.Views.Settings.ModerationSettingsPage (), Foreman.Views.Settings.ModerationSettingsPage.NAME);
        stack.add_named (new Foreman.Views.Settings.JavaRuntimeSettingsPage (), Foreman.Views.Settings.JavaRuntimeSettingsPage.NAME);

        int width = 700;
        int height = 600;
        resize (width, height);
        int parent_x, parent_y, parent_width, parent_height;
        main_window.get_position (out parent_x, out parent_y);
        main_window.get_size (out parent_width, out parent_height);
        move (parent_x + (parent_width / 2) - (width / 2), parent_y + (parent_height / 2) - (height / 2));

        show_all ();
    }


}