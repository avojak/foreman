/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.BedrockStartupLogHandler : Foreman.Services.LogHandler<Foreman.Models.BedrockLogMessage> {

    private const string STARTING_REGEX_STR = """^Starting Server$""";
    private const string COMPLETE_REGEX_STR = """^Server started.$""";
    // Error scenarios
    private const string FAILED_START_REGEX_STR = """^Failed to start the minecraft server$""";
    private const string FAILED_BIND_REGEX_STR = """^\*{4} FAILED TO BIND TO PORT!$""";

    private static GLib.Regex starting_regex;
    private static GLib.Regex complete_regex;
    private static GLib.Regex failed_start_regex;
    private static GLib.Regex failed_bind_regex;

    static construct {
        try {
            starting_regex = new GLib.Regex (STARTING_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
            complete_regex = new GLib.Regex (COMPLETE_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
            failed_start_regex = new GLib.Regex (FAILED_START_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
            failed_bind_regex = new GLib.Regex (FAILED_BIND_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
        } catch (GLib.RegexError e) {
            critical ("Error while constructing regex: %s", e.message);
        }
    }

    protected override bool do_handle (Foreman.Models.BedrockLogMessage message, Foreman.Services.LogHandler.Source source) {
        if (starting_regex.match (message.message)) {
            starting ();
        } else if (complete_regex.match (message.message)) {
            complete ();
        } else if (failed_start_regex.match (message.message) || failed_bind_regex.match (message.message)) {
            //  failed ();
        }
        return true;
    }

    protected override bool can_handle (Foreman.Models.BedrockLogMessage message, Foreman.Services.LogHandler.Source source) {
        return message.message != null
                && (starting_regex.match (message.message)
                    || complete_regex.match (message.message)
                    || failed_start_regex.match (message.message)
                    || failed_bind_regex.match (message.message));
    }

    public signal void starting ();
    public signal void complete ();
    public signal void failed ();

}
