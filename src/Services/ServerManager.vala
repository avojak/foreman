/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.ServerManager : GLib.Object {

    private static GLib.Once<Foreman.Services.ServerManager> instance;
    public static unowned Foreman.Services.ServerManager get_default () {
        return instance.once (() => { return new Foreman.Services.ServerManager (); });
    }

    public static string servers_dir_path = GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, GLib.Environment.get_user_config_dir (), "servers");

    private Gee.Map<string, Foreman.Services.Server> servers;

    private Gee.List<string> active_server_uuids;
    private GLib.HashTable<string, GLib.Timer> uptime_timers;
    //  private GLib.HashTable<string, double> heap_sizes;

    private ServerManager () {
    }

    construct {
        servers = new Gee.HashMap<string, Foreman.Services.Server> ();

        var servers_dir = GLib.File.new_for_path (servers_dir_path);
        if (!servers_dir.query_exists ()) {
            try {
                servers_dir.make_directory ();
            } catch (GLib.Error e) {
                warning (e.message);
            }
        }

        // Load up from the database
        foreach (var server_context in Foreman.Services.ServerRepository.get_default ().get_servers ()) {
            var server = new Foreman.Services.Server.new_for_context (server_context);
            connect_server_signals (server);
            servers.set (server_context.uuid, server);
        }

        active_server_uuids = new Gee.ArrayList<string> ();
        uptime_timers = new GLib.HashTable<string, GLib.Timer> (GLib.str_hash, GLib.str_equal);
        // Monitor server resource utilization
        //  heap_sizes = new GLib.HashTable<string, double> ();
        //  new GLib.Thread<void> ("resource-monitor", () => {
        //      while (true) {
        //          foreach (var uuid in active_server_uuids) {
        //              Foreman.Core.Client.get_default ().java_execution_service.get_heap_size.begin ("123", (obj, res) => {
        //                  double heap_size = Foreman.Core.Client.get_default ().java_execution_service.get_heap_size.end (res);
        //                  heap_sizes.set (uuid, heap_size);
        //              });
        //          }
        //      }
        //  });
    }

    // TODO: Should probably make this async since there's a file I/O stuff going on the in background
    public Foreman.Services.Server create_server (string name, string server_version, Foreman.Models.ServerProperties properties) {
        // Create the server instance
        var server = new Foreman.Services.Server (name, server_version);
        connect_server_signals (server);
        servers.set (server.context.uuid, server);

        // Copy the template to create the new server directory
        Foreman.Core.Client.get_default ().server_executable_repository.copy_template (server_version, server.context.server_directory);

        // Lay down the properties file
        var target_properties_file = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, server.context.server_directory.get_path (), "server.properties"));
        if (!properties.write_to_file (target_properties_file)) {
            // TODO: Handle this error
        }

        // Persist the state
        // TODO

        server_created (server);

        return server;
    }

    private void connect_server_signals (Foreman.Services.Server server) {
        server.startup_beginning.connect (() => {
            server_starting (server);
        });
        server.startup_progress.connect ((progress) => {
            server_startup_progress (server, progress);
        });
        server.startup_complete.connect (() => {
            uptime_timers.set (server.context.uuid, new GLib.Timer ());
            server_started (server);
        });
        server.startup_failed.connect (() => {
            server_startup_failed (server);
        });
        server.stopped.connect (() => {
            uptime_timers.remove (server.context.uuid);
            server_stopped (server);
        });
        server.errored.connect (() => {
            uptime_timers.remove (server.context.uuid);
            server_errored (server);
        });
        server.stopping.connect (() => {
            uptime_timers.remove (server.context.uuid);
            server_stopping (server);
        });
        server.player_joined.connect ((username) => {
            player_joined (server, username);
        });
        server.player_left.connect ((username) => {
            player_left (server, username);
        });
        server.server_message_logged.connect ((message) => {
            server_message_logged (server, message);
        });
        server.server_warning_logged.connect ((message) => {
            server_warning_logged (server, message);
        });
        server.server_error_logged.connect ((message) => {
            server_error_logged (server, message);
        });
    }

    public void start_server (string uuid) {
        servers.get (uuid).start ();
    }

    public void stop_server (string uuid) {
        servers.get (uuid).stop ();
    }

    public void restart_server (string uuid) {

    }

    public void delete_server (string uuid) {
        Server server;
        servers.unset (uuid, out server);
        server.stop ();
        try {
            Foreman.Utils.FileUtils.delete_recursive (server.context.server_directory);
        } catch (GLib.Error e) {
            warning ("Error while deleting server files: %s", e.message);
        }
        server_deleted (server);
    }

    public void stop_all () {
        foreach (var entry in servers.entries) {
            stop_server (entry.key);
        }
    }

    public void send_command (string uuid, string command) {
        // If it's a stop command, call our stop() function first
        if (is_stop_command (command)) {
            servers.get (uuid).stop ();
            return;
        }
        servers.get (uuid).send_command (command);
    }

    private bool is_stop_command (string command) {
        string normalized_command = command.has_prefix ("/") ? command.substring (1) : command;
        return normalized_command.ascii_down () == "stop";
    }

    public double get_uptime_seconds (string uuid) {
        if (!uptime_timers.contains (uuid)) {
            return -1;
        }
        return uptime_timers.get (uuid).elapsed ();
    }

    public async double? get_heap_size (string uuid) {
        if (!servers.has_key (uuid)) {
            return null;
        }
        string pid = servers.get (uuid).get_pid ();
        if (pid == null) {
            return null;
        }

        GLib.SourceFunc callback = get_heap_size.callback;

        double? result = null;
        new GLib.Thread<void> ("heap-check-%s".printf (pid), () => {
            result = Foreman.Core.Client.get_default ().java_execution_service.get_heap_size (pid);
            Idle.add ((owned) callback);
        });
        yield;

        return result;
    }

    public signal void server_created (Foreman.Services.Server server);
    public signal void server_starting (Foreman.Services.Server server);
    public signal void server_startup_progress (Foreman.Services.Server server, double progress);
    public signal void server_startup_failed (Foreman.Services.Server server);
    public signal void server_started (Foreman.Services.Server server);
    public signal void server_stopping (Foreman.Services.Server server);
    public signal void server_stopped (Foreman.Services.Server server);
    public signal void server_errored (Foreman.Services.Server server);
    public signal void server_deleted (Foreman.Services.Server server);
    public signal void player_joined (Foreman.Services.Server server, string username);
    public signal void player_left (Foreman.Services.Server server, string username);
    public signal void server_message_logged (Foreman.Services.Server server, string message);
    public signal void server_warning_logged (Foreman.Services.Server server, string message);
    public signal void server_error_logged (Foreman.Services.Server server, string message);

}
