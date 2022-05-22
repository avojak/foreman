/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Widgets.ServerGrid : Gtk.Grid {

    private static Gtk.CssProvider provider;

    public Gtk.FlowBox flow_box { get; construct; }

    private Gtk.Stack stack;

    public ServerGrid () {
        Object (
            expand: true
        );
    }

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/foreman/AlertView.css");
    }

    construct {
        flow_box = new Gtk.FlowBox () {
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE,
            homogeneous = true,
            expand = true,
            margin = 12,
            valign = Gtk.Align.START
        };
        flow_box.child_activated.connect (on_item_selected);
        flow_box.button_press_event.connect (show_context_menu);

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            expand = true
        };
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (flow_box);

        var alert_view = new Granite.Widgets.AlertView ("No Servers", "Servers will appear here once created", "network-server");
        alert_view.get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // TODO: Instead of a stack, maybe transition back to the welcome view?
        stack = new Gtk.Stack () {
            expand = true
        };
        stack.add_named (scrolled_window, "scrolled-window");
        stack.add_named (alert_view, "alert-view");

        add (stack);

        show_all ();

        stack.set_visible_child_name ("alert-view");
    }

    private void on_item_selected (Gtk.FlowBoxChild child) {
        //  item_selected (child as Replay.Widgets.LibraryItem);
    }

    private bool show_context_menu (Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_PRESS && event.button == Gdk.BUTTON_SECONDARY) {
            unowned Gtk.FlowBoxChild? child = flow_box.get_child_at_pos ((int) event.x, (int) event.y);
            if (child == null) {
                return false;
            }
            flow_box.select_child (child); // Makes it clear which item was clicked
            //  unowned var library_item = child as Replay.Widgets.LibraryItem;
            //  var menu = new Gtk.Menu ();
            //  var run_item = create_image_menu_item (_("Play"), "");
            //  run_item.activate.connect (() => {
            //      on_item_run_selected (library_item);
            //  });
            //  var run_with_item = create_image_menu_item (_("Play with"), "");
            //  var run_with_submenu = new Gtk.Menu ();
            //  foreach (var core in Replay.Core.Client.get_default ().core_repository.get_cores_for_rom (GLib.File.new_for_path (library_item.game.rom_path))) {
            //      var core_name = core.info.core_name;
            //      var item = new Gtk.MenuItem.with_label (core_name);
            //      item.activate.connect (() => {
            //          on_item_run_selected (library_item, core_name);
            //      });
            //      run_with_submenu.add (item);
            //  }
            //  run_with_item.submenu = run_with_submenu;
            //  var played_item = create_image_menu_item (_("Mark as Played"), "mail-read");
            //  played_item.activate.connect (() => {
            //      item_marked_played (library_item);
            //  });
            //  var unplayed_item = create_image_menu_item (_("Mark as Unplayed"), "mail-unread");
            //  unplayed_item.activate.connect (() => {
            //      item_marked_unplayed (library_item);
            //  });
            //  var favorite_item = create_image_menu_item (_("Add to Favorites"), "starred");
            //  favorite_item.activate.connect (() => {
            //      item_added_to_favorites (library_item);
            //  });
            //  var unfavorite_item = create_image_menu_item (_("Remove from Favorites"), "non-starred");
            //  unfavorite_item.activate.connect (() => {
            //      item_removed_from_favorites (library_item);
            //  });
            //  //  var rename_item = create_image_menu_item (_("Rename…"), "edit");
            //  //  rename_item.activate.connect (() => {
            //  //      // TODO
            //  //  });
            //  var properties_item = create_image_menu_item (_("Properties…"), "");
            //  properties_item.activate.connect (() => {
            //      // TODO
            //  });
            //  var delete_item = create_image_menu_item (_("Delete"), "edit-delete");
            //  delete_item.activate.connect (() => {
            //      // TODO
            //  });
            //  // TODO: Support adding item to add to a custom category
            //  menu.add (run_item);
            //  menu.add (run_with_item);
            //  menu.add (new Gtk.SeparatorMenuItem ());
            //  menu.add (library_item.game.is_favorite ? unfavorite_item : favorite_item);
            //  menu.add (library_item.game.is_played ? unplayed_item : played_item);
            //  menu.add (new Gtk.SeparatorMenuItem ());
            //  menu.add (properties_item);
            //  //  menu.add (new Gtk.SeparatorMenuItem ());
            //  //  menu.add (delete_item);
            //  menu.attach_to_widget (child, null);
            //  menu.show_all ();
            //  menu.popup_at_pointer (event);
            return true;
        }
        return false;
    }

    public void add_server () {
        stack.set_visible_child_name ("scrolled-window");
        // TODO
    }

    public void remove_server () {
        if (flow_box.get_children ().length () == 0) {
            stack.set_visible_child_name ("alert-view");
        }
        // TODO
    }

}