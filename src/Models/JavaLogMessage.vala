/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Models.JavaLogMessage : Foreman.Models.LogMessage {

    private const string REGEX_STR = """^\[(?P<timestamp>[0-9]{2}:[0-9]{2}:[0-9]{2})\] \[(?P<thread_name>.+)\/(?P<log_level>[a-zA-Z]*)\]: (?P<message>.*)$""";

    private static GLib.Regex regex;

    static construct {
        try {
            regex = new GLib.Regex (REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
        } catch (GLib.RegexError e) {
            critical ("Error while constructing regex: %s", e.message);
        }
    }

    public JavaLogMessage.from_output (string line) {
        raw = line;
        try {
            regex.replace_eval (line, -1, 0, GLib.RegexMatchFlags.ANCHORED, (match_info, result) => {
                timestamp = match_info.fetch_named ("timestamp");
                thread_name = match_info.fetch_named ("thread_name");
                log_level = match_info.fetch_named ("log_level");
                message = match_info.fetch_named ("message");
                return false;
            });
        } catch (GLib.RegexError e) {
            // TODO
            warning ("Error parsing log message \"%s\": %s", line, e.message);
        }
    }

}
