/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Layouts.MainLayout : Gtk.Grid {

    private static Gtk.CssProvider provider;

    public unowned Foreman.Windows.MainWindow window { get; construct; }

    //  private Foreman.Views.LibraryView library_view;
    //  private Gtk.Stack stack;

    private Gtk.Stack main_stack;
    private Gtk.Stack server_details_stack;
    private Gtk.Grid side_panel;

    private Gee.HashMap<string, Foreman.Views.ServerDetailView> detail_views;

    public MainLayout (Foreman.Windows.MainWindow window) {
        Object (
            window: window
        );
    }

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/foreman/SettingsSidebar.css");
    }

    construct {
        //  var header_bar = new Foreman.Widgets.HeaderBar ();

        //  library_view = new Foreman.Views.LibraryView ();
        //  library_view.start_button_clicked.connect ((server_context) => {
        //      start_button_clicked (server_context);
        //  });
        //  library_view.stop_button_clicked.connect ((server_context) => {
        //      stop_button_clicked (server_context);
        //  });

        //  stack = new Gtk.Stack () {
        //      expand = true,
        //      transition_type = Gtk.StackTransitionType.SLIDE_LEFT
        //  };
        //  stack.add_named (new Foreman.Views.Welcome (window), Foreman.Views.Welcome.NAME);
        //  stack.add_named (library_view, Foreman.Views.LibraryView.NAME);

        //  var base_grid = new Gtk.Grid () {
        //      expand = true
        //  };
        //  base_grid.attach (stack, 0, 0);

        //  attach (header_bar, 0, 0);
        //  attach (base_grid, 0, 1);

        //  show_all ();

        //  stack.set_visible_child_name (Foreman.Views.Welcome.NAME);

        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        detail_views = new Gee.HashMap<string, Foreman.Views.ServerDetailView> ();
        
        server_details_stack = new Gtk.Stack () {
            expand = true
        };
        var settings_sidebar = new Granite.SettingsSidebar (server_details_stack) {
            expand = true
        };
        settings_sidebar.get_style_context ().add_class ("settings-sidebar");

        main_stack = new Gtk.Stack () {
            expand = true
        };
        main_stack.add_named (server_details_stack, "details");
        main_stack.add_named (new Foreman.Views.Welcome (window), "welcome");

        var primary_header_bar = new Foreman.Widgets.PrimaryHeaderBar ();
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
        main_grid.attach (main_stack, 0, 1);

        side_panel = new Gtk.Grid () {
            expand = true
        };
        side_panel.get_style_context ().add_class (Gtk.STYLE_CLASS_SIDEBAR);
        side_panel.attach (secondary_header_bar, 0, 0);
        side_panel.attach (settings_sidebar, 0, 1);
        side_panel.attach (new Foreman.Widgets.NewServerActionBar (), 0, 2);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 240
        };
        paned.pack1 (side_panel, false, false);
        paned.pack2 (main_grid, true, false);

        attach (paned, 0, 0);

        show_all ();

        set_sidebar_visible (false);
        main_stack.set_visible_child_name ("welcome");
    }

    public void add_server_to_library (Foreman.Services.Server.Context server_context) {
        // Create the view and connect signals
        var page = new Foreman.Views.ServerDetailView (server_context);
        page.start_button_clicked.connect (() => {
            start_button_clicked (server_context);
        });
        page.stop_button_clicked.connect (() => {
            stop_button_clicked (server_context);
        });
        page.delete_button_clicked.connect (() => {
            delete_button_clicked (server_context);
        });
        page.configure_button_clicked.connect (() => {
            configure_button_clicked (server_context);
        });
        page.command_to_send.connect ((command) => {
            command_to_send (server_context, command);
        });

        // Add the view to the stack
        server_details_stack.add_named (page, server_context.uuid);
        detail_views.set (server_context.uuid, page);

        // If we were previously showing the welcome view, ensure that the sidebar is now visible
        if (main_stack.get_visible_child_name () == "welcome") {
            set_sidebar_visible (true);
        }
        main_stack.set_visible_child_name ("details");
        main_stack.show_all ();
    }

    public void toggle_sidebar () {
        side_panel.visible = !side_panel.visible;
    }

    public void set_sidebar_visible (bool visible) {
        side_panel.visible = visible;
    }

    public Foreman.Views.ServerDetailView? get_visible_server () {
        return server_details_stack.get_visible_child () as Foreman.Views.ServerDetailView;
    }

    public void server_starting (Foreman.Services.Server.Context server_context) {
        detail_views.get (server_context.uuid).starting ();
    }

    public void server_started (Foreman.Services.Server.Context server_context) {
        detail_views.get (server_context.uuid).started ();
    }

    public void server_stopping (Foreman.Services.Server.Context server_context) {
        detail_views.get (server_context.uuid).stopping ();
    }

    public void server_stopped (Foreman.Services.Server.Context server_context) {
        detail_views.get (server_context.uuid).stopped ();
    }

    public void server_errored (Foreman.Services.Server.Context server_context) {
        detail_views.get (server_context.uuid).errored ();
    }

    public void server_startup_failed (Foreman.Services.Server.Context server_context) {
        detail_views.get (server_context.uuid).errored ();
    }

    public void server_deleted (Foreman.Services.Server.Context server_context) {
        Foreman.Views.ServerDetailView page;
        detail_views.unset (server_context.uuid, out page);
        server_details_stack.remove (page);
        if (detail_views.size == 0) {
            main_stack.set_visible_child_name ("welcome");
            set_sidebar_visible (false);
        }
    }

    public void update_progress (Foreman.Services.Server.Context server_context, double progress) {
        detail_views.get (server_context.uuid).update_progress (progress);
    }

    public void player_joined (Foreman.Services.Server.Context server_context) {
        detail_views.get (server_context.uuid).player_joined ();
    }

    public void player_left (Foreman.Services.Server.Context server_context) {
        detail_views.get (server_context.uuid).player_left ();
    }

    public void add_log_message (Foreman.Services.Server.Context server_context, string message) {
        detail_views.get (server_context.uuid).add_log_message (message);
    }

    public void add_log_warning (Foreman.Services.Server.Context server_context, string message) {
        detail_views.get (server_context.uuid).add_log_warning (message);
    }

    public void add_log_error (Foreman.Services.Server.Context server_context, string message) {
        detail_views.get (server_context.uuid).add_log_error (message);
    }

    public signal void start_button_clicked (Foreman.Services.Server.Context server_context);
    public signal void stop_button_clicked (Foreman.Services.Server.Context server_context);
    public signal void delete_button_clicked (Foreman.Services.Server.Context server_context);
    public signal void configure_button_clicked (Foreman.Services.Server.Context server_context);
    public signal void command_to_send (Foreman.Services.Server.Context server_context, string command);

}
