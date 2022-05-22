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

    private ServerManager () {
        var servers_dir = GLib.File.new_for_path (servers_dir_path);
        if (!servers_dir.query_exists ()) {
            try {
                servers_dir.make_directory ();
            } catch (GLib.Error e) {
                warning (e.message);
            }
        }
    }

    construct {
        servers = new Gee.HashMap<string, Foreman.Services.Server> ();
    }

    // TODO: Should probably make this async since there's a file I/O stuff going on the in background
    public Foreman.Services.Server create_server (string server_version) {
        // Create the server instance
        var server = new Foreman.Services.Server (server_version);
        servers.set (server.context.uuid, server);

        // Copy the template to create the new server directory
        Foreman.Core.Client.get_default ().server_executable_repository.copy_template (server_version, server.context.server_directory);

        // Lay down the properties file
        // TODO

        // Persist the state
        // TODO

        return server;
    }

    public void start_server (string uuid) {
        servers.get (uuid).start ();
    }

    public void stop_server (string uuid) {
        servers.get (uuid).stop ();
    }

    public void restart_server (string uuid) {

    }

    public void stop_all () {
        foreach (var entry in servers.entries) {
            stop_server (entry.key);
        }
    }

}