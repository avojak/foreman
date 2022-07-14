/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public class Foreman.Services.JavaPlayerLeftLogHandler : Foreman.Services.LogHandler<Foreman.Models.JavaLogMessage> {

    private const string REGEX_STR = """^(?P<username>.*) left the game$""";

    private static GLib.Regex regex;

    static construct {
        try {
            regex = new GLib.Regex (REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
        } catch (GLib.RegexError e) {
            critical ("Error while constructing regex: %s", e.message);
        }
    }

    protected override bool do_handle (Foreman.Models.JavaLogMessage message, Foreman.Services.LogHandler.Source source) {
        string? username = null;
        try {
            regex.replace_eval (message.message, -1, 0, GLib.RegexMatchFlags.ANCHORED, (match_info, result) => {
                username = match_info.fetch_named ("username");
                return false;
            });
            player_left (username);
        } catch (GLib.Error e) {
            warning (e.message);
        }
        return true;
    }

    protected override bool can_handle (Foreman.Models.JavaLogMessage message, Foreman.Services.LogHandler.Source source) {
        return message.message != null && regex.match (message.message);
    }

    public signal void player_left (string username);

}
