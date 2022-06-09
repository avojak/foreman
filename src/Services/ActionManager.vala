/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public class Foreman.Services.ActionManager : GLib.Object {

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_QUIT = "action_quit";
    public const string ACTION_PREFERENCES = "action_preferences";
    public const string ACTION_TOGGLE_SIDEBAR = "action_toggle_sidebar";
    public const string ACTION_CREATE_NEW_SERVER = "action_create_new_server";
    //  public const string ACTION_AVAILABLE_DOWNLOADS = "action_available_downloads";
    public const string ACTION_CONFIGURE_SELECTED_SERVER = "action_configure_selected_server";
    public const string ACTION_DELETE_SELECTED_SERVER = "action_delete_selected_server";
    public const string ACTION_HELP = "action_help";

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_QUIT, action_quit },
        { ACTION_PREFERENCES, action_preferences },
        { ACTION_TOGGLE_SIDEBAR, action_toggle_sidebar },
        { ACTION_CREATE_NEW_SERVER, action_create_new_server },
        //  { ACTION_AVAILABLE_DOWNLOADS, action_available_downloads },
        { ACTION_CONFIGURE_SELECTED_SERVER, action_configure_selected_server },
        { ACTION_DELETE_SELECTED_SERVER, action_delete_selected_server },
        { ACTION_HELP, action_help }
    };

    private static Gee.MultiMap<string, string> accelerators;

    public unowned Foreman.Application application { get; construct; }
    public unowned Foreman.Windows.MainWindow window { get; construct; }

    private GLib.SimpleActionGroup action_group;

    public ActionManager (Foreman.Application application, Foreman.Windows.MainWindow window) {
        Object (
            application: application,
            window: window
        );
    }

    static construct {
        accelerators = new Gee.HashMultiMap<string, string> ();
        accelerators.set (ACTION_QUIT, "<Control>q");
        accelerators.set (ACTION_PREFERENCES, "<Control><Shift>p");
        accelerators.set (ACTION_TOGGLE_SIDEBAR, "<Control>backslash");
        accelerators.set (ACTION_HELP, "<Control>h");
    }

    construct {
        action_group = new GLib.SimpleActionGroup ();
        action_group.add_action_entries (ACTION_ENTRIES, this);
        window.insert_action_group ("win", action_group);

        foreach (var action in accelerators.get_keys ()) {
            var accelerators_array = accelerators[action].to_array ();
            accelerators_array += null;
            application.set_accels_for_action (ACTION_PREFIX + action, accelerators_array);
        }
    }

    public static void action_from_group (string action_name, GLib.ActionGroup action_group, GLib.Variant? parameter = null) {
        action_group.activate_action (action_name, parameter);
    }

    private void action_quit () {
        window.before_destroy ();
    }

    private void action_preferences () {
        window.show_preferences_dialog ();
    }

    private void action_toggle_sidebar () {
        window.toggle_sidebar ();
    }

    private void action_create_new_server () {
        window.show_create_new_server_dialog ();
    }

    //  private void action_available_downloads () {
    //      window.show_available_server_downloads_dialog ();
    //  }

    private void action_configure_selected_server () {
        window.configure_selected_server ();
    }

    private void action_delete_selected_server () {
        window.delete_selected_server ();
    }

    private void action_help () {
        window.show_help_dialog ();
    }

}
