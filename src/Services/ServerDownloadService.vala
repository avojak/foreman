/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.ServerDownloadService : GLib.Object {

    private const string VERSION_MANIFEST_URL = "https://launchermeta.mojang.com/mc/game/version_manifest.json";

    private static GLib.Once<Foreman.Services.ServerDownloadService> instance;
    public static unowned Foreman.Services.ServerDownloadService get_default () {
        return instance.once (() => { return new Foreman.Services.ServerDownloadService (); });
    }

    //  private Foreman.Models.VersionManifest? version_manifest;

    public async Foreman.Models.VersionManifest? retrieve_available_servers () {
        GLib.SourceFunc callback = retrieve_available_servers.callback;

        Foreman.Models.VersionManifest? result = null;
        new GLib.Thread<bool> ("download-version-manifest", () => {
            result = download_version_manifest ();
            Idle.add ((owned) callback);
            return true;
        });
        yield;

        if (result != null) {
            debug (result.latest.release);
        }

        return result;
    }

    public async Foreman.Models.VersionDetails? retrieve_version_details (string url) {
        GLib.SourceFunc callback = retrieve_version_details.callback;

        Foreman.Models.VersionDetails? result = null;
        new GLib.Thread<bool> ("download-server-manifest", () => {
            result = download_version_details (url);
            Idle.add ((owned) callback);
            return true;
        });
        yield;

        if (result != null) {
            debug (result.downloads.get (Foreman.Models.VersionDetails.Download.Type.SERVER).url);
        }

        return result;
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
            if (manifest == null) {
                Idle.add (() => {
                    var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch available servers", "Unable to parse the response from the server", "dialog-error", Gtk.ButtonsType.CLOSE);
                    message_dialog.run ();
                    message_dialog.destroy ();
                    return false;
                });
            }
            return manifest;
        } catch (GLib.Error e) {
            var error = e.message;
            warning (error);
            Idle.add (() => {
                var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch available servers", error, "dialog-error", Gtk.ButtonsType.CLOSE);
                message_dialog.run ();
                message_dialog.destroy ();
                return false;
            });
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
                Idle.add (() => {
                    var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch version details", "Unable to parse the response from the server", "dialog-error", Gtk.ButtonsType.CLOSE);
                    message_dialog.run ();
                    message_dialog.destroy ();
                    return false;
                });
            }
            return details;
        } catch (GLib.Error e) {
            var error = e.message;
            warning (error);
            Idle.add (() => {
                var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch version details", error, "dialog-error", Gtk.ButtonsType.CLOSE);
                message_dialog.run ();
                message_dialog.destroy ();
                return false;
            });
        }
        return null;
    }

}
