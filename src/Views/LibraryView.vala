/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.LibraryView : Gtk.Grid {

    public const string NAME = "library";

    private Gtk.Stack stack;

    public LibraryView () {
        Object (
            expand: true
        );
    }

    construct {
        var server_grid = new Foreman.Widgets.ServerGrid ();
        var detail_view = new Foreman.Views.ServerDetailView ();

        stack = new Gtk.Stack () {
            expand = true
        };
        stack.add_named (server_grid, "server-grid");
        stack.add_named (detail_view, "detail-view");

        add (stack);

        show_all ();

        stack.set_visible_child_name ("server-grid");
    }

    public void show_grid () {
        stack.set_visible_child_name ("server-grid");
    }

    public void show_details () {
        stack.set_visible_child_name ("detail-view");
    }

}