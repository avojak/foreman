/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.SQLClient : GLib.Object {

    private static GLib.Once<Foreman.Services.SQLClient> instance;
    public static unowned Foreman.Services.SQLClient get_default () {
        return instance.once (() => { return new Foreman.Services.SQLClient (); });
    }

    private const string DATABASE_FILENAME = "foreman.db";

    private Sqlite.Database database;

    private SQLClient () {
        info ("Database file: %s", GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, GLib.Environment.get_user_config_dir (), DATABASE_FILENAME));
        initialize_database ();
    }

    private void initialize_database () {
        var db_file = GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, GLib.Environment.get_user_config_dir (), DATABASE_FILENAME);
        if (Sqlite.Database.open_v2 (db_file, out database) != Sqlite.OK) {
            // TODO: Show error message that we cannot proceed
            critical ("Can't open database: %d: %s", database.errcode (), database.errmsg ());
            return;
        }
        initialize_tables ();
    }

    private void initialize_tables () {
        string sql = """
            CREATE TABLE IF NOT EXISTS "servers" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "name" TEXT NOT NULL,
                "uuid" TEXT NOT NULL,
                "version" TEXT NOT NULL,
                "path" TEXT NOT NULL,
                "state" TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS "server_executables" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "version" TEXT NOT NULL,
                "type" TEXT NOT NULL,
                "path" TEXT NOT NULL
            );
            """;
        database.exec (sql);

        do_upgrades ();
    }

    private void do_upgrades () {
        int? user_version = get_user_version ();
        if (user_version == null) {
            warning ("Null user_version, skipping upgrades");
            return;
        }
        if (user_version == 0) {
            debug ("SQLite user_version: %d, no upgrades to perform", user_version);
        }
    }

    private int? get_user_version () {
        var sql = "PRAGMA user_version";
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return null;
        }

        if (statement.step () != Sqlite.ROW) {
            return null;
        }
        var num_columns = statement.column_count ();
        int? user_version = null;
        for (int i = 0; i < num_columns; i++) {
            switch (statement.column_name (i)) {
                case "user_version":
                    user_version = statement.column_int (i);
                    break;
                default:
                    break;
            }
        }
        statement.reset ();
        return user_version;
    }

    public void insert_server (Foreman.Services.Server.Context server_context) {
        var sql = """
            INSERT INTO servers (uuid, name, version, path, state)
            VALUES ($UUID, $NAME, $VERSION, $PATH, $STATE);
        """;

        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return;
        }

        statement.bind_text (1, server_context.uuid);
        statement.bind_text (2, server_context.name);
        statement.bind_text (3, server_context.server_version);
        statement.bind_text (4, server_context.server_directory.get_path ());
        statement.bind_text (5, server_context.state.to_string ());

        string errmsg;
        int ec = database.exec (statement.expanded_sql (), null, out errmsg);
        if (ec != Sqlite.OK) {
            log_database_error (ec, errmsg);
            debug ("SQL statement: %s", statement.expanded_sql ());
        }
        statement.reset ();
    }

    public Gee.List<Foreman.Services.Server.Context> get_servers () {
        var servers = new Gee.ArrayList<Foreman.Services.Server.Context> ();

        var sql = "SELECT * FROM servers;";
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return servers;
        }

        while (statement.step () == Sqlite.ROW) {
            var server = parse_server_row (statement);
            servers.add (server);
        }
        statement.reset ();

        return servers;
    }

    public void remove_server (Foreman.Services.Server.Context server_context) {
        var sql = "DELETE FROM servers WHERE uuid = $UUID;";
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return;
        }
        statement.bind_text (1, server_context.uuid);

        string err_msg;
        int ec = database.exec (statement.expanded_sql (), null, out err_msg);
        if (ec != Sqlite.OK) {
            log_database_error (ec, err_msg);
            debug ("SQL statement: %s", statement.expanded_sql ());
        }
        statement.reset ();
    }

    public void insert_server_executable (Foreman.Models.ServerExecutable executable) {
        var sql = """
            INSERT INTO server_executables (version, type, path)
            VALUES ($VERSION, $TYPE, $PATH);
        """;

        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return;
        }

        statement.bind_text (1, executable.version);
        statement.bind_text (2, executable.directory.get_path ());
        statement.bind_text (3, executable.version_type.to_string ());

        string errmsg;
        int ec = database.exec (statement.expanded_sql (), null, out errmsg);
        if (ec != Sqlite.OK) {
            log_database_error (ec, errmsg);
            debug ("SQL statement: %s", statement.expanded_sql ());
        }
        statement.reset ();
    }

    public Gee.List<Foreman.Models.ServerExecutable> get_server_executables () {
        var executables = new Gee.ArrayList<Foreman.Models.ServerExecutable> ();

        var sql = "SELECT * FROM server_executables;";
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return executables;
        }

        while (statement.step () == Sqlite.ROW) {
            var executable = parse_server_executable_row (statement);
            executables.add (executable);
        }
        statement.reset ();

        return executables;
    }

    public void remove_server_executable (string version) {
        var sql = "DELETE FROM server_executables WHERE version = $VERSION;";
        Sqlite.Statement statement;
        if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
            log_database_error (database.errcode (), database.errmsg ());
            return;
        }
        statement.bind_text (1, version);

        string err_msg;
        int ec = database.exec (statement.expanded_sql (), null, out err_msg);
        if (ec != Sqlite.OK) {
            log_database_error (ec, err_msg);
            debug ("SQL statement: %s", statement.expanded_sql ());
        }
        statement.reset ();
    }

    private Foreman.Services.Server.Context parse_server_row (Sqlite.Statement statement) {
        var num_columns = statement.column_count ();
        var context = new Foreman.Services.Server.Context ();
        for (int i = 0; i < num_columns; i++) {
            switch (statement.column_name (i)) {
                case "uuid":
                    context.uuid = statement.column_text (i);
                    break;
                case "name":
                    context.name = statement.column_text (i);
                    break;
                case "version":
                    context.server_version = statement.column_text (i);
                    break;
                case "path":
                    context.server_directory = GLib.File.new_for_path (statement.column_text (i));
                    break;
                case "state":
                    EnumClass enumc = (EnumClass) typeof (Foreman.Services.Server.State).class_ref ();
                    unowned EnumValue? eval = enumc.get_value_by_name (statement.column_text (i));
                    if (eval == null) {
                        // TODO: Handle this 
                        break;
                    }
                    context.state = (Foreman.Services.Server.State) eval.value;
                    break;
                default:
                    break;
            }
        }
        return context;
    }

    private Foreman.Models.ServerExecutable parse_server_executable_row (Sqlite.Statement statement) {
        var num_columns = statement.column_count ();
        var executable = new Foreman.Models.ServerExecutable ();
        for (int i = 0; i < num_columns; i++) {
            switch (statement.column_name (i)) {
                case "version":
                    executable.version = statement.column_text (i);
                    break;
                case "path":
                    executable.directory = GLib.File.new_for_path (statement.column_text (i));
                    break;
                case "type":
                    EnumClass enumc = (EnumClass) typeof (Foreman.Models.VersionDetails.Type).class_ref ();
                    unowned EnumValue? eval = enumc.get_value_by_name (statement.column_text (i));
                    if (eval == null) {
                        // TODO: Handle this 
                        break;
                    }
                    executable.version_type = (Foreman.Models.VersionDetails.Type) eval.value;
                    break;
                default:
                    break;
            }
        }
        return executable;
    }

    private void log_database_error (int errcode, string errmsg) {
        warning ("Database error: %d: %s", errcode, errmsg);
    }

}
