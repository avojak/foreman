/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.ServerRepository : GLib.Object {

    private static GLib.Once<Foreman.Services.ServerRepository> instance;
    public static unowned Foreman.Services.ServerRepository get_default () {
        return instance.once (() => { return new Foreman.Services.ServerRepository (); });
    }

    public Foreman.Services.SQLClient sql_client { get; construct; }

    private Gee.Map<string, Foreman.Services.Server.Context>? server_contexts;

    private ServerRepository () {
        Object (
            sql_client: Foreman.Services.SQLClient.get_default ()
        );
    }

    construct {
        // Load up contexts from the database
        server_contexts = new Gee.HashMap<string, Foreman.Services.Server.Context> ();
        lock (sql_client) {
            foreach (var server_context in sql_client.get_servers ()) {
                server_contexts.set (server_context.uuid, server_context);
            }
        }
    }

    public void on_server_created (Foreman.Services.Server server) {
        server_contexts.set (server.context.uuid, server.context);
        lock (sql_client) {
            sql_client.insert_server (server.context);
        }
    }

    public void on_server_deleted (Foreman.Services.Server server) {
        server_contexts.unset (server.context.uuid);
        lock (sql_client) {
            sql_client.remove_server (server.context);
        }
    }

    public void on_server_state_changed (Foreman.Services.Server server) {
        //  lock (sql_client) {
        //      sql_client.update_server (server.context);
        //  }
    }

    public Gee.Collection<Foreman.Services.Server.Context> get_servers () {
        return server_contexts.values;
    }

}
