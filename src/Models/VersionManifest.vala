/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Models.VersionManifest : GLib.Object {

    public class Latest : GLib.Object {

        public string release { get; set; }
        public string snapshot { get; set; }

        public static Latest from_json (Json.Object json) {
            var obj = new Latest ();
            foreach (unowned string name in json.get_members ()) {
                switch (name) {
                    case "release":
                        obj.release = json.get_string_member (name);
                        break;
                    case "snapshot":
                        obj.snapshot = json.get_string_member (name);
                        break;
                    default:
                        warning ("Unsupported attribute: %s", name);
                        break;
                }
            }
            return obj;
        }

    }

    public class Version : GLib.Object {

        public enum Type {

            OLD_ALPHA, OLD_BETA, SNAPSHOT, RELEASE;

            public static Type from_string (string str) {
                switch (str) {
                    case "old_alpha":
                        return OLD_ALPHA;
                    case "old_beta":
                        return OLD_BETA;
                    case "snapshot":
                        return SNAPSHOT;
                    case "release":
                        return RELEASE;
                    default:
                        assert_not_reached ();
                }
            }

        }

        public string id { get; set; }
        public Type version_type { get; set; }
        public string url { get; set; }
        public string time { get; set; }
        public string release_time { get; set; }

        public static Version from_json (Json.Object json) {
            var obj = new Version ();
            foreach (unowned string name in json.get_members ()) {
                switch (name) {
                    case "id":
                        obj.id = json.get_string_member (name);
                        break;
                    case "type":
                        obj.version_type = Type.from_string (json.get_string_member (name));
                        break;
                    case "url":
                        obj.url = json.get_string_member (name);
                        break;
                    case "time":
                        obj.time = json.get_string_member (name);
                        break;
                    case "releaseTime":
                        obj.release_time = json.get_string_member (name);
                        break;
                    default:
                        warning ("Unsupported attribute: %s", name);
                        break;
                }
            }
            return obj;
        }

    }

    public Latest latest { get; set; }
    public Gee.Map<string, Version> versions { get; set; }

    public static VersionManifest from_json (Json.Object json) {
        var obj = new VersionManifest ();
        foreach (unowned string name in json.get_members ()) {
            switch (name) {
                case "latest":
                    obj.latest = Latest.from_json (json.get_object_member (name));
                    break;
                case "versions":
                    obj.versions = new Gee.HashMap<string, Version> ();
                    foreach (var element in json.get_array_member (name).get_elements ()) {
                        var version = Version.from_json (element.get_object ());
                        obj.versions.set (version.id, version);
                    }
                    break;
            }
        }
        return obj;
    }

}