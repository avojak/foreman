/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public class Foreman.Services.BedrockPlayerJoinLogHandler : Foreman.Services.LogHandler<Foreman.Models.BedrockLogMessage> {

    private const string REGEX_STR = """^Player connected: (?P<username>.*), xuid: (?<xuid>.*)$""";

    private static GLib.Regex regex;

    static construct {
        try {
            regex = new GLib.Regex (REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
        } catch (GLib.RegexError e) {
            critical ("Error while constructing regex: %s", e.message);
        }
    }

    protected override bool do_handle (Foreman.Models.BedrockLogMessage message, Foreman.Services.LogHandler.Source source) {
        string? username = null;
        string? xuid = null;
        try {
            regex.replace_eval (message.message, -1, 0, GLib.RegexMatchFlags.ANCHORED, (match_info, result) => {
                username = match_info.fetch_named ("username");
                xuid = match_info.fetch_named ("xuid");
                return false;
            });
            player_joined (username);
        } catch (GLib.Error e) {
            warning (e.message);
        }
        return true;
    }

    protected override bool can_handle (Foreman.Models.BedrockLogMessage message, Foreman.Services.LogHandler.Source source) {
        return message.message != null && regex.match (message.message);
    }

    public signal void player_joined (string username);

}
