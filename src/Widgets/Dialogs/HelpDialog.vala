/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Widgets.Dialogs.HelpDialog : Granite.Dialog {

    public HelpDialog (Foreman.Windows.MainWindow main_window) {
        Object (
            deletable: false,
            resizable: false,
            title: _("Help"),
            transient_for: main_window,
            modal: false
        );
    }

    construct {
        var body = get_content_area ();

        // Create the header
        var header_grid = new Gtk.Grid () {
            margin_start = 30,
            margin_end = 30,
            margin_bottom = 10,
            column_spacing = 10
        };

        var header_image = new Gtk.Image.from_icon_name ("help-contents", Gtk.IconSize.DIALOG);

        var header_title = new Gtk.Label (_("Help")) {
            halign = Gtk.Align.START,
            hexpand = true,
            margin_end = 10
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.set_line_wrap (true);

        header_grid.attach (header_image, 0, 0, 1, 1);
        header_grid.attach (header_title, 1, 0, 1, 1);

        body.add (header_grid);

        var main_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            margin = 30,
            row_spacing = 12,
            column_spacing = 10
        };

        int num_chars = 50;
        var local_connection_header_label = new Granite.HeaderLabel (_("Troubleshooting Connection Issues"));
        var local_connection_text = new Gtk.Label (_("If players are having trouble connecting to your server first take a look at the Minecraft: Java Edition Multiplayer Connection Issues guide:")) {
            max_width_chars = num_chars,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        var connection_issues_link = new Gtk.LinkButton.with_label ("https://help.minecraft.net/hc/en-us/articles/360034754052-Minecraft-Java-Edition-Multiplayer-Connection-Issues-", "Minecraft: Java Edition Multiplayer Connection Issues");

        var network_link = new Gtk.LinkButton.with_label ("settings://network", _("Network Settings…"));
        var firewall_link = new Gtk.LinkButton.with_label ("settings://security/firewall", _("Firewall Settings…"));

        main_grid.add (local_connection_header_label);
        main_grid.add (local_connection_text);
        main_grid.add (connection_issues_link);
        main_grid.add (network_link);
        main_grid.add (firewall_link);

        var remote_connection_header_label = new Granite.HeaderLabel (_("Remote Connections"));
        var remote_connection_text = new Gtk.Label (_("For users connecting from outside your local network, ensure that they are using the correct IP address:")) {
            max_width_chars = num_chars,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };

        var check_ip_link = new Gtk.LinkButton.with_label ("https://ifconfig.me/", _("Check my IP Address…"));

        main_grid.add (remote_connection_header_label);
        main_grid.add (remote_connection_text);
        main_grid.add (check_ip_link);

        body.add (main_grid);

        var close_button = new Gtk.Button.with_label (_("Close"));
        close_button.clicked.connect (() => {
            close ();
        });

        add_action_widget (close_button, 0);

        set_focus (close_button);
    }

}
