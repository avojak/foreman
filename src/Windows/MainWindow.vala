/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Windows.MainWindow : Hdy.Window {

    public weak Foreman.Application app { get; construct; }

    private Foreman.Services.ActionManager action_manager;
    private Gtk.AccelGroup accel_group;

    private Foreman.Widgets.Dialogs.PreferencesDialog? preferences_dialog;
    private Foreman.Widgets.Dialogs.CreateNewServerDialog? create_new_server_dialog;
    private Foreman.Widgets.Dialogs.ConfigureServerDialog? configure_server_dialog;
    private Foreman.Widgets.Dialogs.AvailableServerDownloadsDialog? available_server_downloads_dialog;
    private Foreman.Widgets.Dialogs.HelpDialog? help_dialog;

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
        layout.start_button_clicked.connect (on_start_button_clicked);
        layout.stop_button_clicked.connect (on_stop_button_clicked);
        //  layout.delete_button_clicked.connect (on_delete_button_clicked);
        //  layout.delete_button_clicked.connect (on_configure_button_clicked);
        layout.command_to_send.connect (on_command_to_send);

        // Populate the layout
        foreach (var server in Foreman.Core.Client.get_default ().server_repository.get_servers ()) {
            layout.add_server_to_library (server);
            layout.set_sidebar_visible (true);
        }

        add (layout);

        restore_window_position ();

        this.destroy.connect (() => {
            // Do stuff before closing the application
        });

        this.delete_event.connect (before_destroy);

        Foreman.Core.Client.get_default ().server_manager.server_created.connect (on_server_created);
        Foreman.Core.Client.get_default ().server_manager.server_starting.connect (on_server_starting);
        Foreman.Core.Client.get_default ().server_manager.server_startup_progress.connect (on_server_startup_progress);
        Foreman.Core.Client.get_default ().server_manager.server_started.connect (on_server_started);
        Foreman.Core.Client.get_default ().server_manager.server_startup_failed.connect (on_server_startup_failed);
        Foreman.Core.Client.get_default ().server_manager.server_stopping.connect (on_server_stopping);
        Foreman.Core.Client.get_default ().server_manager.server_stopped.connect (on_server_stopped);
        Foreman.Core.Client.get_default ().server_manager.server_errored.connect (on_server_errored);
        Foreman.Core.Client.get_default ().server_manager.server_deleted.connect (on_server_deleted);
        Foreman.Core.Client.get_default ().server_manager.player_joined.connect (on_player_joined);
        Foreman.Core.Client.get_default ().server_manager.player_left.connect (on_player_left);
        Foreman.Core.Client.get_default ().server_manager.server_message_logged.connect (on_server_message_logged);
        Foreman.Core.Client.get_default ().server_manager.server_warning_logged.connect (on_server_warning_logged);
        Foreman.Core.Client.get_default ().server_manager.server_error_logged.connect (on_server_error_logged);

        show_app ();

        set_focus (null);
    }

    private void restore_window_position () {
        move (Foreman.Application.settings.get_int ("pos-x"), Foreman.Application.settings.get_int ("pos-y"));
        resize (Foreman.Application.settings.get_int ("window-width"), Foreman.Application.settings.get_int ("window-height"));
    }

    private void show_app () {
        //  show_all ();
        present ();
    }

    public bool before_destroy () {
        //  Foreman.Core.Client.get_default ().server_manager.server_stopped.disconnect (on_server_stopped); // Prevent warnings
        //  Foreman.Core.Client.get_default ().server_manager.server_errored.disconnect (on_server_errored); // Prevent warnings
        Foreman.Core.Client.get_default ().server_manager.stop_all ();
        update_position_settings ();
        destroy ();
        return true;
    }

    public void toggle_sidebar () {
        layout.toggle_sidebar ();
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

    private void on_server_created (Foreman.Services.Server server) {
        layout.add_server_to_library (server.context);
    }

    private void on_server_starting (Foreman.Services.Server server) {
        layout.server_starting (server.context);
    }

    private void on_server_startup_progress (Foreman.Services.Server server, double progress) {
        layout.update_progress (server.context, progress);
    }

    private void on_server_started (Foreman.Services.Server server) {
        layout.server_started (server.context);
    }

    private void on_server_startup_failed (Foreman.Services.Server server) {
        layout.server_startup_failed (server.context);
    }

    private void on_server_stopping (Foreman.Services.Server server) {
        layout.server_stopping (server.context);
    }

    private void on_server_stopped (Foreman.Services.Server server) {
        layout.server_stopped (server.context);
    }

    private void on_server_errored (Foreman.Services.Server server) {
        layout.server_errored (server.context);
    }

    private void on_server_deleted (Foreman.Services.Server server) {
        layout.server_deleted (server.context);
    }

    private void on_player_joined (Foreman.Services.Server server) {
        layout.player_joined (server.context);
    }

    private void on_player_left (Foreman.Services.Server server) {
        layout.player_left (server.context);
    }

    private void on_server_message_logged (Foreman.Services.Server server, string message) {
        layout.add_log_message (server.context, message);
    }

    private void on_server_warning_logged (Foreman.Services.Server server, string message) {
        layout.add_log_warning (server.context, message);
    }

    private void on_server_error_logged (Foreman.Services.Server server, string message) {
        layout.add_log_error (server.context, message);
    }

    private void on_start_button_clicked (Foreman.Services.Server.Context server_context) {
        Foreman.Core.Client.get_default ().server_manager.start_server (server_context.uuid);
    }

    private void on_stop_button_clicked (Foreman.Services.Server.Context server_context) {
        Foreman.Core.Client.get_default ().server_manager.stop_server (server_context.uuid);
    }

    //  private void on_delete_button_clicked (Foreman.Services.Server.Context server_context) {
    //      Foreman.Core.Client.get_default ().server_manager.delete_server (server_context.uuid);
    //  }

    //  private void on_configure_button_clicked (Foreman.Services.Server.Context server_context) {
    //      // TODO
    //  }

    private void on_command_to_send (Foreman.Services.Server.Context server_context, string command) {
        Foreman.Core.Client.get_default ().server_manager.send_command (server_context.uuid, command);
    }

    public void show_preferences_dialog () {
        if (preferences_dialog == null) {
            preferences_dialog = new Foreman.Widgets.Dialogs.PreferencesDialog (this);
            preferences_dialog.show_all ();
            preferences_dialog.destroy.connect (() => {
                preferences_dialog = null;
            });
        }
        preferences_dialog.present ();
    }

    public void configure_selected_server () {
        Foreman.Views.ServerDetailView? selected_server = layout.get_visible_server ();
        if (selected_server == null) {
            debug ("No selected server to configure");
            return;
        }
        if (configure_server_dialog == null) {
            configure_server_dialog = new Foreman.Widgets.Dialogs.ConfigureServerDialog (this, selected_server.server_context);
            configure_server_dialog.show_all ();
            configure_server_dialog.destroy.connect (() => {
                configure_server_dialog = null;
            });
        }
        configure_server_dialog.present ();
    }

    public void delete_selected_server () {
        Foreman.Views.ServerDetailView? selected_server = layout.get_visible_server ();
        if (selected_server == null) {
            debug ("No selected server to delete");
            return;
        }
        if (delete_confirmation (selected_server.server_context)) {
            Foreman.Core.Client.get_default ().server_manager.delete_server (selected_server.server_context.uuid);
        }
    }

    private bool delete_confirmation (Foreman.Services.Server.Context server_context) {
        var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
            _("Delete “%s”?").printf ("My Server"), // TODO: Get actual server name from context
            _("The server and all world data will be permanently deleted."),
            "edit-delete",
            Gtk.ButtonsType.CANCEL
        ) {
            badge_icon = new ThemedIcon ("dialog-question"),
            transient_for = this
        };

        unowned Gtk.Widget trash_button = message_dialog.add_button (_("Delete Anyway"), Gtk.ResponseType.YES);
        trash_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        Gtk.ResponseType response = (Gtk.ResponseType) message_dialog.run ();
        message_dialog.destroy ();

        return response == Gtk.ResponseType.YES;
    }

    public void show_create_new_server_dialog () {
        //  var latest_downloaded = Foreman.Core.Client.get_default ().server_executable_repository.get_latest_downloaded_release_version ();
        //  if (latest_downloaded == null) {

        //  }

        // ----

        //  var latest_release = Foreman.Core.Client.get_default ().server_executable_repository.get_latest_release_version ();
        //  Foreman.Core.Client.get_default ().server_executable_repository.download_server_executable_async.begin (latest_release, null, (obj, res) => {
        //      GLib.File? server_file = Foreman.Core.Client.get_default ().server_executable_repository.download_server_executable_async.end (res);
        //      if (server_file == null) {
        //          debug ("Error downloading server file");
        //      }

        //      // Show EULA dialog since this is a new download (Maybe change this to a one-time thing? Should follow how it would be done if running manually)
        //      if (show_eula_dialog () != Gtk.ResponseType.ACCEPT) {
        //          // TODO
        //          return;
        //      }
        //      if (!Foreman.Core.Client.get_default ().server_executable_repository.accept_eula (latest_release)) {
        //          // TODO: This is an error
        //          return;
        //      }

        //      var server = Foreman.Core.Client.get_default ().server_manager.create_server (latest_release);
        //      //  layout.add_server_to_library (server.context);
        //      server.start ();
        //  });

        // ----

        if (create_new_server_dialog == null) {
            create_new_server_dialog = new Foreman.Widgets.Dialogs.CreateNewServerDialog (this);
            create_new_server_dialog.create_button_clicked.connect ((name, version, properties) => {
                create_new_server_dialog.close ();
                create_new_server (name, version, properties);
            });
            create_new_server_dialog.destroy.connect (() => {
                create_new_server_dialog = null;
            });
            create_new_server_dialog.show_all ();
        }
        create_new_server_dialog.present ();
    }

    private void create_new_server (string name, string version, Foreman.Models.ServerProperties properties) {
        if (!Foreman.Core.Client.get_default ().server_executable_repository.get_downloaded_executables ().has_key (version)) {
            Foreman.Core.Client.get_default ().server_executable_repository.download_server_executable_async.begin (version, null, (obj, res) => {
                GLib.File? server_file = Foreman.Core.Client.get_default ().server_executable_repository.download_server_executable_async.end (res);
                if (server_file == null) {
                    debug ("Error downloading server file");
                }

                // Show EULA dialog since this is a new download (Maybe change this to a one-time thing? Should follow how it would be done if running manually)
                if (show_eula_dialog () != Gtk.ResponseType.ACCEPT) {
                    // TODO
                    return;
                }
                if (!Foreman.Core.Client.get_default ().server_executable_repository.accept_eula (version)) {
                    // TODO: This is an error
                    return;
                }

                Foreman.Core.Client.get_default ().server_manager.create_server (name, version, properties).start ();
            });
        } else {
            Foreman.Core.Client.get_default ().server_manager.create_server (name, version, properties).start ();
        }

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

    public void show_help_dialog () {
        if (help_dialog == null) {
            help_dialog = new Foreman.Widgets.Dialogs.HelpDialog (this);
            help_dialog.destroy.connect (() => {
                help_dialog = null;
            });
            help_dialog.show_all ();
        }
        help_dialog.present ();
    }

    //  public void show_available_server_downloads_dialog () {
    //      //  if (available_server_downloads_dialog == null) {
    //      //      available_server_downloads_dialog = new Foreman.Widgets.Dialogs.AvailableServerDownloadsDialog (this);
    //      //      available_server_downloads_dialog.destroy.connect (() => {
    //      //          available_server_downloads_dialog = null;
    //      //      });
    //      //      available_server_downloads_dialog.show_all ();
    //      //  }
    //      //  available_server_downloads_dialog.present ();
    //      var dialog = new Foreman.Widgets.Dialogs.DownloadingDialog (this);
    //      dialog.show_all ();
    //      dialog.present ();

    //      unowned var client = Foreman.Core.Client.get_default ();
    //      client.server_download_service.retrieve_available_servers.begin ((obj, res) => {
    //          Foreman.Models.VersionManifest? version_manifest = client.server_download_service.retrieve_available_servers.end (res);
    //          if (version_manifest == null) {
    //              // TODO: Error
    //              return;
    //          }
    //          var server_manifest = version_manifest.versions.get (version_manifest.latest.release);
    //          client.server_download_service.retrieve_version_details.begin (server_manifest.url, (obj, res) => {
    //              Foreman.Models.VersionDetails? version_details = client.server_download_service.retrieve_version_details.end (res);
    //              if (version_details == null) {
    //                  // TODO: Error
    //                  return;
    //              }
    //              var download = version_details.downloads.get (Foreman.Models.VersionDetails.Download.Type.SERVER);
    //              var download_context = new Foreman.Utils.HttpUtils.DownloadContext (download.url, GLib.File.new_for_path (GLib.Path.build_filename (GLib.Environment.get_home_dir (), "Downloads", "minecraft-server.jar")), download.size);

    //              download_context.progress.connect ((progress) => {
    //                  Idle.add (() => {
    //                      dialog.update_progress (download_context);
    //                      return false;
    //                  });
    //              });

    //              new GLib.Thread<bool> ("download-server", () => {
    //                  try {
    //                      Foreman.Utils.HttpUtils.download_file (download_context, null);
    //                  } catch (GLib.Error e) {
    //                      warning (e.message);
    //                  }
    //                  return true;
    //              });
    //          });
    //      });

    //  }

}
