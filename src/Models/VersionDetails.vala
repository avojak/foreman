/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Models.VersionDetails : GLib.Object {

    public class Download : GLib.Object {

        public enum Type {

            CLIENT, CLIENT_MAPPINGS, SERVER, SERVER_MAPPINGS;

            public static Type from_string (string str) {
                switch (str) {
                    case "client":
                        return CLIENT;
                    case "client_mappings":
                        return CLIENT_MAPPINGS;
                    case "server":
                        return SERVER;
                    case "server_mappings":
                        return SERVER_MAPPINGS;
                    default:
                        assert_not_reached ();
                }
            }

        }

        public string sha1 { get; set; }
        public int64 size { get; set; }
        public string url { get; set; }

        public static Download from_json (Json.Object json) {
            var obj = new Download ();
            foreach (unowned string name in json.get_members ()) {
                switch (name) {
                    case "sha1":
                        obj.sha1 = json.get_string_member (name);
                        break;
                    case "size":
                        obj.size = json.get_int_member (name);
                        break;
                    case "url":
                        obj.url = json.get_string_member (name);
                        break;
                    default:
                        warning ("Unsupported attribute: %s", name);
                        break;
                }
            }
            return obj;
        }

    }

    public string id { get; set; }
    public Gee.Map<Download.Type, Download> downloads { get; set; }

    public static VersionDetails from_json (Json.Object json) {
        var obj = new VersionDetails ();
        foreach (unowned string name in json.get_members ()) {
            switch (name) {
                case "id":
                    obj.id = json.get_string_member (name);
                    break;
                case "downloads":
                    obj.downloads = new Gee.HashMap<Download.Type, Download> ();
                    var downloads = json.get_object_member (name);
                    foreach (unowned string download_name in downloads.get_members ()) {
                        obj.downloads.set (Download.Type.from_string (download_name), Download.from_json (downloads.get_object_member (download_name)));
                    }
                    break;
                default:
                    // Don't log this, it will be very noisy
                    break;
            }
        }
        return obj;
    }

}