/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.BedrockServer : Foreman.Services.Server<Foreman.Models.BedrockLogMessage> {

    private const string STARTUP_CMD = "./bedrock_server";

    public BedrockServer (string name, string server_version) {
        this.new_for_context (new Context.new_for_version (name, Foreman.Models.ServerType.BEDROCK, server_version));
    }

    public BedrockServer.new_for_context (Context context) {
        Object (
            context: context
        );
    }

    construct {
        var startup_log_handler = new Foreman.Services.BedrockStartupLogHandler ();
        startup_log_handler.starting.connect (on_server_starting);
        startup_log_handler.complete.connect (on_server_started);
        startup_log_handler.failed.connect (on_server_startup_failed);

        var player_join_log_handler = new Foreman.Services.BedrockPlayerJoinLogHandler ();
        player_join_log_handler.player_joined.connect (on_player_joined);

        var player_left_log_handler = new Foreman.Services.BedrockPlayerLeftLogHandler ();
        player_left_log_handler.player_left.connect (on_player_left);

        var sink_log_handler = new Foreman.Services.BedrockSinkLogHandler ();
        sink_log_handler.message_logged.connect (on_message_logged);
        sink_log_handler.warning_logged.connect (on_warning_logged);
        sink_log_handler.error_logged.connect (on_error_logged);

        log_handlers.add (startup_log_handler);
        log_handlers.add (player_join_log_handler);
        log_handlers.add (player_left_log_handler);
        log_handlers.add (sink_log_handler);
    }

    public override Gee.Map<string, string> get_environment_variables () {
        var env_vars = new Gee.HashMap<string, string> ();
        env_vars.set ("LD_LIBRARY_PATH", ".");
        return env_vars;
    }

    public override string get_startup_cmd () {
        return STARTUP_CMD;
    }

    public override Foreman.Models.BedrockLogMessage create_log_message (string line) {
        return new Foreman.Models.BedrockLogMessage.from_output (line);
    }

}
