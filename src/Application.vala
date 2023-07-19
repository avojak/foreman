/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Application : Gtk.Application {

    private static GLib.Once<Foreman.Application> instance;
    public static unowned Foreman.Application get_instance () {
        return instance.once (() => { return new Foreman.Application (); });
    }

    public static GLib.Settings settings;
    public static GLib.Settings java_server_preferences;
    public static GLib.Settings bedrock_server_preferences;

    private Foreman.Windows.MainWindow main_window;

    public Application () {
        Object (
            application_id: Constants.APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        info ("%s version: %s", Constants.APP_ID, Constants.VERSION);
        info ("Kernel version: %s", Posix.utsname ().release);
    }

    construct {
        settings = new GLib.Settings (Constants.APP_ID);
        java_server_preferences = new GLib.Settings (Constants.APP_ID + ".java");
        bedrock_server_preferences = new GLib.Settings (Constants.APP_ID + ".bedrock");
        startup.connect ((handler) => {
            Hdy.init ();
        });
    }

    private void add_new_window () {
        this.main_window = new Foreman.Windows.MainWindow (this);
        main_window.destroy.connect (() => {
            main_window = null;
        });
        this.add_window (main_window);
    }

    protected override void activate () {
        force_elementary_style ();

        // Respect the system color scheme preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        var client = Foreman.Core.Client.get_default ();

        this.add_new_window ();

        client.server_executable_repository.refresh.begin ();

        //  var socket_client = new GLib.SocketClient ();
        //  try {
        //      var connection = socket_client.connect (new GLib.NetworkAddress ("launchermeta.mojang.com", 443));
        //      debug (((GLib.InetSocketAddress) connection.get_local_address ()).get_address ().to_string ());
        //  } catch (GLib.Error e) {
        //      warning (e.message);
        //  }

        //  debug (address.get_family ().to_string ());

        //  client.server_download_service.retrieve_available_servers.begin ((obj, res) => {
        //      Foreman.Models.VersionManifest? version_manifest = client.server_download_service.retrieve_available_servers.end (res);
        //      if (version_manifest == null) {
        //          return;
        //      }

        //  });
    }

    /**
     * Sets the app's icons, cursors, and stylesheet to elementary defaults.
     * See: https://github.com/elementary/granite/pull/501
     */
    private void force_elementary_style () {
        const string STYLESHEET_PREFIX = "io.elementary.stylesheet";
        unowned var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_cursor_theme_name = "elementary";
        gtk_settings.gtk_icon_theme_name = "elementary";

        if (!gtk_settings.gtk_theme_name.has_prefix (STYLESHEET_PREFIX)) {
            gtk_settings.gtk_theme_name = string.join (".", STYLESHEET_PREFIX, "blueberry");
        }
    }

    public Foreman.Windows.MainWindow get_main_window () {
        return main_window;
    }

    public static int main (string[] args) {
        var app = Foreman.Application.get_instance ();
        return app.run (args);
    }

}
