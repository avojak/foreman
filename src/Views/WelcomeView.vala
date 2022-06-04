/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Views.Welcome : Granite.Widgets.Welcome {

    public const string NAME = "welcome";

    private static Gtk.CssProvider provider;

    public unowned Foreman.Windows.MainWindow window { get; construct; }

    public Welcome (Foreman.Windows.MainWindow window) {
        Object (
            window: window,
            title: _("Welcome to Foreman"),
            subtitle: _("Run and manage Minecraft servers")
        );
    }

    static construct {
        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/avojak/foreman/WelcomeView.css");
    }

    construct {
        unowned Gtk.StyleContext style_context = get_style_context ();
        style_context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        valign = Gtk.Align.FILL;
        halign = Gtk.Align.FILL;
        vexpand = true;

        // TODO: To get version info: https://launchermeta.mojang.com/mc/game/version_manifest.json

        // TODO: See https://minecraft.fandom.com/wiki/Tutorials/Setting_up_a_server for extra config options

        // TODO: Instead, simply have an option to connect to a new server. We
        //       can maybe have a separate star icon for favoriting?
        //  append ("document-open", _("Choose Server Executable"), _("Choose a previously-downloaded server executable"));
        //  append ("browser-download", _("Download Latest Server Executable"), _("Download the latest server executable from Mojang"));
        //  append ("document-open-recent", _("Recently Connected"), _("Connect to a recently connected server"));

        append (Constants.APP_ID + ".network-server-new", _("Create New Server"), _("Configure and start a new server"));

        activated.connect (index => {
            switch (index) {
                case 0:
                    Foreman.Services.ActionManager.action_from_group (Foreman.Services.ActionManager.ACTION_CREATE_NEW_SERVER, window.get_action_group ("win"));
                    break;
                //  case 1:
                    //  try {
                    //      Gtk.show_uri_on_window (null, "https://minecraft.net/download/server", Gdk.CURRENT_TIME);
                    //  } catch (GLib.Error e) {
                    //      warning (e.message);
                    //  }

                    //  Foreman.Core.Client.get_default ().server_download_service.retrieve_available_servers.begin ();

                    //  Foreman.Services.ActionManager.action_from_group (Foreman.Services.ActionManager.ACTION_AVAILABLE_DOWNLOADS, window.get_action_group ("win"));
                    //  break;
                default:
                    assert_not_reached ();
            }
        });
    }

}
