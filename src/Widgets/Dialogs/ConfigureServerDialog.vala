/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Widgets.Dialogs.ConfigureServerDialog : Granite.Dialog {

    public Foreman.Services.Server.Context server_context { get; construct; }

    public ConfigureServerDialog (Foreman.Windows.MainWindow main_window, Foreman.Services.Server.Context server_context) {
        Object (
            deletable: false,
            resizable: false,
            title: _("Configure Server"),
            transient_for: main_window,
            modal: false,
            server_context: server_context
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

        var header_image = new Gtk.Image.from_icon_name (Constants.APP_ID + ".network-server-configure", Gtk.IconSize.DIALOG);

        var header_title = new Gtk.Label (_("Configure Server")) {
            halign = Gtk.Align.START,
            hexpand = true,
            margin_end = 10
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.set_line_wrap (true);

        header_grid.attach (header_image, 0, 0, 1, 1);
        header_grid.attach (header_title, 1, 0, 1, 1);

        var text_view = new Gtk.TextView () {
            pixels_below_lines = 3,
            border_width = 12,
            wrap_mode = Gtk.WrapMode.NONE,
            monospace = true,
            editable = true,
            cursor_visible = true,
            expand = true
        };
        text_view.get_style_context ().add_class (Granite.STYLE_CLASS_TERMINAL);

        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            vscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            hscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            expand = true,
            margin = 30
        };
        scrolled_window.add (text_view);
        scrolled_window.set_size_request (500, 600);

        body.add (header_grid);
        body.add (scrolled_window);

        // Add action buttons
        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.clicked.connect (() => {
            close ();
        });

        var save_button = new Gtk.Button.with_label (_("Save"));
        save_button.get_style_context ().add_class ("suggested-action");
        //  save.clicked.connect (() => {
        //      spinner.start ();
        //      status_label.label = "";
        //      save_clicked (get_topic ());
        //  });

        //  save.sensitive = get_topic () != current_topic;
        //  text_view.get_buffer ().changed.connect (() => {
        //      var new_topic = get_topic ();
        //      save.sensitive = new_topic != current_topic;
        //      if (new_topic.length == 0 && current_topic.length != 0) {
        //          // Make sure current topic isn't empty - doesn't make sense to clear
        //          // something that's already empty
        //          save.set_label (_("Clear topic"));
        //      } else {
        //          save.set_label (_("Submit"));
        //      }
        //  });

        add_action_widget (cancel_button, 0);
        add_action_widget (save_button, 1);

        text_view.get_buffer ().set_text (read_properties_file (GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, server_context.server_directory.get_path (), "server.properties"))));
    }

    private string read_properties_file (GLib.File properties_file) {
        try {
            var sb = new GLib.StringBuilder ();
            var input_stream = new DataInputStream (properties_file.read ());
            string line = null;
            while ((line = input_stream.read_line ()) != null) {
                sb.append (line).append ("\n");
            }
            return sb.str;
        } catch (GLib.Error e) {
            warning (e.message);
            return "";
        }
    }

    private void save_properties_File (string content) {

    }

}
