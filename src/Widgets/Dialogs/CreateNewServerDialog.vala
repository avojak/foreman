/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Widgets.Dialogs.CreateNewServerDialog : Granite.Dialog {

    private Granite.ValidatedEntry name_entry;
    private Gtk.ListStore list_store;
    private Gtk.ComboBox version_combo;
    private Gtk.Button create_button;

    public enum VersionColumn {
        ICON, VERSION, DESCRIPTION;
    }

    public CreateNewServerDialog (Foreman.Windows.MainWindow main_window) {
        Object (
            deletable: false,
            resizable: false,
            title: _("Create Server"),
            transient_for: main_window,
            modal: true
        );
    }

    construct {
        var body = get_content_area ();
        body.add (create_header ());
        body.add (create_form ());

        // Add action buttons
        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.clicked.connect (() => {
            close ();
        });

        create_button = new Gtk.Button.with_label (_("Create")) {
            sensitive = false
        };
        create_button.get_style_context ().add_class ("suggested-action");
        create_button.clicked.connect (() => {
            Gtk.TreeIter iter;
            version_combo.get_active_iter (out iter);
            GLib.Value value;
            list_store.get_value (iter, VersionColumn.VERSION, out value);
            create_button_clicked (name_entry.get_text (), value.get_string ());
        });

        add_action_widget (cancel_button, 0);
        add_action_widget (create_button, 1);
    }

    private Gtk.Grid create_header () {
        var header_grid = new Gtk.Grid () {
            margin_start = 30,
            margin_end = 30,
            margin_bottom = 10,
            column_spacing = 10
        };

        var header_image = new Gtk.Image.from_icon_name (Constants.APP_ID + ".network-server-new", Gtk.IconSize.DIALOG);

        var header_title = new Gtk.Label (_("Create Server")) {
            halign = Gtk.Align.START,
            hexpand = true,
            margin_end = 10
        };
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.set_line_wrap (true);

        header_grid.attach (header_image, 0, 0);
        header_grid.attach (header_title, 1, 0);

        return header_grid;
    }

    private Gtk.Grid create_form () {
        var form_grid = new Gtk.Grid () {
            margin = 30,
            row_spacing = 12,
            column_spacing = 10
        };

        var name_label = new Gtk.Label (_("Name:")) {
            halign = Gtk.Align.END
        };
        name_entry = new Granite.ValidatedEntry () {
            hexpand = true,
            placeholder_text = _("My Server")
        };
        name_entry.changed.connect (() => {
            name_entry.is_valid = name_entry.text_length > 0;
        });

        var version_label = new Gtk.Label (_("Version:")) {
            halign = Gtk.Align.END
        };
        version_combo = create_version_combo ();

        var game_mode_label = new Gtk.Label (_("Game mode:")) {
            halign = Gtk.Align.END
        };
        var game_mode_button = new Granite.Widgets.ModeButton () {
            //  margin = 12
        };
        game_mode_button.append_text (Foreman.Models.GameMode.SURVIVAL.get_display_string ());
        game_mode_button.append_text (Foreman.Models.GameMode.CREATIVE.get_display_string ());
        game_mode_button.append_text (Foreman.Models.GameMode.ADVENTURE.get_display_string ());
        game_mode_button.append_text (Foreman.Models.GameMode.SPECTATOR.get_display_string ());
        game_mode_button.selected = Foreman.Application.settings.get_int ("gamemode");

        var difficulty_label = new Gtk.Label (_("Difficulty:")) {
            halign = Gtk.Align.END
        };
        var difficulty_button = new Granite.Widgets.ModeButton () {
            //  margin = 12
        };
        difficulty_button.append_text (Foreman.Models.Difficulty.PEACEFUL.get_display_string ());
        difficulty_button.append_text (Foreman.Models.Difficulty.EASY.get_display_string ());
        difficulty_button.append_text (Foreman.Models.Difficulty.NORMAL.get_display_string ());
        difficulty_button.append_text (Foreman.Models.Difficulty.HARD.get_display_string ());
        difficulty_button.selected = Foreman.Application.settings.get_int ("difficulty");

        form_grid.attach (name_label, 0, 0);
        form_grid.attach (name_entry, 1, 0);
        form_grid.attach (version_label, 0, 1);
        form_grid.attach (version_combo, 1, 1);
        form_grid.attach (game_mode_label, 0, 2);
        form_grid.attach (game_mode_button, 1, 2);
        form_grid.attach (difficulty_label, 0, 3);
        form_grid.attach (difficulty_button, 1, 3);

        // Connect to signals to determine whether the connect button should be sensitive
        // Note: Can't use the preferred Granite.ValidatedEntry way, because that seems to limit
        //       one widget per button, not a set of widgets like in this case.
        name_entry.changed.connect (update_create_button);

        return form_grid;
    }

    private Gtk.ComboBox create_version_combo () {
        var latest_release_version = Foreman.Core.Client.get_default ().server_executable_repository.get_latest_release_version ();
        //  var latest_snapshot_version = Foreman.Core.Client.get_default ().server_executable_repository.get_latest_snapshot_version ();
        var available_versions = Foreman.Core.Client.get_default ().server_executable_repository.get_downloaded_executables ();

        list_store = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (string), typeof (int));

        // Add the entry for the latest release version available if we don't already have it downloaded
        if (latest_release_version != null && !available_versions.has_key (latest_release_version)) {
            Gtk.TreeIter iter;
            list_store.append (out iter);
            list_store.set (iter, VersionColumn.ICON, "software-update-available");
            list_store.set (iter, VersionColumn.VERSION, latest_release_version);
            list_store.set (iter, VersionColumn.DESCRIPTION, _("(Will be downloaded)"));
        }

        //  // Add the entry for the latest snapshot version available if we don't already have it downloaded
        //  if (latest_release_version != null && !available_versions.has_key (latest_release_version)) {
        //      Gtk.TreeIter iter;
        //      list_store.append (out iter);
        //      list_store.set (iter, VersionColumn.ICON, "software-update-available");
        //      list_store.set (iter, VersionColumn.VERSION, latest_snapshot_version);
        //      list_store.set (iter, VersionColumn.DESCRIPTION, _("(Will be downloaded)"));
        //  }

        // Add all previously downloaded versions
        foreach (var entry in available_versions.entries) {
            Gtk.TreeIter iter;
            list_store.append (out iter);
            list_store.set (iter, VersionColumn.ICON, "process-completed-symbolic");
            list_store.set (iter, VersionColumn.VERSION, entry.key);
        }

        var combo = new Gtk.ComboBox.with_model (list_store);
        var cell_renderer_pixbuf = new Gtk.CellRendererPixbuf ();
        combo.pack_start (cell_renderer_pixbuf, false);
        combo.set_attributes (cell_renderer_pixbuf, "icon_name", VersionColumn.ICON);
        var details_cell_renderer_text = new Gtk.CellRendererText () {
            style = Pango.Style.ITALIC
        };
        combo.pack_end (details_cell_renderer_text, false);
        combo.set_attributes (details_cell_renderer_text, "text", VersionColumn.DESCRIPTION);
        var version_cell_renderer_text = new Gtk.CellRendererText () {
            xpad = 6
        };
        combo.pack_end (version_cell_renderer_text, false);
        combo.set_attributes (version_cell_renderer_text, "text", VersionColumn.VERSION);

        combo.set_active (0);
        
        return combo;
    }

    private void update_create_button () {
        create_button.sensitive = name_entry.is_valid;
    }

    public signal void create_button_clicked (string name, string version);

}