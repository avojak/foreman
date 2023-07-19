/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.Settings.GameplaySettingsPage : Granite.SimpleSettingsPage {

    public const string NAME = "gameplay";

    private Granite.Widgets.ModeButton game_mode_button;
    private Gtk.Label allow_flight_label;
    private Gtk.Switch allow_flight_switch;
    private Granite.Widgets.ModeButton difficulty_button;
    private Gtk.Switch hardcore_switch;
    private Gtk.FileChooserButton resource_pack_file_entry;
    private Gtk.Label require_resource_pack_label;
    private Gtk.Switch require_resource_pack_switch;
    private Gtk.Label resource_pack_prompt_label;
    private Gtk.Entry resource_pack_prompt_entry;

    public GameplaySettingsPage () {
        Object (
            header: null,
            icon_name: "input-gaming",
            title: _("Gameplay"),
            description: _("Default gameplay preferences for new servers"),
            activatable: false,
            expand: true
        );
    }

    construct {
        var game_mode_header_label = new Granite.HeaderLabel (_("Game Mode"));

        game_mode_button = new Granite.Widgets.ModeButton () {
            margin = 12
        };
        game_mode_button.append_text (Foreman.Models.GameMode.SURVIVAL.get_display_string ());
        game_mode_button.append_text (Foreman.Models.GameMode.CREATIVE.get_display_string ());
        game_mode_button.append_text (Foreman.Models.GameMode.ADVENTURE.get_display_string ());
        game_mode_button.append_text (Foreman.Models.GameMode.SPECTATOR.get_display_string ());
        Foreman.Application.java_server_preferences.bind ("gamemode", game_mode_button, "selected", GLib.SettingsBindFlags.DEFAULT);

        var force_game_mode_label = new Gtk.Label (_("Force game mode:")) {
            halign = Gtk.Align.END
        };
        var force_game_mode_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.java_server_preferences.bind ("force-gamemode", force_game_mode_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        allow_flight_label = new Gtk.Label (_("Allow flight:")) {
            halign = Gtk.Align.END
        };
        allow_flight_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.java_server_preferences.bind ("allow-flight", allow_flight_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var difficulty_header_label = new Granite.HeaderLabel (_("Difficulty"));

        difficulty_button = new Granite.Widgets.ModeButton () {
            margin = 12
        };
        difficulty_button.append_text (Foreman.Models.Difficulty.PEACEFUL.get_display_string ());
        difficulty_button.append_text (Foreman.Models.Difficulty.EASY.get_display_string ());
        difficulty_button.append_text (Foreman.Models.Difficulty.NORMAL.get_display_string ());
        difficulty_button.append_text (Foreman.Models.Difficulty.HARD.get_display_string ());
        Foreman.Application.java_server_preferences.bind ("difficulty", difficulty_button, "selected", GLib.SettingsBindFlags.DEFAULT);

        var hardcore_label = new Gtk.Label (_("Hardcore:")) {
            halign = Gtk.Align.END
        };
        hardcore_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.java_server_preferences.bind ("hardcore", hardcore_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var pvp_label = new Gtk.Label (_("Enable PvP:")) {
            halign = Gtk.Align.END
        };
        var pvp_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.java_server_preferences.bind ("pvp", pvp_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var resource_pack_header_label = new Granite.HeaderLabel (_("Resource Pack"));

        resource_pack_file_entry = new Gtk.FileChooserButton (_("Select Resource Pack\u2026"), Gtk.FileChooserAction.OPEN) {
            hexpand = true
        };
        resource_pack_file_entry.file_set.connect (() => {
            update_resource_pack_required_sensitivity ();
            Foreman.Application.java_server_preferences.set_string ("resource-pack", resource_pack_file_entry.get_uri ());
        });
        var remove_resource_pack_button = new Gtk.Button.with_label (_("Remove"));
        remove_resource_pack_button.clicked.connect (() => {
            resource_pack_file_entry.unselect_all ();
            require_resource_pack_switch.set_active (false);
            update_resource_pack_required_sensitivity ();
            Foreman.Application.java_server_preferences.set_string ("resource-pack", "");
        });
        resource_pack_file_entry.set_uri (Foreman.Application.java_server_preferences.get_string ("resource-pack"));
        var resource_pack_grid = new Gtk.Grid () {
            margin = 12,
            hexpand = true,
            column_spacing = 6
        };
        resource_pack_grid.attach (resource_pack_file_entry, 0, 0);
        resource_pack_grid.attach (remove_resource_pack_button, 1, 0);

        require_resource_pack_label = new Gtk.Label (_("Required:")) {
            halign = Gtk.Align.END
        };
        require_resource_pack_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.java_server_preferences.bind ("require-resource-pack", require_resource_pack_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        resource_pack_prompt_label = new Gtk.Label (_("Prompt:")) {
            halign = Gtk.Align.END
        };
        resource_pack_prompt_entry = new Gtk.Entry ();
        Foreman.Application.java_server_preferences.bind ("resource-pack-prompt", resource_pack_prompt_entry, "text", GLib.SettingsBindFlags.DEFAULT);

        var main_grid = new Gtk.Grid () {
            margin_start = 10,
            margin_end = 10,
            margin_bottom = 10,
            column_spacing = 10,
            row_spacing = 10,
            column_homogeneous = false
        };

        main_grid.attach (game_mode_header_label, 0, 0, 2);
        main_grid.attach (game_mode_button, 0, 1, 2);
        main_grid.attach (force_game_mode_label, 0, 2);
        main_grid.attach (force_game_mode_switch, 1, 2);
        main_grid.attach (allow_flight_label, 0, 3);
        main_grid.attach (allow_flight_switch, 1, 3);
        main_grid.attach (difficulty_header_label, 0, 4, 2);
        main_grid.attach (difficulty_button, 0, 5, 2);
        main_grid.attach (hardcore_label, 0, 6);
        main_grid.attach (hardcore_switch, 1, 6);
        main_grid.attach (pvp_label, 0, 7);
        main_grid.attach (pvp_switch, 1, 7);
        main_grid.attach (resource_pack_header_label, 0, 8, 2);
        main_grid.attach (resource_pack_grid, 0, 9, 2);
        main_grid.attach (require_resource_pack_label, 0, 10);
        main_grid.attach (require_resource_pack_switch, 1, 10);
        main_grid.attach (resource_pack_prompt_label, 0, 11);
        main_grid.attach (resource_pack_prompt_entry, 1, 11);

        content_area.attach (main_grid, 0, 0);

        update_allow_flight_sensitivity ();
        update_difficulty_sensitivity ();
        update_resource_pack_required_sensitivity ();

        game_mode_button.mode_changed.connect (update_allow_flight_sensitivity);
        hardcore_switch.notify["active"].connect (update_difficulty_sensitivity);
        require_resource_pack_switch.notify["active"].connect (update_resource_pack_prompt_sensitivity);
    }

    private void update_allow_flight_sensitivity () {
        // The allow-flight property is only applicable when in surival mode
        allow_flight_switch.sensitive = (game_mode_button.selected == Foreman.Models.GameMode.SURVIVAL);
        allow_flight_label.sensitive = (game_mode_button.selected == Foreman.Models.GameMode.SURVIVAL);
    }

    private void update_difficulty_sensitivity () {
        difficulty_button.sensitive = (!hardcore_switch.active);
    }

    private void update_resource_pack_required_sensitivity () {
        require_resource_pack_label.sensitive = resource_pack_file_entry.get_uri () != null;
        require_resource_pack_switch.sensitive = resource_pack_file_entry.get_uri () != null;
        update_resource_pack_prompt_sensitivity ();
    }

    private void update_resource_pack_prompt_sensitivity () {
        resource_pack_prompt_entry.sensitive = (require_resource_pack_switch.active && resource_pack_file_entry.get_uri () != null);
        resource_pack_prompt_label.sensitive = (require_resource_pack_switch.active && resource_pack_file_entry.get_uri () != null);
    }

}
