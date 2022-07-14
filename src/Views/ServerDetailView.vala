/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.ServerDetailView : Granite.SimpleSettingsPage {

    public unowned Foreman.Services.Server.Context server_context { get; construct; }

    private Gtk.Stack control_stack;
    private Foreman.Widgets.ProgressButton progress_button;
    private Gtk.Label address_value;
    private Gtk.Label players_value;
    private Gtk.Label uptime_value;
    private Foreman.Widgets.LogOutput log_output;

    private GLib.Thread timer_thread;
    //  private GLib.Thread heap_thread;
    private GLib.Cancellable cancellable;

    //  private LiveChart.Serie heap_serie;

    public ServerDetailView (Foreman.Services.Server.Context server_context) {
        Object (
            header: null,
            icon_name: Constants.APP_ID,
            status: Foreman.Services.Server.State.NOT_RUNNING.get_display_string (),
            status_type: Granite.SettingsPage.StatusType.OFFLINE,
            title: server_context.name,
            description: "%s v%s".printf (server_context.server_type.get_display_string (), server_context.server_version),
            activatable: false,
            expand: true,
            server_context: server_context
        );
    }

    construct {
        var start_button = create_control_button ("media-playback-start-symbolic", _("Start"));
        start_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        start_button.clicked.connect (() => {
            start_button_clicked ();
        });

        progress_button = new Foreman.Widgets.ProgressButton () {
            label = _("Starting"),
            sensitive = false,
            fraction = 0.0
        };

        var stopping_button = new Foreman.Widgets.ProgressButton () {
            label = _("Stopping"),
            sensitive = false,
            fraction = 0.0
        };

        var stop_button = create_control_button ("media-playback-stop-symbolic", _("Stop"));
        stop_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        stop_button.clicked.connect (() => {
            stop_button_clicked ();
        });

        control_stack = new Gtk.Stack () {

        };
        control_stack.add_named (start_button, "start");
        control_stack.add_named (progress_button, "progress");
        control_stack.add_named (stop_button, "stop");
        control_stack.add_named (stopping_button, "stopping");

        var address_icon = new Gtk.Image () {
            gicon = new GLib.ThemedIcon ("network-server-symbolic"),
            pixel_size = 16
        };
        var address_label = new Granite.HeaderLabel (_("Address:"));
        address_value = new Gtk.Label ("--");
        var address_grid = new Gtk.Grid () {
            column_spacing = 6
        };
        address_grid.attach (address_icon, 0, 0);
        address_grid.attach (address_label, 1, 0);
        address_grid.attach (address_value, 2, 0);

        var players_icon = new Gtk.Image () {
            gicon = new GLib.ThemedIcon ("system-users-symbolic"),
            pixel_size = 16
        };
        var players_label = new Granite.HeaderLabel (_("Players:"));
        players_value = new Gtk.Label ("--");
        var players_grid = new Gtk.Grid () {
            column_spacing = 6
        };
        players_grid.attach (players_icon, 0, 0);
        players_grid.attach (players_label, 1, 0);
        players_grid.attach (players_value, 2, 0);

        var uptime_icon = new Gtk.Image () {
            gicon = new GLib.ThemedIcon ("preferences-system-time-symbolic"),
            pixel_size = 16
        };
        var uptime_label = new Granite.HeaderLabel (_("Uptime:"));
        uptime_value = new Gtk.Label ("--");
        var uptime_grid = new Gtk.Grid () {
            column_spacing = 6
        };
        uptime_grid.attach (uptime_icon, 0, 0);
        uptime_grid.attach (uptime_label, 1, 0);
        uptime_grid.attach (uptime_value, 2, 0);

        var menu_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.MENU),
            tooltip_text = _("Menu"),
            relief = Gtk.ReliefStyle.NONE,
            valign = Gtk.Align.CENTER,
            hexpand = true,
            halign = Gtk.Align.END
        };
        create_menu (menu_button);

        var primary_row = new Gtk.Grid () {
            hexpand = true,
            vexpand = false,
            column_spacing = 24
        };
        primary_row.attach (control_stack, 0, 0);
        primary_row.attach (address_grid, 1, 0);
        primary_row.attach (players_grid, 2, 0);
        primary_row.attach (uptime_grid, 3, 0);
        primary_row.attach (menu_button, 4, 0);

        //  heap_serie = new LiveChart.Serie ("HEAP", new LiveChart.SmoothLineArea ());
        //  heap_serie.line.color = { 0.3, 0.8, 0.1, 1.0 };
        //  var chart = new LiveChart.Chart () {
        //      expand = true
        //  };
        //  chart.add_serie (heap_serie);

        log_output = new Foreman.Widgets.LogOutput ();
        log_output.command_to_send.connect ((command) => {
            command_to_send (command);
        });

        content_area.attach (primary_row, 0, 0);
        //  content_area.attach (chart, 0, 1);
        content_area.attach (log_output, 0, 1);
    }

    private void create_menu (Gtk.MenuButton button) {
        var configure_accellabel = new Granite.AccelLabel.from_action_name (
            _("Configure…"),
            Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_CONFIGURE_SELECTED_SERVER
        );

        var configure_menu_item = new Gtk.ModelButton ();
        configure_menu_item.action_name = Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_CONFIGURE_SELECTED_SERVER;
        configure_menu_item.get_child ().destroy ();
        configure_menu_item.add (configure_accellabel);

        // TODO: Add export option

        var delete_accellabel = new Granite.AccelLabel.from_action_name (
            _("Delete…"),
            Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_DELETE_SELECTED_SERVER
        );

        var delete_menu_item = new Gtk.ModelButton ();
        delete_menu_item.action_name = Foreman.Services.ActionManager.ACTION_PREFIX + Foreman.Services.ActionManager.ACTION_DELETE_SELECTED_SERVER;
        delete_menu_item.get_child ().destroy ();
        delete_menu_item.add (delete_accellabel);
        delete_menu_item.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        var popover_grid = new Gtk.Grid () {
            margin_top = 3,
            margin_bottom = 3,
            orientation = Gtk.Orientation.VERTICAL,
            width_request = 200
        };
        //  popover_grid.attach (configure_menu_item, 0, 0);
        //  popover_grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
        //      margin_top = 0
        //  }, 0, 1);
        popover_grid.attach (delete_menu_item, 0, 0);
        popover_grid.show_all ();

        var popover = new Gtk.Popover (null);
        popover.add (popover_grid);

        button.popover = popover;
    }

    private Gtk.Button create_control_button (string icon_name, string label) {
        return new Gtk.Button () {
            always_show_image = true,
            image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.BUTTON),
            image_position = Gtk.PositionType.LEFT,
            label = label,
            tooltip_text = label,
            width_request = 100 // Make the button a bit larger for emphasis
        };
    }

    public void starting () {
        Idle.add (() => {
            status = Foreman.Services.Server.State.STARTING.get_display_string ();
            status_type = Granite.SettingsPage.StatusType.WARNING;
            progress_button.fraction = 0.0;
            control_stack.set_visible_child_name ("progress");
            return GLib.Source.REMOVE;
        });
    }

    public void started () {
        Idle.add (() => {
            status = Foreman.Services.Server.State.RUNNING.get_display_string ();
            status_type = Granite.SettingsPage.StatusType.SUCCESS;
            control_stack.set_visible_child_name ("stop");
            //  var network_monitor = GLib.NetworkMonitor.get_default ();
            //  var network_manager = new NM.Client ();
            //  GLib.Process.spawn_command_line_sync (string command_line, out string standard_output, out string standard_error, out int exit_status)
            //  foreach (var ip in Foreman.Utils.NetUtils.get_private_ip_addrs ()) {
            //      debug (ip);
            //  }
            var ip = "127.0.0.1"; // Foreman.Utils.NetUtils.get_public_ip_addr ();
            // TODO: Maybe just use private IP only for now? Or show a dropdown with the various IPs?
            address_value.set_text (@"$ip:25565"); // TODO: Get the real value
            players_value.set_text ("0");
            log_output.set_accept_input (true);
            return GLib.Source.REMOVE;
        });
        cancellable = new GLib.Cancellable ();
        timer_thread = new GLib.Thread<void> ("timer", () => {
            while (!cancellable.is_cancelled ()) {
                update_uptime (Foreman.Core.Client.get_default ().server_manager.get_uptime_seconds (server_context.uuid));
                Thread.usleep (500000); // 0.5 seconds
            }
        });
        //  heap_thread = new GLib.Thread<void> ("heap", () => {
        //      while (!cancellable.is_cancelled ()) {
        //          Foreman.Core.Client.get_default ().server_manager.get_heap_size.begin (server_context.uuid, (obj, res) => {
        //              double? heap_size = Foreman.Core.Client.get_default ().server_manager.get_heap_size.end (res);
        //              if (heap_size != null) {
        //                  debug (heap_size.to_string ());
        //                  heap_serie.add (heap_size);
        //              }
        //          });
        //          Thread.usleep (1000000); // 1 second
        //      }
        //  });
    }

    public void stopping () {
        Idle.add (() => {
            status = Foreman.Services.Server.State.STOPPING.get_display_string ();
            status_type = Granite.SettingsPage.StatusType.WARNING;
            control_stack.set_visible_child_name ("stopping");
            address_value.set_text ("--");
            players_value.set_text ("--");
            uptime_value.set_text ("--");
            log_output.set_accept_input (false);
            return GLib.Source.REMOVE;
        });
    }

    public void stopped () {
        Idle.add (() => {
            status = Foreman.Services.Server.State.NOT_RUNNING.get_display_string ();
            status_type = Granite.SettingsPage.StatusType.OFFLINE;
            progress_button.fraction = 0.0;
            control_stack.set_visible_child_name ("start");
            address_value.set_text ("--");
            players_value.set_text ("--");
            uptime_value.set_text ("--");
            log_output.set_accept_input (false);
            return GLib.Source.REMOVE;
        });
        cancellable.cancel ();
    }

    public void errored () {
        Idle.add (() => {
            status = Foreman.Services.Server.State.ERRORED.get_display_string ();
            status_type = Granite.SettingsPage.StatusType.ERROR;
            progress_button.fraction = 0.0;
            control_stack.set_visible_child_name ("start");
            address_value.set_text ("--");
            players_value.set_text ("--");
            uptime_value.set_text ("--");
            log_output.set_accept_input (false);
            return GLib.Source.REMOVE;
        });
        cancellable.cancel ();
    }

    public void update_progress (double progress) {
        Idle.add (() => {
            progress_button.fraction = progress;
            return GLib.Source.REMOVE;
        });
    }

    public void player_joined () {
        Idle.add (() => {
            players_value.set_text ((int.parse (players_value.get_text ()) + 1).to_string ());
            return GLib.Source.REMOVE;
        });
    }

    public void player_left () {
        Idle.add (() => {
            players_value.set_text ((int.parse (players_value.get_text ()) - 1).to_string ());
            return GLib.Source.REMOVE;
        });
    }

    public void add_log_message (string message) {
        Idle.add (() => {
            log_output.append_message (message);
            return GLib.Source.REMOVE;
        });
    }

    public void add_log_warning (string message) {
        Idle.add (() => {
            log_output.append_warning (message);
            return GLib.Source.REMOVE;
        });
    }

    public void add_log_error (string message) {
        Idle.add (() => {
            log_output.append_error (message);
            return GLib.Source.REMOVE;
        });
    }

    private void update_uptime (double uptime_seconds) {
        if (uptime_seconds < 0) {
            Idle.add (() => {
                uptime_value.set_text ("--");
                return GLib.Source.REMOVE;
            });
            return;
        }
        int num_seconds = (int) uptime_seconds;
        int days = num_seconds / (60 * 60 * 24);
        num_seconds -= days * (60 * 60 * 24);
        int hours = num_seconds / (60 * 60);
        num_seconds -= hours * (60 * 60);
        int minutes = num_seconds / 60;
        num_seconds -= minutes * 60;

        var parts = new Gee.ArrayList<string> ();
        if (days > 0) {
            parts.add ("%id".printf (days));
        }
        if (hours > 0) {
            parts.add ("%ih".printf (hours));
        }
        if (minutes > 0) {
            parts.add ("%im".printf (minutes));
        }
        parts.add ("%is".printf (num_seconds));
        string new_value = string.joinv (" ", parts.to_array ());

        Idle.add (() => {
            uptime_value.set_text (new_value);
            return GLib.Source.REMOVE;
        });
    }

    public signal void start_button_clicked ();
    public signal void stop_button_clicked ();
    public signal void restart_button_clicked ();
    //  public signal void delete_button_clicked ();
    //  public signal void configure_button_clicked ();
    public signal void command_to_send (string command);

}
