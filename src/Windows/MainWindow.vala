/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Windows.MainWindow : Hdy.Window {

    public weak Foreman.Application app { get; construct; }

    private Foreman.Services.ActionManager action_manager;
    private Gtk.AccelGroup accel_group;

    private Foreman.Widgets.Dialogs.CreateNewServerDialog? create_new_server_dialog;
    private Foreman.Widgets.Dialogs.AvailableServerDownloadsDialog? available_server_downloads_dialog;

    private Foreman.Layouts.MainLayout layout;

    public MainWindow (Foreman.Application application) {
        Object (
            title: Constants.APP_NAME,
            application: application,
            app: application,
            border_width: 0,
            resizable: true,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        accel_group = new Gtk.AccelGroup ();
        add_accel_group (accel_group);
        action_manager = new Foreman.Services.ActionManager (app, this);

        layout = new Foreman.Layouts.MainLayout (this);

        add (layout);

        restore_window_position ();

        this.destroy.connect (() => {
            // Do stuff before closing the application
        });

        this.delete_event.connect (before_destroy);

        show_app ();

        set_focus (null);
    }

    private void restore_window_position () {
        move (Foreman.Application.settings.get_int ("pos-x"), Foreman.Application.settings.get_int ("pos-y"));
        resize (Foreman.Application.settings.get_int ("window-width"), Foreman.Application.settings.get_int ("window-height"));
    }

    private void show_app () {
        show_all ();
        present ();
    }

    public bool before_destroy () {
        Foreman.Core.Client.get_default ().server_manager.stop_all ();
        update_position_settings ();
        destroy ();
        return true;
    }

    private void update_position_settings () {
        int width, height, x, y;

        get_size (out width, out height);
        get_position (out x, out y);

        Foreman.Application.settings.set_int ("pos-x", x);
        Foreman.Application.settings.set_int ("pos-y", y);
        Foreman.Application.settings.set_int ("window-width", width);
        Foreman.Application.settings.set_int ("window-height", height);
    }

    public void show_preferences_dialog () {
        
    }

    public void show_create_new_server_dialog () {
        var latest_release = Foreman.Core.Client.get_default ().server_executable_repository.get_latest_release_version ();
        Foreman.Core.Client.get_default ().server_executable_repository.download_server_executable_async.begin (latest_release, null, (obj, res) => {
            GLib.File? server_file = Foreman.Core.Client.get_default ().server_executable_repository.download_server_executable_async.end (res);
            if (server_file == null) {
                debug ("Error downloading server file");
            }

            // Show EULA dialog since this is a new download (Maybe change this to a one-time thing? Should follow how it would be done if running manually)
            if (show_eula_dialog () == Gtk.ResponseType.ACCEPT) {
                if (!Foreman.Core.Client.get_default ().server_executable_repository.accept_eula (latest_release)) {
                    // TODO
                }
            }

            layout.show_library ();

            var server = Foreman.Core.Client.get_default ().server_manager.create_server (latest_release);
            server.start ();
        });

        //  if (create_new_server_dialog == null) {
        //      create_new_server_dialog = new Foreman.Widgets.Dialogs.CreateNewServerDialog (this);
        //      create_new_server_dialog.destroy.connect (() => {
        //          create_new_server_dialog = null;
        //      });
        //      create_new_server_dialog.show_all ();
        //  }
        //  create_new_server_dialog.present ();
    }

    private int show_eula_dialog () {
        var eula_dialog = new Foreman.Widgets.Dialogs.MojangEULADialog (this);
        int response = eula_dialog.run ();
        eula_dialog.destroy ();
        if (response == Gtk.ResponseType.ACCEPT) {
            debug ("EULA accepted");
        } else {
            warning ("EULA rejected");
        }
        return response;
    }

    public void show_available_server_downloads_dialog () {
        //  if (available_server_downloads_dialog == null) {
        //      available_server_downloads_dialog = new Foreman.Widgets.Dialogs.AvailableServerDownloadsDialog (this);
        //      available_server_downloads_dialog.destroy.connect (() => {
        //          available_server_downloads_dialog = null;
        //      });
        //      available_server_downloads_dialog.show_all ();
        //  }
        //  available_server_downloads_dialog.present ();
        var dialog = new Foreman.Widgets.Dialogs.DownloadingDialog (this);
        dialog.show_all ();
        dialog.present ();

        unowned var client = Foreman.Core.Client.get_default ();
        client.server_download_service.retrieve_available_servers.begin ((obj, res) => {
            Foreman.Models.VersionManifest? version_manifest = client.server_download_service.retrieve_available_servers.end (res);
            if (version_manifest == null) {
                // TODO: Error
                return;
            }
            var server_manifest = version_manifest.versions.get (version_manifest.latest.release);
            client.server_download_service.retrieve_version_details.begin (server_manifest.url, (obj, res) => {
                Foreman.Models.VersionDetails? version_details = client.server_download_service.retrieve_version_details.end (res);
                if (version_details == null) {
                    // TODO: Error
                    return;
                }
                var download = version_details.downloads.get (Foreman.Models.VersionDetails.Download.Type.SERVER);
                var download_context = new Foreman.Utils.HttpUtils.DownloadContext (download.url, GLib.File.new_for_path (GLib.Path.build_filename (GLib.Environment.get_home_dir (), "Downloads", "minecraft-server.jar")), download.size);

                download_context.progress.connect ((progress) => {
                    Idle.add (() => {
                        dialog.update_progress (download_context);
                        return false;
                    });
                });

                new GLib.Thread<bool> ("download-server", () => {
                    try {
                        Foreman.Utils.HttpUtils.download_file (download_context, null);
                    } catch (GLib.Error e) {
                        warning (e.message);
                    }
                    return true;
                });
            });
        });
        
    }

}
