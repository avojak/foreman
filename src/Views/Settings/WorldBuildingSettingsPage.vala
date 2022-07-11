/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.Settings.WorldBuildingSettingsPage : Granite.SimpleSettingsPage {

    public const string NAME = "world-building";

    public WorldBuildingSettingsPage () {
        Object (
            header: null,
            icon_name: "applications-development",
            title: _("World Building"),
            description: _("Default world-building preferences for new servers"),
            activatable: false,
            expand: true
        );
    }

    construct {
        var world_type_header_label = new Granite.HeaderLabel (_("World Type"));

        var level_type_button = new Granite.Widgets.ModeButton () {
            margin = 12
        };
        level_type_button.append_text (Foreman.Models.WorldPreset.NORMAL.get_display_string ());
        level_type_button.append_text (Foreman.Models.WorldPreset.FLAT.get_display_string ());
        level_type_button.append_text (Foreman.Models.WorldPreset.LARGE_BIOMES.get_display_string ());
        level_type_button.append_text (Foreman.Models.WorldPreset.AMPLIFIED.get_display_string ());
        level_type_button.append_text (Foreman.Models.WorldPreset.SINGLE_BIOME_SURFACE.get_display_string ());
        Foreman.Application.settings.bind ("level-type", level_type_button, "selected", GLib.SettingsBindFlags.DEFAULT);

        var seed_label = new Gtk.Label (_("Seed:")) {
            halign = Gtk.Align.END
        };
        var seed_entry = new Gtk.Entry ();
        Foreman.Application.settings.bind ("level-seed", seed_entry, "text", GLib.SettingsBindFlags.DEFAULT);

        var max_world_size_label = new Gtk.Label (_("Max world size:")) {
            halign = Gtk.Align.END
        };
        var max_world_size_entry = new Gtk.SpinButton.with_range (1, 29999984, 1);
        Foreman.Application.settings.bind ("max-world-size", max_world_size_entry, "value", GLib.SettingsBindFlags.DEFAULT);

        var generate_structures_label = new Gtk.Label (_("Generate structures:")) {
            halign = Gtk.Align.END
        };
        var generate_structures_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.settings.bind ("generate-structures", generate_structures_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var allow_nether_label = new Gtk.Label (_("Allow Nether:")) {
            halign = Gtk.Align.END
        };
        var allow_nether_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.settings.bind ("allow-nether", allow_nether_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        // TODO: Generator settings

        var spawn_header_label = new Granite.HeaderLabel (_("Entity Spawning"));

        var spawn_npcs_label = new Gtk.Label (_("Spawn NPCs:")) {
            halign = Gtk.Align.END
        };
        var spawn_npcs_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.settings.bind ("spawn-npcs", spawn_npcs_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var spawn_animals_label = new Gtk.Label (_("Spawn animals:")) {
            halign = Gtk.Align.END
        };
        var spawn_animals_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.settings.bind ("spawn-animals", spawn_animals_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var spawn_monsters_label = new Gtk.Label (_("Spawn monsters:")) {
            halign = Gtk.Align.END
        };
        var spawn_monsters_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER
        };
        Foreman.Application.settings.bind ("spawn-monsters", spawn_monsters_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var spawn_protection_label = new Gtk.Label (_("Spawn protection:")) {
            halign = Gtk.Align.END
        };
        var spawn_protection_entry = new Gtk.SpinButton.with_range (0, double.MAX, 1);
        Foreman.Application.settings.bind ("spawn-protection", spawn_protection_entry, "value", GLib.SettingsBindFlags.DEFAULT);

        var main_grid = new Gtk.Grid () {
            margin_start = 10,
            margin_end = 10,
            margin_bottom = 10,
            column_spacing = 10,
            row_spacing = 10,
            column_homogeneous = false
        };

        main_grid.attach (world_type_header_label, 0, 0, 2);
        main_grid.attach (level_type_button, 0, 1, 2);
        main_grid.attach (seed_label, 0, 2);
        main_grid.attach (seed_entry, 1, 2);
        main_grid.attach (max_world_size_label, 0, 3);
        main_grid.attach (max_world_size_entry, 1, 3);
        main_grid.attach (generate_structures_label, 0, 4);
        main_grid.attach (generate_structures_switch, 1, 4);
        main_grid.attach (allow_nether_label, 0, 5);
        main_grid.attach (allow_nether_switch, 1, 5);
        main_grid.attach (spawn_header_label, 0, 6, 2);
        main_grid.attach (spawn_npcs_label, 0, 7);
        main_grid.attach (spawn_npcs_switch, 1, 7);
        main_grid.attach (spawn_animals_label, 0, 8);
        main_grid.attach (spawn_animals_switch, 1, 8);
        main_grid.attach (spawn_monsters_label, 0, 9);
        main_grid.attach (spawn_monsters_switch, 1, 9);
        main_grid.attach (spawn_protection_label, 0, 10);
        main_grid.attach (spawn_protection_entry, 1, 10);

        content_area.attach (main_grid, 0, 0);
    }

}
