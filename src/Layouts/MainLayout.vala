/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Layouts.MainLayout : Gtk.Grid {

    public unowned Foreman.Windows.MainWindow window { get; construct; }

    private Foreman.Views.LibraryView library_view;
    private Gtk.Stack stack;

    public MainLayout (Foreman.Windows.MainWindow window) {
        Object (
            window: window
        );
    }

    construct {
        var header_bar = new Foreman.Widgets.HeaderBar ();

        library_view = new Foreman.Views.LibraryView ();

        stack = new Gtk.Stack () {
            expand = true,
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT
        };
        stack.add_named (new Foreman.Views.Welcome (window), Foreman.Views.Welcome.NAME);
        stack.add_named (library_view, Foreman.Views.LibraryView.NAME);

        var base_grid = new Gtk.Grid () {
            expand = true
        };
        base_grid.attach (stack, 0, 0);

        attach (header_bar, 0, 0);
        attach (base_grid, 0, 1);

        show_all ();

        stack.set_visible_child_name (Foreman.Views.Welcome.NAME);
    }

    public void show_library () {
        //  library_view.show_grid ();
        stack.set_visible_child_name (Foreman.Views.LibraryView.NAME);
    }

}
