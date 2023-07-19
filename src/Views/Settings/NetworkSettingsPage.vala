/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.Settings.NetworkSettingsPage : Granite.SimpleSettingsPage {

    public const string NAME = "network";

    private Gtk.Switch enable_query_switch;
    private Gtk.Label query_port_label;
    private Gtk.SpinButton query_port_entry;
    private Gtk.Switch enable_rcon_switch;
    private Gtk.Label rcon_port_label;
    private Gtk.SpinButton rcon_port_entry;
    private Gtk.Label rcon_password_label;
    private Gtk.Entry rcon_password_entry;

    public NetworkSettingsPage () {
        Object (
            header: null,
            icon_name: "preferences-system-network",
            title: _("Network"),
            description: _("Default networking preferences for new servers"),
            activatable: false,
            expand: true
        );
    }

    construct {
        /**
         * Connectivity section
         */
        var connectivity_header_label = new Granite.HeaderLabel (_("Connectivity"));

        var ip_label = new Gtk.Label (_("IP address:")) {
            halign = Gtk.Align.END
        };
        var ip_entry = new Gtk.Entry ();
        Foreman.Application.java_server_preferences.bind ("server-ip", ip_entry, "text", GLib.SettingsBindFlags.DEFAULT);

        var port_label = new Gtk.Label (_("Port:")) {
            halign = Gtk.Align.END
        };
        var port_entry = new Gtk.SpinButton.with_range (1, 65535, 1);
        Foreman.Application.java_server_preferences.bind ("server-port", port_entry, "value", GLib.SettingsBindFlags.DEFAULT);

        var enable_status_label = new Gtk.Label (_("Enable status:")) {
            halign = Gtk.Align.END
        };
        var enable_status_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.java_server_preferences.bind ("enable-status", enable_status_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        /**
         * RCON (GameSpy4) section
         */
        var query_header_label = new Granite.HeaderLabel (_("GameSpy4 Query"));

        var enable_query_label = new Gtk.Label (_("Enable:")) {
            halign = Gtk.Align.END
        };
        enable_query_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.java_server_preferences.bind ("enable-query", enable_query_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        query_port_label = new Gtk.Label (_("Port:")) {
            halign = Gtk.Align.END
        };
        query_port_entry = new Gtk.SpinButton.with_range (1, 65535, 1);
        Foreman.Application.java_server_preferences.bind ("query-port", query_port_entry, "value", GLib.SettingsBindFlags.DEFAULT);

        var enable_rcon_label = new Gtk.Label (_("Enable:")) {
            halign = Gtk.Align.END
        };
        enable_rcon_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.java_server_preferences.bind ("enable-rcon", enable_rcon_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        rcon_port_label = new Gtk.Label (_("Port:")) {
            halign = Gtk.Align.END
        };
        rcon_port_entry = new Gtk.SpinButton.with_range (1, 65535, 1);
        Foreman.Application.java_server_preferences.bind ("rcon-port", rcon_port_entry, "value", GLib.SettingsBindFlags.DEFAULT);

        rcon_password_label = new Gtk.Label (_("Password:")) {
            halign = Gtk.Align.END
        };

        rcon_password_entry = new Gtk.Entry () {
            hexpand = true,
            visibility = false
        };
        rcon_password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "changes-prevent-symbolic");
        rcon_password_entry.icon_press.connect ((pos, event) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY) {
                rcon_password_entry.visibility = !rcon_password_entry.visibility;
            }
            if (rcon_password_entry.visibility) {
                rcon_password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "changes-allow-symbolic");
            } else {
                rcon_password_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "changes-prevent-symbolic");
            }
        });
        Foreman.Application.java_server_preferences.bind ("rcon-password", rcon_password_entry, "text", GLib.SettingsBindFlags.DEFAULT);

        /**
         * Network Compression section
         */
        var network_compression_header_label = new Granite.HeaderLabel (_("Network Compression"));
        var enable_network_compression_label = new Gtk.Label (_("Enable:")) {
            halign = Gtk.Align.END
        };
        var enable_network_compression_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };

        var main_grid = new Gtk.Grid () {
            margin_start = 10,
            margin_end = 10,
            margin_bottom = 10,
            column_spacing = 10,
            row_spacing = 10,
            column_homogeneous = false
        };

        var rcon_header_label = new Granite.HeaderLabel (_("RCON"));

        main_grid.attach (connectivity_header_label, 0, 0, 2);
        main_grid.attach (ip_label, 0, 1);
        main_grid.attach (ip_entry, 1, 1);
        main_grid.attach (port_label, 0, 2);
        main_grid.attach (port_entry, 1, 2);
        main_grid.attach (enable_status_label, 0, 3);
        main_grid.attach (enable_status_switch, 1, 3);

        main_grid.attach (query_header_label, 0, 4, 2);
        main_grid.attach (enable_query_label, 0, 5);
        main_grid.attach (enable_query_switch, 1, 5);
        main_grid.attach (query_port_label, 0, 6);
        main_grid.attach (query_port_entry, 1, 6);

        main_grid.attach (rcon_header_label, 0, 7, 2);
        main_grid.attach (enable_rcon_label, 0, 8);
        main_grid.attach (enable_rcon_switch, 1, 8);
        main_grid.attach (rcon_port_label, 0, 9);
        main_grid.attach (rcon_port_entry, 1, 9);
        main_grid.attach (rcon_password_label, 0, 10);
        main_grid.attach (rcon_password_entry, 1, 10);

        content_area.attach (main_grid, 0, 0);

        enable_query_switch.notify["active"].connect (update_query_port_sensitivity);
        enable_rcon_switch.notify["active"].connect (update_rcon_port_sensitivity);

        update_query_port_sensitivity ();
        update_rcon_port_sensitivity ();
    }

    private void update_query_port_sensitivity () {
        query_port_label.sensitive = enable_query_switch.active;
        query_port_entry.sensitive = enable_query_switch.active;
    }

    private void update_rcon_port_sensitivity () {
        rcon_port_label.sensitive = enable_rcon_switch.active;
        rcon_port_entry.sensitive = enable_rcon_switch.active;
        rcon_password_label.sensitive = enable_rcon_switch.active;
        rcon_password_entry.sensitive = enable_rcon_switch.active;
    }

}
