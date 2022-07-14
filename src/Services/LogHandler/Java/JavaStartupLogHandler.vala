/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.JavaStartupLogHandler : Foreman.Services.LogHandler<Foreman.Models.JavaLogMessage> {

    private const string STARTING_REGEX_STR = """^Starting net.minecraft.server.Main$""";
    private const string PROGRESS_REGEX_STR = """^Preparing spawn area: (?P<progress_str>\d{1,2})%$""";
    private const string COMPLETE_REGEX_STR = """^Done \(\d*\.\d*s\)! For help, type \"help\"$""";
    // Error scenarios
    private const string FAILED_START_REGEX_STR = """^Failed to start the minecraft server$""";
    private const string FAILED_BIND_REGEX_STR = """^\*{4} FAILED TO BIND TO PORT!$""";

    private static GLib.Regex starting_regex;
    private static GLib.Regex progress_regex;
    private static GLib.Regex complete_regex;
    private static GLib.Regex failed_start_regex;
    private static GLib.Regex failed_bind_regex;

    static construct {
        try {
            starting_regex = new GLib.Regex (STARTING_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
            progress_regex = new GLib.Regex (PROGRESS_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
            complete_regex = new GLib.Regex (COMPLETE_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
            failed_start_regex = new GLib.Regex (FAILED_START_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
            failed_bind_regex = new GLib.Regex (FAILED_BIND_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
        } catch (GLib.RegexError e) {
            critical ("Error while constructing regex: %s", e.message);
        }
    }

    protected override bool do_handle (Foreman.Models.JavaLogMessage message, Foreman.Services.LogHandler.Source source) {
        if (starting_regex.match (message.raw)) {
            starting ();
        } else if (progress_regex.match (message.message)) {
            string? progress_str = null;
            try {
                progress_regex.replace_eval (message.message, -1, 0, GLib.RegexMatchFlags.ANCHORED, (match_info, result) => {
                    progress_str = match_info.fetch_named ("progress_str");
                    return false;
                });
                progress (double.parse (progress_str) / 100.0);
            } catch (GLib.Error e) {
                warning (e.message);
            }
        } else if (complete_regex.match (message.message)) {
            complete ();
        } else if (failed_start_regex.match (message.message) || failed_bind_regex.match (message.message)) {
            //  failed ();
        }
        return true;
    }

    protected override bool can_handle (Foreman.Models.JavaLogMessage message, Foreman.Services.LogHandler.Source source) {
        return starting_regex.match (message.raw)
                || (message.message != null
                    && (progress_regex.match (message.message)
                        || complete_regex.match (message.message)
                        || failed_start_regex.match (message.message)
                        || failed_bind_regex.match (message.message)));
    }

    public signal void starting ();
    public signal void progress (double progress); // Progress between 0.0 and 1.0
    public signal void complete ();
    public signal void failed ();

}
