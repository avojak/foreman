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

    public Foreman.Services.SQLClient sql_client { get; construct; }

    private Foreman.Models.VersionManifest? version_manifest;
    private GLib.DateTime? last_updated;
    private Gee.Map<string, Foreman.Models.ServerExecutable> downloaded_executables;

    private ServerExecutableRepository () {
        Object (
            sql_client: Foreman.Services.SQLClient.get_default ()
        );
    }

    construct {
        // Establish the directory for server executables if not already present
        var server_executable_dir = GLib.File.new_for_path (server_executable_dir_path);
        if (!server_executable_dir.query_exists ()) {
            try {
                server_executable_dir.make_directory ();
            } catch (GLib.Error e) {
                warning (e.message);
            }
        }

        // Load up the downloaded executables from the database
        downloaded_executables = new Gee.HashMap<string, Foreman.Models.ServerExecutable> ();
        lock (sql_client) {
            foreach (var executable in sql_client.get_server_executables ()) {
                downloaded_executables.set (executable.version, executable);
            }
        }
        //  try {
        //      GLib.FileEnumerator enumerator = server_executable_dir.enumerate_children (GLib.FileAttribute.STANDARD_NAME, GLib.FileQueryInfoFlags.NONE);
        //      for (GLib.FileInfo? info = enumerator.next_file (); info != null; info = enumerator.next_file ()) {
        //          var executable_directory = GLib.File.new_for_path (GLib.Path.build_filename (server_executable_dir.get_path (), info.get_name ()));
        //          if (executable_directory.query_file_type (GLib.FileQueryInfoFlags.NONE) == GLib.FileType.DIRECTORY) {
        //              downloaded_executables.set (info.get_name (), executable_directory);
        //          }
        //      }
        //  } catch (GLib.Error e) {
        //      warning (e.message);
        //  }
        debug ("Downloaded server versions: %s", downloaded_executables.size == 0 ? "none" : string.joinv (", ", downloaded_executables.keys.to_array ()));
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

    public Gee.HashMap<string, Foreman.Models.ServerExecutable> get_downloaded_executables () {
        var downloaded = new Gee.HashMap<string, Foreman.Models.ServerExecutable> ();
        downloaded.set_all (downloaded_executables);
        return downloaded;
    }

    public string? get_latest_downloaded_release_version () {
        var versions = new Gee.ArrayList<SemVer.Version> ();
        foreach (var entry in downloaded_executables) {
            try {
                versions.add (new SemVer.Version.from_string (entry.key));
            } catch (SemVer.VersionParseError e) {
                warning (e.message);
            }
        }
        if (versions.size == 0) {
            return null;
        }
        versions.sort ((a, b) => {
            return a.compare_to (b);
        });
        return versions.get (0).to_string ();
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

        // TODO: Check if latest release is newer than our latest downloaded
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

                if (!unpack_server_executable (server_file)) {
                    // TODO: Error
                    downloaded_executables.unset (version);
                    sql_client.remove_server_executable (version);
                    return;
                }

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

            // Add the executable to the database
            var executable = new Foreman.Models.ServerExecutable () {
                version = version,
                version_type = version_details.version_type,
                directory = server_dir
            };
            sql_client.insert_server_executable (executable);
            downloaded_executables.set (version, executable);

            return server_file;
        } catch (GLib.Error e) {
            warning (e.message);
            return null;
        }
    }

    private bool unpack_server_executable (GLib.File server_file) {
        return Foreman.Core.Client.get_default ().java_execution_service.execute_sync ("java -jar %s nogui".printf (server_file.get_path ()), server_file.get_parent ().get_path ());
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
