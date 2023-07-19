/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Widgets.Dialogs.CreateNewServerDialog : Granite.Dialog {

    private Granite.ValidatedEntry name_entry;
    private Gtk.ListStore java_list_store;
    private Gtk.ListStore bedrock_list_store;
    private Gtk.ComboBox java_edition_version_combo;
    private Gtk.ComboBox bedrock_version_combo;
    private Granite.Widgets.ModeButton server_type_button;
    private Granite.Widgets.ModeButton game_mode_button;
    private Granite.Widgets.ModeButton difficulty_button;
    private Gtk.Stack version_stack;
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
            modal: false
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
            GLib.Value value;
            var server_type = ((Foreman.Models.ServerType) server_type_button.selected);
            if (server_type == Foreman.Models.ServerType.JAVA_EDITION) {
                java_edition_version_combo.get_active_iter (out iter);
                java_list_store.get_value (iter, VersionColumn.VERSION, out value);
            } else {
                bedrock_version_combo.get_active_iter (out iter);
                bedrock_list_store.get_value (iter, VersionColumn.VERSION, out value);
            }
            create_button_clicked (name_entry.get_text (), server_type, value.get_string (), create_properties ());
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

        var server_type_label = new Gtk.Label (_("Server type:")) {
            halign = Gtk.Align.END
        };
        server_type_button = new Granite.Widgets.ModeButton () {
            //  margin = 12
        };
        server_type_button.append_text (Foreman.Models.ServerType.JAVA_EDITION.get_display_string ());
        server_type_button.append_text (Foreman.Models.ServerType.BEDROCK.get_display_string ());
        // TODO: Pull from preferences
        //  server_type_button.selected = 1; // Foreman.Application.java_server_preferences.get_int ("gamemode");

        var version_label = new Gtk.Label (_("Version:")) {
            halign = Gtk.Align.END
        };
        java_edition_version_combo = create_java_edition_version_combo ();
        bedrock_version_combo = create_bedrock_version_combo ();

        version_stack = new Gtk.Stack ();
        version_stack.add_named (java_edition_version_combo, Foreman.Models.ServerType.JAVA_EDITION.to_string ());
        version_stack.add_named (bedrock_version_combo, Foreman.Models.ServerType.BEDROCK.to_string ());

        var game_mode_label = new Gtk.Label (_("Game mode:")) {
            halign = Gtk.Align.END
        };
        game_mode_button = new Granite.Widgets.ModeButton () {
            //  margin = 12
        };
        game_mode_button.append_text (Foreman.Models.GameMode.SURVIVAL.get_display_string ());
        game_mode_button.append_text (Foreman.Models.GameMode.CREATIVE.get_display_string ());
        game_mode_button.append_text (Foreman.Models.GameMode.ADVENTURE.get_display_string ());
        game_mode_button.append_text (Foreman.Models.GameMode.SPECTATOR.get_display_string ());
        game_mode_button.selected = Foreman.Application.java_server_preferences.get_int ("gamemode");

        var difficulty_label = new Gtk.Label (_("Difficulty:")) {
            halign = Gtk.Align.END
        };
        difficulty_button = new Granite.Widgets.ModeButton () {
            //  margin = 12
        };
        difficulty_button.append_text (Foreman.Models.Difficulty.PEACEFUL.get_display_string ());
        difficulty_button.append_text (Foreman.Models.Difficulty.EASY.get_display_string ());
        difficulty_button.append_text (Foreman.Models.Difficulty.NORMAL.get_display_string ());
        difficulty_button.append_text (Foreman.Models.Difficulty.HARD.get_display_string ());
        difficulty_button.selected = Foreman.Application.java_server_preferences.get_int ("difficulty");

        var customize_button = new Gtk.Button () {
            halign = Gtk.Align.CENTER,
            always_show_image = true,
            image = new Gtk.Image.from_icon_name ("preferences-other-symbolic", Gtk.IconSize.BUTTON),
            image_position = Gtk.PositionType.LEFT,
            label = _("Customize…"),
            tooltip_text = _("Show more customization options"),
            width_request = 125 // Make the button a bit larger for emphasis
        };

        form_grid.attach (name_label, 0, 0);
        form_grid.attach (name_entry, 1, 0);
        form_grid.attach (server_type_label, 0, 1);
        form_grid.attach (server_type_button, 1, 1);
        form_grid.attach (version_label, 0, 2);
        form_grid.attach (version_stack, 1, 2);
        form_grid.attach (game_mode_label, 0, 3);
        form_grid.attach (game_mode_button, 1, 3);
        form_grid.attach (difficulty_label, 0, 4);
        form_grid.attach (difficulty_button, 1, 4);
        form_grid.attach (customize_button, 0, 5, 2);

        // Connect to signals to determine whether the connect button should be sensitive
        // Note: Can't use the preferred Granite.ValidatedEntry way, because that seems to limit
        //       one widget per button, not a set of widgets like in this case.
        name_entry.changed.connect (update_create_button);
        server_type_button.mode_changed.connect (() => {
            version_stack.set_visible_child_name (((Foreman.Models.ServerType) server_type_button.selected).to_string ());
        });

        // TODO: Pull from preferences
        server_type_button.selected = Foreman.Models.ServerType.BEDROCK;
        Idle.add (() => {
            version_stack.set_visible_child_name (Foreman.Models.ServerType.BEDROCK.to_string ());
            return false;
        });

        return form_grid;
    }

    private Gtk.ComboBox create_java_edition_version_combo () {
        var latest_release_version = Foreman.Core.Client.get_default ().server_executable_repository.get_latest_java_release_version ();
        //  var latest_snapshot_version = Foreman.Core.Client.get_default ().server_executable_repository.get_latest_snapshot_version ();
        var available_versions = Foreman.Core.Client.get_default ().server_executable_repository.get_downloaded_java_executables ();

        java_list_store = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (string), typeof (int));

        return create_version_combo (latest_release_version, available_versions, java_list_store);
    }

    private Gtk.ComboBox create_bedrock_version_combo () {
        var latest_release_version = Foreman.Core.Client.get_default ().server_executable_repository.get_latest_bedrock_version ();
        var available_versions = Foreman.Core.Client.get_default ().server_executable_repository.get_downloaded_bedrock_executables ();

        bedrock_list_store = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (string), typeof (int));

        return create_version_combo (latest_release_version, available_versions, bedrock_list_store);
    }

    private Gtk.ComboBox create_version_combo (string? latest, Gee.HashMap<string, Foreman.Models.ServerExecutable> available, Gtk.ListStore list_store) {
        // Add the entry for the latest release version available if we don't already have it downloaded
        if (latest != null && !available.has_key (latest)) {
            Gtk.TreeIter iter;
            list_store.append (out iter);
            list_store.set (iter, VersionColumn.ICON, "software-update-available");
            list_store.set (iter, VersionColumn.VERSION, latest);
            list_store.set (iter, VersionColumn.DESCRIPTION, _("(Will be downloaded)"));
        }

        //  // Add the entry for the latest snapshot version available if we don't already have it downloaded
        //  if (latest_release_version != null && !available.has_key (latest_release_version)) {
        //      Gtk.TreeIter iter;
        //      list_store.append (out iter);
        //      list_store.set (iter, VersionColumn.ICON, "software-update-available");
        //      list_store.set (iter, VersionColumn.VERSION, latest_snapshot_version);
        //      list_store.set (iter, VersionColumn.DESCRIPTION, _("(Will be downloaded)"));
        //  }

        // Add all previously downloaded versions
        foreach (var entry in available.entries) {
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

    private Foreman.Models.ServerProperties create_properties () {
        var properties = new Foreman.Models.ServerProperties () {
            difficulty = (Foreman.Models.Difficulty) difficulty_button.selected,
            gamemode = (Foreman.Models.GameMode) game_mode_button.selected,
        };
        return properties;
    }

    public signal void create_button_clicked (string name, Foreman.Models.ServerType server_type, string version, Foreman.Models.ServerProperties properties);

}
