/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.ServerDetailView : Gtk.Grid {

    private Gtk.Stack stack;

    public ServerDetailView () {
        Object (
            expand: true
        );
    }

    construct {
        //  var server_grid = new Foreman.Widgets.ServerGrid ();
        //  var detail_view = new Foreman.Views.ServerDetailView ();

        //  stack = new Gtk.Stack () {
        //      expand = true
        //  };
        //  stack.add_named (server_grid, "server-grid");
        //  stack.add_named (detail_view, "detail-view");

        //  add (stack);
    }

}