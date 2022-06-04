/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Models.SemVer : GLib.Object {

    private const string REGEX_STR = """^(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)(?:-(?P<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$""";

    private static GLib.Regex regex;

    public int major { get; set; }
    public int minor { get; set; }
    public int patch { get; set; }
    public string? pre_release { get; set; }
    public string? build_metadata { get; set; }

    static construct {
        try {
            regex = new GLib.Regex (REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
        } catch (GLib.RegexError e) {
            critical ("Error while constructing regex: %s", e.message);
        }
    }

    public SemVer.from_string (string str) {
        try {
            regex.replace_eval (str, -1, 0, GLib.RegexMatchFlags.ANCHORED, (match_info, result) => {
                major = int.parse (match_info.fetch_named ("major"));
                minor = int.parse (match_info.fetch_named ("minor"));
                patch = int.parse (match_info.fetch_named ("patch"));
                pre_release = match_info.fetch_named ("pre_release");
                build_metadata = match_info.fetch_named ("build_metadata");
                return false;
            });
        } catch (GLib.RegexError e) {
            // TODO
            warning ("Error parsing semantic version \"%s\": %s", str, e.message);
        }
    }

    public static GLib.CompareFunc<Foreman.Models.SemVer?> compare_func = (a, b) => {
        if (a == null && b == null) {
            return 0;
        }
        if (a == null && b != null) {
            return -1;
        }
        if (a.major != b.major) {
            return (int) (a.major > b.major) - (int) (a.major < b.major);
        }
        if (a.minor != b.minor) {
            return (int) (a.minor > b.minor) - (int) (a.minor < b.minor);
        }
        if (a.patch != b.patch) {
            return (int) (a.patch > b.patch) - (int) (a.patch < b.patch);
        }
        if (a.pre_release != null && b.pre_release != null) {

        }
        GLib.CompareFunc<string> s = GLib.strcmp;
    };

}
