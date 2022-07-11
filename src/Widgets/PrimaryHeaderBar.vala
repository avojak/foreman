/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Widgets.PrimaryHeaderBar : Hdy.HeaderBar {

    public PrimaryHeaderBar () {
        Object (
            title: Constants.APP_NAME,
            show_close_button: true,
            has_subtitle: false
        );
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        // TODO: Add search entry

        // TODO: Add ability to open a ROM file not in the library

        var settings_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text = _("Menu"),
            relief = Gtk.ReliefStyle.NONE,
            valign = Gtk.Align.CENTER
        };

        var toggle_sidebar_accellabel = new Granite.AccelLabel.from_action_name (
            _("Toggle Sidebar"),
            Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_TOGGLE_SIDEBAR
        );

        var toggle_sidebar_menu_item = new Gtk.ModelButton ();
        toggle_sidebar_menu_item.action_name = Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_TOGGLE_SIDEBAR;
        toggle_sidebar_menu_item.get_child ().destroy ();
        toggle_sidebar_menu_item.add (toggle_sidebar_accellabel);

        var preferences_accellabel = new Granite.AccelLabel.from_action_name (
            _("Preferences…"),
            Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_PREFERENCES
        );

        var preferences_menu_item = new Gtk.ModelButton () {
            action_name = Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_PREFERENCES
        };
        preferences_menu_item.get_child ().destroy ();
        preferences_menu_item.add (preferences_accellabel);

        var help_accellabel = new Granite.AccelLabel.from_action_name (
            _("Help…"),
            Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_HELP
        );

        var help_menu_item = new Gtk.ModelButton () {
            action_name = Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_HELP
        };
        help_menu_item.get_child ().destroy ();
        help_menu_item.add (help_accellabel);

        var quit_accellabel = new Granite.AccelLabel.from_action_name (
            _("Quit"),
            Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_QUIT
        );

        var quit_menu_item = new Gtk.ModelButton () {
            action_name = Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_QUIT
        };
        quit_menu_item.get_child ().destroy ();
        quit_menu_item.add (quit_accellabel);

        var settings_popover_grid = new Gtk.Grid () {
            margin_top = 3,
            margin_bottom = 3,
            orientation = Gtk.Orientation.VERTICAL,
            width_request = 200
        };
        settings_popover_grid.attach (toggle_sidebar_menu_item, 0, 0, 1, 1);
        settings_popover_grid.attach (preferences_menu_item, 0, 1, 1, 1);
        settings_popover_grid.attach (create_menu_separator (), 0, 2, 1, 1);
        settings_popover_grid.attach (help_menu_item, 0, 3, 1, 1);
        settings_popover_grid.attach (create_menu_separator (), 0, 5, 1, 1);
        settings_popover_grid.attach (quit_menu_item, 0, 5, 1, 1);
        settings_popover_grid.show_all ();

        var settings_popover = new Gtk.Popover (null);
        settings_popover.add (settings_popover_grid);

        settings_button.popover = settings_popover;

        pack_end (settings_button);
    }

    private Gtk.Separator create_menu_separator () {
        return new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 0
        };
    }

}
