/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Widgets.NewServerActionBar : Gtk.ActionBar {

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);

        var create_accellabel = new Granite.AccelLabel.from_action_name (
            _("Create a New Server…"),
            Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_CREATE_NEW_SERVER
        );

        var create_menu_item = new Gtk.ModelButton () {
            action_name = Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_CREATE_NEW_SERVER
        };
        create_menu_item.get_child ().destroy ();
        create_menu_item.add (create_accellabel);

        //  var import_accellabel = new Granite.AccelLabel.from_action_name (
        //      _("Import a New Server…"),
        //      Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_IMPORT_SERVER
        //  );

        //  var import_menu_item = new Gtk.ModelButton () {
        //      action_name = Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_IMPORT_SERVER
        //  };
        //  import_menu_item.get_child ().destroy ();
        //  import_menu_item.add (import_accellabel);

        var popover_grid = new Gtk.Grid () {
            margin_top = 3,
            margin_bottom = 3,
            orientation = Gtk.Orientation.VERTICAL,
            width_request = 200
        };
        popover_grid.attach (create_menu_item, 0, 0, 1, 1);
        popover_grid.show_all ();

        var join_popover = new Gtk.Popover (null);
        join_popover.add (popover_grid);

        var menu_button = new Gtk.MenuButton () {
            label = _("Add Server…"),
            direction = Gtk.ArrowType.UP,
            popover = join_popover,
            tooltip_text = _("Add or Import a Server"),
            image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
            always_show_image = true
        };
        menu_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        pack_start (menu_button);
    }

}
