/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Widgets.LogOutput : Gtk.Grid {

    private const string ERROR_TAG_NAME = "error";
    private const string WARNING_TAG_NAME = "warning";

    private Gtk.TextView text_view;
    private Gtk.ScrolledWindow scrolled_window;
    private Gtk.Entry entry;

    private bool lock_autoscroll = false;

    public LogOutput () {
        Object (
            expand: true,
            row_spacing: 4,
            column_spacing: 4
        );
    }

    construct {
        text_view = new Gtk.TextView () {
            pixels_below_lines = 3,
            border_width = 12,
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
            //  indent = text_indent,
            monospace = true,
            editable = false,
            cursor_visible = false,
            expand = true
        };
        text_view.get_style_context ().add_class (Granite.STYLE_CLASS_TERMINAL);

        scrolled_window = new Gtk.ScrolledWindow (null, null) {
            vscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            hscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            expand = true
        };
        scrolled_window.add (text_view);

        //  var autoscroll_label = new Gtk.Label (_("Autoscroll:"));

        //  var autoscroll_switch = new Gtk.Switch ();

        //  var autoscroll_switcher_grid = new Gtk.Grid () {
        //      halign = Gtk.Align.CENTER,
        //      valign = Gtk.Align.CENTER
        //  };
        //  autoscroll_switcher_grid.attach (autoscroll_label, 0, 0);
        //  autoscroll_switcher_grid.attach (autoscroll_switch, 1, 0);

        //  var autoscroll_switcher = new Gtk.EventBox () {
        //      valign = Gtk.Align.START,
        //      halign = Gtk.Align.END
        //  };
        //  autoscroll_switcher.set_events (autoscroll_switcher.get_events () | Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        //  autoscroll_switcher.add (autoscroll_switcher_grid);

        entry = new Gtk.Entry () {
            hexpand = true,
            vexpand = false,
            primary_icon_name = "utilities-terminal-symbolic",
            primary_icon_sensitive = false,
            primary_icon_activatable = false,
            show_emoji_icon = false,
            has_frame = true,
            placeholder_text = _("Server command"),
            sensitive = false
        };
        entry.activate.connect (() => {
            var command = entry.get_text ().strip ();
            if (command.length == 0) {
                return;
            }
            entry.set_text ("");
            append_message (command);
            command_to_send (command);
        });

        //  get_style_context ().add_class (Granite.STYLE_CLASS_TERMINAL);

        var autoscroll_button = new Gtk.Button.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON) {
            tooltip_text = _("Disable autoscrolling")
        };
        autoscroll_button.clicked.connect (() => {
            lock_autoscroll = !lock_autoscroll;
            autoscroll_button.image = new Gtk.Image () {
                gicon = new ThemedIcon (lock_autoscroll ? "changes-prevent-symbolic" : "changes-allow-symbolic"),
                pixel_size = 16
            };
            autoscroll_button.tooltip_text = lock_autoscroll ? _("Enable autoscrolling") : _("Disable autoscrolling");
        });

        attach (scrolled_window, 0, 0, 2, 1);
        attach (entry, 0, 1, 1, 1);
        attach (autoscroll_button, 1, 1, 1, 1);

        create_text_tags ();
    }

    private void create_text_tags () {
        unowned Gtk.TextBuffer buffer = text_view.get_buffer ();
        var color = Gdk.RGBA ();

        unowned Gtk.TextTag error_tag = buffer.create_tag (ERROR_TAG_NAME);
        error_tag.weight = Pango.Weight.SEMIBOLD;
        color.parse (Foreman.Models.ColorPalette.COLOR_STRAWBERRY.get_value ());
        error_tag.foreground_rgba = color;

        unowned Gtk.TextTag warning_tag = buffer.create_tag (WARNING_TAG_NAME);
        warning_tag.weight = Pango.Weight.SEMIBOLD;
        color.parse (Foreman.Models.ColorPalette.COLOR_BANANA.get_value ());
        warning_tag.foreground_rgba = color;
    }

    public void set_accept_input (bool accept_input) {
        entry.sensitive = accept_input;
        if (!accept_input) {
            entry.set_text ("");
        }
    }

    public void append_message (string message) {
        string line = @"$message\n";
        Gtk.TextIter end_iter;
        text_view.get_buffer ().get_end_iter (out end_iter);
        text_view.get_buffer ().insert_text (ref end_iter, line, line.length);
        autoscroll ();
    }

    public void append_warning (string message) {
        unowned Gtk.TextBuffer buffer = text_view.get_buffer ();

        Gtk.TextIter end_iter;
        buffer.get_end_iter (out end_iter);
        buffer.insert_text (ref end_iter, message, message.length);

        Gtk.TextIter start_iter = end_iter;
        start_iter.backward_chars (message.length);
        buffer.apply_tag_by_name (WARNING_TAG_NAME, start_iter, end_iter);

        buffer.insert (ref end_iter, "\n", 1);

        autoscroll ();
    }

    public void append_error (string message) {
        unowned Gtk.TextBuffer buffer = text_view.get_buffer ();

        Gtk.TextIter end_iter;
        buffer.get_end_iter (out end_iter);
        buffer.insert_text (ref end_iter, message, message.length);

        Gtk.TextIter start_iter = end_iter;
        start_iter.backward_chars (message.length);
        buffer.apply_tag_by_name (ERROR_TAG_NAME, start_iter, end_iter);

        buffer.insert (ref end_iter, "\n", 1);

        autoscroll ();
    }

    private void autoscroll () {
        // TODO: Fix this - doesn't work completely if a lot of messages are inserted in rapid succession
        if (!lock_autoscroll) {
            scrolled_window.vadjustment.value = scrolled_window.vadjustment.upper - scrolled_window.vadjustment.page_size;
        }
    }

    public signal void command_to_send (string command);

}