//  /*
//   * SPDX-License-Identifier: GPL-3.0-or-later
//   * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
//   */

//  public class Foreman.Services.ServerDownloadService : GLib.Object {

//      private const string JAVA_VERSION_MANIFEST_URL = "https://launchermeta.mojang.com/mc/game/version_manifest.json";

//      private static GLib.Once<Foreman.Services.ServerDownloadService> instance;
//      public static unowned Foreman.Services.ServerDownloadService get_default () {
//          return instance.once (() => { return new Foreman.Services.ServerDownloadService (); });
//      }

//      //  private Foreman.Models.VersionManifest? version_manifest;

//      public async Foreman.Models.JavaVersionManifest? retrieve_available_java_servers () {
//          GLib.SourceFunc callback = retrieve_available_java_servers.callback;

//          Foreman.Models.JavaVersionManifest? result = null;
//          new GLib.Thread<bool> ("download-version-manifest", () => {
//              result = download_java_version_manifest ();
//              Idle.add ((owned) callback);
//              return true;
//          });
//          yield;

//          if (result != null) {
//              debug (result.latest.release);
//          }

//          return result;
//      }

//      public async Foreman.Models.JavaVersionDetails? retrieve_java_version_details (string url) {
//          GLib.SourceFunc callback = retrieve_java_version_details.callback;

//          Foreman.Models.JavaVersionDetails? result = null;
//          new GLib.Thread<bool> ("download-server-manifest", () => {
//              result = download_java_version_details (url);
//              Idle.add ((owned) callback);
//              return true;
//          });
//          yield;

//          if (result != null) {
//              debug (result.downloads.get (Foreman.Models.JavaVersionDetails.Download.Type.SERVER).url);
//          }

//          return result;
//      }

//      private Foreman.Models.JavaVersionManifest? download_java_version_manifest () {
//          try {
//              string result = Foreman.Utils.HttpUtils.get_as_string (JAVA_VERSION_MANIFEST_URL);
//              Foreman.Models.JavaVersionManifest? manifest = Foreman.Utils.JsonUtils.parse_json_obj (result, (json_obj) => {
//                  return Foreman.Models.JavaVersionManifest.from_json (json_obj);
//              }) as Foreman.Models.JavaVersionManifest;
//              if (manifest == null) {
//                  Idle.add (() => {
//                      var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch available servers", "Unable to parse the response from the server", "dialog-error", Gtk.ButtonsType.CLOSE);
//                      message_dialog.run ();
//                      message_dialog.destroy ();
//                      return false;
//                  });
//              }
//              return manifest;
//          } catch (GLib.Error e) {
//              var error = e.message;
//              warning (error);
//              Idle.add (() => {
//                  var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch available servers", error, "dialog-error", Gtk.ButtonsType.CLOSE);
//                  message_dialog.run ();
//                  message_dialog.destroy ();
//                  return false;
//              });
//          }
//          return null;
//      }

//      private Foreman.Models.JavaVersionDetails? download_java_version_details (string url) {
//          try {
//              string result = Foreman.Utils.HttpUtils.get_as_string (url);
//              Foreman.Models.JavaVersionDetails? details = Foreman.Utils.JsonUtils.parse_json_obj (result, (json_obj) => {
//                  return Foreman.Models.JavaVersionDetails.from_json (json_obj);
//              }) as Foreman.Models.JavaVersionDetails;
//              if (details == null) {
//                  Idle.add (() => {
//                      var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch version details", "Unable to parse the response from the server", "dialog-error", Gtk.ButtonsType.CLOSE);
//                      message_dialog.run ();
//                      message_dialog.destroy ();
//                      return false;
//                  });
//              }
//              return details;
//          } catch (GLib.Error e) {
//              var error = e.message;
//              warning (error);
//              Idle.add (() => {
//                  var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Unable to fetch version details", error, "dialog-error", Gtk.ButtonsType.CLOSE);
//                  message_dialog.run ();
//                  message_dialog.destroy ();
//                  return false;
//              });
//          }
//          return null;
//      }

//  }
