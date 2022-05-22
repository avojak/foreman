/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Models.ServerProperties : GLib.Object {

    public Foreman.Models.ServerProperty<bool> allow_flight = new Foreman.Models.BooleanServerProperty ("allow-flight");
    public Foreman.Models.ServerProperty<bool> allow_nether = new Foreman.Models.BooleanServerProperty ("allow-nether");
    public Foreman.Models.ServerProperty<bool> broadcast_console_to_ops = new Foreman.Models.BooleanServerProperty ("broadcast-console-to-ops");
    public Foreman.Models.ServerProperty<bool> broadcast_rcon_to_ops = new Foreman.Models.BooleanServerProperty ("broadcast-rcon-to-ops");
    public Foreman.Models.ServerProperty<bool> enable_command_block = new Foreman.Models.BooleanServerProperty ("enable-command-block");
    public Foreman.Models.ServerProperty<bool> enable_jmx_monitoring = new Foreman.Models.BooleanServerProperty ("enable-jmx-monitoring");
    public Foreman.Models.ServerProperty<bool> enable_query = new Foreman.Models.BooleanServerProperty ("enable-query");
    public Foreman.Models.ServerProperty<bool> enable_rcon = new Foreman.Models.BooleanServerProperty ("enable-rcon");
    public Foreman.Models.ServerProperty<bool> enable_status = new Foreman.Models.BooleanServerProperty ("enable-status");
    //  public Foreman.Models.ServerProperty<bool> enable_secure_profile = new Foreman.Models.BooleanServerProperty ("enable-secure-profile");
    public Foreman.Models.ServerProperty<bool> enforce_whitelist = new Foreman.Models.BooleanServerProperty ("enforce-whitelist");
    public Foreman.Models.ServerProperty<bool> force_gamemode = new Foreman.Models.BooleanServerProperty ("force-gamemode");
    public Foreman.Models.ServerProperty<bool> generate_structures = new Foreman.Models.BooleanServerProperty ("generate-structures");
    public Foreman.Models.ServerProperty<bool> hardcore = new Foreman.Models.BooleanServerProperty ("hardcore");
    public Foreman.Models.ServerProperty<bool> hide_online_players = new Foreman.Models.BooleanServerProperty ("hide-online-players");
    public Foreman.Models.ServerProperty<bool> online_mode = new Foreman.Models.BooleanServerProperty ("online-mode");

    //  public string allow_flight { get; set; }
    //  public string allow_nether { get; set; }
    //  public string broadcast_console_to_ops { get; set; }
    //  public string broadcast_rcon_to_ops { get; set; }
    public string difficulty { get; set; }
    //  public string enable_command_block { get; set; }
    //  public string enable_query { get; set; }
    //  public string enable_rcon { get; set; }
    //  public string enable_status { get; set; }
    //  public string enforce_whitelist { get; set; }
    public string entity_broadcast_range_percentage { get; set; }
    //  public string force_gamemode { get; set; }
    public string function_permission_level { get; set; }
    public string gamemode { get; set; }
    //  public string generate_structures { get; set; }
    public string generator_settings { get; set; }
    //  public string hardcore { get; set; }
    //  public string hide_online_players { get; set; }
    public string level_name { get; set; }
    public string level_seed { get; set; }
    public string level_type { get; set; }
    public string max_players { get; set; }
    public string max_tick_time { get; set; }
    public string max_world_size { get; set; }
    public string motd { get; set; }
    public string network_compression_threshold { get; set; }
    //  public string online_mode { get; set; }
    public string op_permission_level { get; set; }
    public string player_idle_timeout { get; set; }
    public string prevent_proxy_connections { get; set; }
    public string pvp { get; set; }
    public string query_port { get; set; }
    public string rate_limit { get; set; }
    public string rcon_password { get; set; }
    public string rcon_port { get; set; }
    public string require_resource_pack { get; set; }
    public string resource_pack { get; set; }
    public string resource_pack_prompt { get; set; }
    public string resource_pack_sha1 { get; set; }
    public string server_ip { get; set; }
    public string server_port { get; set; }
    public string simulation_distance { get; set; }
    public string spawn_animals { get; set; }
    public string spawn_monsters { get; set; }
    public string spawn_npcs { get; set; }
    public string spawn_protection { get; set; }
    public string sync_chunk_writes { get; set; }
    public string text_filtering_config { get; set; }
    public string use_native_transport { get; set; }
    public string view_distance { get; set; }
    public string white_list { get; set; }

    public bool write_to_file (GLib.File file) {
        // TODO
        return true;
    }

}
