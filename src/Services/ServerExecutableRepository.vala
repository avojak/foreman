/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.ServerExecutableRepository : GLib.Object {

    private const string VERSION_MANIFEST_URL = "https://launchermeta.mojang.com/mc/game/version_manifest.json";
    private const string EULA_FILENAME = "eula.txt";

    private static GLib.Once<Foreman.Services.ServerExecutableRepository> instance;
    public static unowned Foreman.Services.ServerExecutableRepository get_default () {
        return instance.once (() => { return new Foreman.Services.ServerExecutableRepository (); });
    }

    public static string server_executable_dir_path = GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, GLib.Environment.get_user_config_dir (), "server_executables");

    private Foreman.Models.VersionManifest? version_manifest;
    private GLib.DateTime? last_updated;

    private ServerExecutableRepository () {
        // TODO: Log available server executables
        var server_executable_dir = GLib.File.new_for_path (server_executable_dir_path);
        if (!server_executable_dir.query_exists ()) {
            try {
                server_executable_dir.make_directory ();
            } catch (GLib.Error e) {
                warning (e.message);
            }
        }
    }

    public string? get_latest_release_version () {
        if (version_manifest == null) {
            return null;
        }
        return version_manifest.latest.release;
    }

    public string? get_latest_snapshot_version () {
        if (version_manifest == null) {
            return null;
        }
        return version_manifest.latest.snapshot;
    }

    public async void refresh () {
        GLib.SourceFunc callback = refresh.callback;

        Foreman.Models.VersionManifest? result = null;
        new GLib.Thread<bool> ("download-version-manifest", () => {
            result = download_version_manifest ();
            Idle.add ((owned) callback);
            return true;
        });
        yield;

        version_manifest = result;
        last_updated = new DateTime.now ();
        
        if (version_manifest != null) {
            debug ("Latest release: %s", version_manifest.latest.release);
            debug ("Latest snapshot: %s", version_manifest.latest.snapshot);
        }
    }

    private Foreman.Models.VersionManifest? download_version_manifest () {
        Soup.Session session = new Soup.Session () {
            use_thread_context = true
        };
        try {
            Soup.Request request = session.request (VERSION_MANIFEST_URL);
            GLib.DataInputStream data_stream = new GLib.DataInputStream (request.send ());
            GLib.StringBuilder string_builder = new GLib.StringBuilder ();
            string? line;
            while ((line = data_stream.read_line ()) != null) {
                string_builder.append (line);
            }
            Foreman.Models.VersionManifest? manifest = Foreman.Utils.JsonUtils.parse_json_obj (string_builder.str, (json_obj) => {
                return Foreman.Models.VersionManifest.from_json (json_obj);
            }) as Foreman.Models.VersionManifest;
            //  if (manifest == null) {
                //  Idle.add (() => {
                //      var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch available servers", "Unable to parse the response from the server", "dialog-error", Gtk.ButtonsType.CLOSE);
                //      message_dialog.run ();
                //      message_dialog.destroy ();
                //      return false;
                //  });
            //  }
            return manifest;
        } catch (GLib.Error e) {
            var error = e.message;
            warning (error);
            //  Idle.add (() => {
            //      var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch available servers", error, "dialog-error", Gtk.ButtonsType.CLOSE);
            //      message_dialog.run ();
            //      message_dialog.destroy ();
            //      return false;
            //  });
        }
        return null;
    }

    private Foreman.Models.VersionDetails? download_version_details (string url) {
        Soup.Session session = new Soup.Session () {
            use_thread_context = true
        };
        try {
            Soup.Request request = session.request (url);
            GLib.DataInputStream data_stream = new GLib.DataInputStream (request.send ());
            GLib.StringBuilder string_builder = new GLib.StringBuilder ();
            string? line;
            while ((line = data_stream.read_line ()) != null) {
                string_builder.append (line);
            }
            Foreman.Models.VersionDetails? details = Foreman.Utils.JsonUtils.parse_json_obj (string_builder.str, (json_obj) => {
                return Foreman.Models.VersionDetails.from_json (json_obj);
            }) as Foreman.Models.VersionDetails;
            if (details == null) {
                //  Idle.add (() => {
                //      var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch version details", "Unable to parse the response from the server", "dialog-error", Gtk.ButtonsType.CLOSE);
                //      message_dialog.run ();
                //      message_dialog.destroy ();
                //      return false;
                //  });
            }
            return details;
        } catch (GLib.Error e) {
            var error = e.message;
            warning (error);
            //  Idle.add (() => {
            //      var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch version details", error, "dialog-error", Gtk.ButtonsType.CLOSE);
            //      message_dialog.run ();
            //      message_dialog.destroy ();
            //      return false;
            //  });
        }
        return null;
    }

    public async GLib.File? download_server_executable_async (string version, GLib.Cancellable? cancellable = null) {
        GLib.SourceFunc callback = download_server_executable_async.callback;

        var dialog = new Foreman.Widgets.Dialogs.DownloadingDialog (Foreman.Application.get_instance ().get_main_window ());
        dialog.show_all ();
        dialog.present ();
        dialog.show_downloading ();

        GLib.File? server_file = null;
        new GLib.Thread<void> ("download-server-executable", () => {
            server_file = do_download_server_executable (version, dialog, cancellable);
            if (server_file != null) {
                Idle.add (() => {
                    dialog.show_extracting ();
                    return false;
                });
                
                unpack_server_executable (server_file);
                dialog.close ();
            } else {
                // TODO: Error
            }
            Idle.add ((owned) callback);
        });
        yield;

        return server_file;
    }

    private GLib.File? do_download_server_executable (string version, Foreman.Widgets.Dialogs.DownloadingDialog dialog, GLib.Cancellable? cancellable = null) {
        try {
            var details_url = version_manifest.versions.get (version).url;
            Foreman.Models.VersionDetails? version_details = download_version_details (details_url);
            if (version_details == null) {
                return null;
            }
    
            var server_details = version_details.downloads.get (Foreman.Models.VersionDetails.Download.Type.SERVER);
            var server_dir = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, server_executable_dir_path, version));
            server_dir.make_directory (cancellable);
            var server_file = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, server_dir.get_path (), "server.jar"));
            var context = new Foreman.Utils.HttpUtils.DownloadContext (server_details.url, server_file, server_details.size);

            context.progress.connect ((progress) => {
                Idle.add (() => {
                    dialog.update_progress (context);
                    return false;
                });
            });
            //  context.complete.connect (() => {
            //      Idle.add (() => {
            //          dialog.close ();
            //          return false;
            //      });
            //  });

            Foreman.Utils.HttpUtils.download_file (context, cancellable);
            return server_file;
        } catch (GLib.Error e) {
            warning (e.message);
            return null;
        }
    }

    private void unpack_server_executable (GLib.File server_file) {
        Foreman.Core.Client.get_default ().java_execution_service.execute_sync ("java -jar %s nogui".printf (server_file.get_path ()), server_file.get_parent ().get_path ());
    }

    public bool accept_eula (string version) {
        var eula_file = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, server_executable_dir_path, version, EULA_FILENAME));
        uint8[] old_contents;
        string etag;
        try {
            eula_file.load_contents (null, out old_contents, out etag);
        } catch (GLib.Error e) {
            warning ("Error loading contents of EULA file: %s", e.message);
            return false;
        }
        uint8[] new_contents = ((string) old_contents).replace ("eula=false", "eula=true").data;
        try {
            eula_file.replace_contents (new_contents, etag, false, GLib.FileCreateFlags.NONE, null);
        } catch (GLib.Error e) {
            warning ("Error replacing contents of EULA file: %s", e.message);
            return false;
        }
        return true;
    }

    public void copy_template (string version, GLib.File target) {
        var template_dir = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, server_executable_dir_path, version));
        try {
            //  template_dir.copy (target, GLib.FileCopyFlags.OVERWRITE, null, null);
            Foreman.Utils.FileUtils.copy_recursive (template_dir, target, GLib.FileCopyFlags.OVERWRITE, null);
        } catch (GLib.Error e) {
            warning (e.message);
        }
    }

}