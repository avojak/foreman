/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Widgets.Dialogs.DownloadingDialog : Granite.Dialog {

    private Gtk.Stack stack;
    private Gtk.Spinner spinner;
    private Gtk.ProgressBar progress_bar;
    private Gtk.Label progress_label;

    public DownloadingDialog (Foreman.Windows.MainWindow main_window) {
        Object (
            deletable: false,
            resizable: false,
            title: _("Downloading Server…"),
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

        var header_image = new Gtk.Image.from_icon_name ("browser-download", Gtk.IconSize.DIALOG);

        var header_title = new Gtk.Label (_("Downloading Server…")) {
            halign = Gtk.Align.START,
            hexpand = true,
            margin_end = 10
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.set_line_wrap (true);

        header_grid.attach (header_image, 0, 0, 1, 1);
        header_grid.attach (header_title, 1, 0, 1, 1);

        body.add (header_grid);

        progress_bar = new Gtk.ProgressBar () {
            valign = Gtk.Align.CENTER,
            hexpand = true,
            fraction = 0.0,
            show_text = false
        };

        progress_label = new Gtk.Label ("0MB / ?MB") {
            halign = Gtk.Align.START,
            justify = Gtk.Justification.LEFT,
            ellipsize = Pango.EllipsizeMode.END,
            width_chars = 15
        };

        var progress_grid = new Gtk.Grid () {
            margin = 30,
            row_spacing = 12,
            column_spacing = 10,
            hexpand = true,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER
        };
        progress_grid.attach (progress_bar, 0, 0);
        progress_grid.attach (progress_label, 1, 0);

        var extracting_grid = new Gtk.Grid () {
            margin = 30,
            row_spacing = 12,
            column_spacing = 10,
            hexpand = true,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER
        };
        spinner = new Gtk.Spinner ();
        extracting_grid.attach (spinner, 0, 0);
        extracting_grid.attach (new Gtk.Label (_("Extracting…")), 1, 0);

        stack = new Gtk.Stack ();
        stack.add_named (extracting_grid, "extracting");
        stack.add_named (progress_grid, "downloading");

        body.add (stack);
    }

    public void update_progress (Foreman.Utils.HttpUtils.DownloadContext context) {
        progress_bar.set_fraction ((double) context.total_read / (double) context.total_size);
        progress_label.set_text (get_formatted_progress (context.total_read, context.total_size));
    }

    public void show_downloading () {
        stack.set_visible_child_name ("downloading");
    }

    public void show_extracting () {
        spinner.start ();
        stack.set_visible_child_name ("extracting");
    }

    private string get_formatted_progress (int64 total_read, int64 total_size) {
        double read_mb = ((double) total_read) / 1000000.0;
        double total_mb = ((double) total_size) / 1000000.0;
        return "%.1fMB / %.1fMB".printf (read_mb, total_mb);
    }

}
