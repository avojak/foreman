/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.ServerExecutableRepository : GLib.Object {

    private const string JAVA_VERSION_MANIFEST_URL = "https://launchermeta.mojang.com/mc/game/version_manifest.json";
    private const string EULA_FILENAME = "eula.txt";
    private const string BEDROCK_DOWNLOAD_URL_FORMAT = "https://minecraft.azureedge.net/bin-linux/bedrock-server-%s.zip";

    private static GLib.Once<Foreman.Services.ServerExecutableRepository> instance;
    public static unowned Foreman.Services.ServerExecutableRepository get_default () {
        return instance.once (() => { return new Foreman.Services.ServerExecutableRepository (); });
    }

    public static string java_server_executable_dir_path = GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, GLib.Environment.get_user_config_dir (), "java_server_executables");
    public static string bedrock_server_executable_dir_path = GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, GLib.Environment.get_user_config_dir (), "bedrock_server_executables");

    public Foreman.Services.SQLClient sql_client { get; construct; }

    private Foreman.Models.JavaVersionManifest? java_version_manifest;
    private string? bedrock_version;
    private GLib.DateTime? last_updated;
    private Gee.Map<string, Foreman.Models.JavaServerExecutable> downloaded_java_executables;
    private Gee.Map<string, Foreman.Models.BedrockServerExecutable> downloaded_bedrock_executables;

    private ServerExecutableRepository () {
        Object (
            sql_client: Foreman.Services.SQLClient.get_default ()
        );
    }

    construct {
        // Establish the directory for Java Edition server executables if not already present
        var java_server_executable_dir = GLib.File.new_for_path (java_server_executable_dir_path);
        if (!java_server_executable_dir.query_exists ()) {
            try {
                java_server_executable_dir.make_directory ();
            } catch (GLib.Error e) {
                warning (e.message);
            }
        }
        var bedrock_server_executable_dir = GLib.File.new_for_path (bedrock_server_executable_dir_path);
        if (!bedrock_server_executable_dir.query_exists ()) {
            try {
                bedrock_server_executable_dir.make_directory ();
            } catch (GLib.Error e) {
                warning (e.message);
            }
        }

        // Load up the downloaded executables from the database
        downloaded_java_executables = new Gee.HashMap<string, Foreman.Models.JavaServerExecutable> ();
        lock (sql_client) {
            foreach (var executable in sql_client.get_java_server_executables ()) {
                downloaded_java_executables.set (executable.version, executable);
            }
        }
        downloaded_bedrock_executables = new Gee.HashMap<string, Foreman.Models.BedrockServerExecutable> ();
        lock (sql_client) {
            foreach (var executable in sql_client.get_bedrock_server_executables ()) {
                downloaded_bedrock_executables.set (executable.version, executable);
            }
        }
        //  try {
        //      GLib.FileEnumerator enumerator = server_executable_dir.enumerate_children (GLib.FileAttribute.STANDARD_NAME, GLib.FileQueryInfoFlags.NONE);
        //      for (GLib.FileInfo? info = enumerator.next_file (); info != null; info = enumerator.next_file ()) {
        //          var executable_directory = GLib.File.new_for_path (GLib.Path.build_filename (server_executable_dir.get_path (), info.get_name ()));
        //          if (executable_directory.query_file_type (GLib.FileQueryInfoFlags.NONE) == GLib.FileType.DIRECTORY) {
        //              downloaded_java_executables.set (info.get_name (), executable_directory);
        //          }
        //      }
        //  } catch (GLib.Error e) {
        //      warning (e.message);
        //  }
        debug ("Downloaded Java server versions: %s", downloaded_java_executables.size == 0 ? "none" : string.joinv (", ", downloaded_java_executables.keys.to_array ()));
        debug ("Downloaded Bedrock server versions: %s", downloaded_bedrock_executables.size == 0 ? "none" : string.joinv (", ", downloaded_bedrock_executables.keys.to_array ()));
    }

    public string? get_latest_java_release_version () {
        if (java_version_manifest == null) {
            return null;
        }
        return java_version_manifest.latest.release;
    }

    public string? get_latest_java_snapshot_version () {
        if (java_version_manifest == null) {
            return null;
        }
        return java_version_manifest.latest.snapshot;
    }

    public string? get_latest_bedrock_version () {
        return bedrock_version;
    }

    public Gee.HashMap<string, Foreman.Models.JavaServerExecutable> get_downloaded_java_executables () {
        var downloaded = new Gee.HashMap<string, Foreman.Models.JavaServerExecutable> ();
        downloaded.set_all (downloaded_java_executables);
        return downloaded;
    }

    public Gee.HashMap<string, Foreman.Models.BedrockServerExecutable> get_downloaded_bedrock_executables () {
        var downloaded = new Gee.HashMap<string, Foreman.Models.BedrockServerExecutable> ();
        downloaded.set_all (downloaded_bedrock_executables);
        return downloaded;
    }

    public string? get_latest_downloaded_release_version () {
        var versions = new Gee.ArrayList<SemVer.Version> ();
        foreach (var entry in downloaded_java_executables) {
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

        Foreman.Models.JavaVersionManifest? java_result = null;
        string? bedrock_result = null;
        new GLib.Thread<bool> ("download-version-manifest", () => {
            java_result = download_java_version_manifest ();
            bedrock_result = get_latest_available_bedrock_version ();
            Idle.add ((owned) callback);
            return true;
        });
        yield;

        java_version_manifest = java_result;
        bedrock_version = bedrock_result;
        last_updated = new DateTime.now ();

        if (java_version_manifest != null) {
            debug ("Latest Java Edition release: %s", java_version_manifest.latest.release);
            debug ("Latest Java Edition snapshot: %s", java_version_manifest.latest.snapshot);
        }
        if (bedrock_version != null) {
            debug ("Latest Bedrock version: %s", bedrock_version);
        }

        // TODO: Check if latest release is newer than our latest downloaded
    }

    private Foreman.Models.JavaVersionManifest? download_java_version_manifest () {
        try {
            string result = Foreman.Utils.HttpUtils.get_as_string (JAVA_VERSION_MANIFEST_URL);
            Foreman.Models.JavaVersionManifest? manifest = Foreman.Utils.JsonUtils.parse_json_obj (result, (json_obj) => {
                return Foreman.Models.JavaVersionManifest.from_json (json_obj);
            }) as Foreman.Models.JavaVersionManifest;
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

    private Foreman.Models.JavaVersionDetails? download_java_version_details (string url) {
        try {
            string result = Foreman.Utils.HttpUtils.get_as_string (url);
            Foreman.Models.JavaVersionDetails? details = Foreman.Utils.JsonUtils.parse_json_obj (result, (json_obj) => {
                return Foreman.Models.JavaVersionDetails.from_json (json_obj);
            }) as Foreman.Models.JavaVersionDetails;
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

    public async GLib.File? download_java_server_executable_async (string version, GLib.Cancellable? cancellable = null) {
        GLib.SourceFunc callback = download_java_server_executable_async.callback;

        var dialog = new Foreman.Widgets.Dialogs.DownloadingDialog (Foreman.Application.get_instance ().get_main_window ());
        dialog.show_all ();
        dialog.present ();
        dialog.show_downloading ();

        GLib.File? server_file = null;
        new GLib.Thread<void> ("download-server-executable", () => {
            server_file = do_download_java_server_executable (version, dialog, cancellable);
            if (server_file != null) {
                Idle.add (() => {
                    dialog.show_extracting ();
                    return false;
                });

                if (!unpack_java_server_executable (server_file)) {
                    // TODO: Error
                    downloaded_java_executables.unset (version);
                    sql_client.remove_java_server_executable (version);
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

    private GLib.File? do_download_java_server_executable (string version, Foreman.Widgets.Dialogs.DownloadingDialog dialog, GLib.Cancellable? cancellable = null) {
        try {
            var details_url = java_version_manifest.versions.get (version).url;
            Foreman.Models.JavaVersionDetails? version_details = download_java_version_details (details_url);
            if (version_details == null) {
                return null;
            }

            var server_details = version_details.downloads.get (Foreman.Models.JavaVersionDetails.Download.Type.SERVER);
            var server_dir = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, java_server_executable_dir_path, version));
            server_dir.make_directory (cancellable);
            var server_file = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, server_dir.get_path (), "server.jar"));
            var context = new Foreman.Utils.HttpUtils.DownloadContext (server_details.url, server_file);

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
            var executable = new Foreman.Models.JavaServerExecutable () {
                version = version,
                version_type = version_details.version_type,
                directory = server_dir
            };
            sql_client.insert_java_server_executable (executable);
            downloaded_java_executables.set (version, executable);

            return server_file;
        } catch (GLib.Error e) {
            warning (e.message);
            return null;
        }
    }

    private bool unpack_java_server_executable (GLib.File server_file) {
        return Foreman.Core.Client.get_default ().java_execution_service.execute_sync ("java -jar %s nogui".printf (server_file.get_path ()), server_file.get_parent ().get_path ());
    }

    public bool accept_java_eula (string version) {
        var eula_file = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, java_server_executable_dir_path, version, EULA_FILENAME));
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

    public void copy_template (Foreman.Models.ServerType server_type, string version, GLib.File target) {
        GLib.File template_dir;
        switch (server_type) {
            case JAVA_EDITION:
                template_dir = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, java_server_executable_dir_path, version));
                break;
            case BEDROCK:
                template_dir = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, bedrock_server_executable_dir_path, version));
                break;
            default:
                assert_not_reached ();
        }
        try {
            //  template_dir.copy (target, GLib.FileCopyFlags.OVERWRITE, null, null);
            Foreman.Utils.FileUtils.copy_recursive (template_dir, target, GLib.FileCopyFlags.OVERWRITE, null);
        } catch (GLib.Error e) {
            warning (e.message);
        }

        if (server_type == Foreman.Models.ServerType.BEDROCK) {
            var wrapper = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, Constants.PKG_DATA_DIR, "bedrock-wrapper.sh"));
            var wrapper_target = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, target.get_path (), "bedrock-wrapper.sh"));
            try {
                wrapper.copy (wrapper_target, GLib.FileCopyFlags.OVERWRITE);
            } catch (GLib.Error e) {
                warning (e.message);
            }
        }
    }

    public string? get_latest_available_bedrock_version () {
        string? html = null;
        try {
            html = Foreman.Utils.HttpUtils.get_as_string ("https://www.minecraft.net/download/server/bedrock");
        } catch (GLib.Error e) {
            warning (e.message);
            return null;
        }
        try {
            var doc = new GXml.XHtmlDocument.from_string_doc (html, Html.ParserOption.NOWARNING | Html.ParserOption.NOERROR);
            GXml.DomElement? element = doc.query_selector (".downloadlink[data-platform=\"serverBedrockLinux\"]");
            if (element == null) {
                warning ("Download link element not found");
                return null;
            }
            string? download_url = element.get_attribute ("href");
            if (download_url == null) {
                warning ("Download URL not found");
                return null;
            }
            string[] url_tokens = download_url.split ("/");
            string[] filename_tokens = url_tokens[url_tokens.length - 1].split ("-");
            return filename_tokens[filename_tokens.length - 1].replace (".zip", "");
        } catch (GLib.Error e) {
            warning (e.message);
            return null;
        }
    }

    public async GLib.File? download_bedrock_server_executable_async (string version, GLib.Cancellable? cancellable = null) {
        GLib.SourceFunc callback = download_bedrock_server_executable_async.callback;

        var dialog = new Foreman.Widgets.Dialogs.DownloadingDialog (Foreman.Application.get_instance ().get_main_window ());
        dialog.show_all ();
        dialog.present ();
        dialog.show_downloading ();

        GLib.File? server_archive = null;
        new GLib.Thread<void> ("download-server-executable", () => {
            server_archive = do_download_bedrock_server_archive (version, dialog, cancellable);
            if (server_archive != null) {
                Idle.add (() => {
                    dialog.show_extracting ();
                    return false;
                });

                if (!unpack_bedrock_server_archive (server_archive)) {
                    // TODO: Error
                    downloaded_bedrock_executables.unset (version);
                    sql_client.remove_bedrock_server_executable (version);
                    return;
                }
                server_archive.delete_async ();

                dialog.close ();
            } else {
                // TODO: Error
            }
            Idle.add ((owned) callback);
        });
        yield;

        return server_archive;
    }

    private GLib.File? do_download_bedrock_server_archive (string version, Foreman.Widgets.Dialogs.DownloadingDialog dialog, GLib.Cancellable? cancellable = null) {
        try {
            var server_dir = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, bedrock_server_executable_dir_path, version));
            server_dir.make_directory (cancellable);
            var server_archive = GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, server_dir.get_path (), "bedrock-server.zip"));
            var context = new Foreman.Utils.HttpUtils.DownloadContext (BEDROCK_DOWNLOAD_URL_FORMAT.printf (version), server_archive);

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
            var executable = new Foreman.Models.BedrockServerExecutable () {
                version = version,
                directory = server_dir
            };
            sql_client.insert_bedrock_server_executable (executable);
            downloaded_bedrock_executables.set (version, executable);

            return server_archive;
        } catch (GLib.Error e) {
            warning (e.message);
            return null;
        }
    }

    private bool unpack_bedrock_server_archive (GLib.File server_archive) {
        Foreman.Utils.FileUtils.extract_archive (server_archive);
        return true;
    }

}
