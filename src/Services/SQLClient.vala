/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.SQLClient : GLib.Object {

    private const string DATABASE_FILENAME = "foreman.db";

    private Sqlite.Database database;

    private static Foreman.Services.SQLClient _instance = null;
    public static Foreman.Services.SQLClient instance {
        get {
            if (_instance == null) {
                _instance = new Foreman.Services.SQLClient ();
            }
            return _instance;
        }
    }

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
                "hostname" TEXT NOT NULL,
                "port" INTEGER NOT NULL,
                "nickname" TEXT NOT NULL,
                "username" TEXT NOT NULL,
                "realname" TEXT NOT NULL,
                "auth_method" TEXT NOT NULL,
                "tls" BOOL NOT NULL,
                "enabled" BOOL NOT NULL,
                "network_name" TEXT
            );
            CREATE TABLE IF NOT EXISTS "channels" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "server_id" INTEGER,
                "channel" TEXT,
                "enabled" BOOL,
                "favorite" BOOL
            );
            CREATE TABLE IF NOT EXISTS "server_identities" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "host" TEXT,
                "certificate_pem" TEXT,
                "is_accepted" BOOL
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

    //  private void set_user_version (int user_version) {
    //      var sql = @"PRAGMA user_version = $user_version";
    //      Sqlite.Statement statement;
    //      if (database.prepare_v2 (sql, sql.length, out statement) != Sqlite.OK) {
    //          log_database_error (database.errcode (), database.errmsg ());
    //          return;
    //      }
    //      string err_msg;
    //      int ec = database.exec (statement.expanded_sql (), null, out err_msg);
    //      if (ec != Sqlite.OK) {
    //          log_database_error (ec, err_msg);
    //          debug ("SQL statement: %s", statement.expanded_sql ());
    //      }
    //      statement.reset ();
    //  }

    private static void log_database_error (int errcode, string errmsg) {
        warning ("Database error: %d: %s", errcode, errmsg);
    }

}
