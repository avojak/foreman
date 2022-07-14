/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.JavaEditionServer : Foreman.Services.Server<Foreman.Models.JavaLogMessage> {

    private const string STARTUP_CMD = "java -Xmx1024M -Xms1024M -jar server.jar nogui"; // TODO: Tune JVM settings

    public JavaEditionServer (string name, string server_version) {
        this.new_for_context (new Foreman.Services.Server.Context.new_for_version (name, Foreman.Models.ServerType.JAVA_EDITION, server_version));
    }

    public JavaEditionServer.new_for_context (Foreman.Services.Server.Context context) {
        Object (
            context: context
        );
    }

    construct {
        var startup_log_handler = new Foreman.Services.JavaStartupLogHandler ();
        startup_log_handler.starting.connect (on_server_starting);
        startup_log_handler.progress.connect (on_server_startup_progress);
        startup_log_handler.complete.connect (on_server_started);
        startup_log_handler.failed.connect (on_server_startup_failed);

        var player_join_log_handler = new Foreman.Services.JavaPlayerJoinLogHandler ();
        player_join_log_handler.player_joined.connect (on_player_joined);

        var player_left_log_handler = new Foreman.Services.JavaPlayerLeftLogHandler ();
        player_left_log_handler.player_left.connect (on_player_left);

        var sink_log_handler = new Foreman.Services.JavaSinkLogHandler ();
        sink_log_handler.message_logged.connect (on_message_logged);
        sink_log_handler.warning_logged.connect (on_warning_logged);
        sink_log_handler.error_logged.connect (on_error_logged);

        log_handlers.add (startup_log_handler);
        log_handlers.add (player_join_log_handler);
        log_handlers.add (player_left_log_handler);
        log_handlers.add (sink_log_handler);
    }

    public override string get_startup_cmd () {
        return STARTUP_CMD;
    }

    public override Foreman.Models.JavaLogMessage create_log_message (string line) {
        return new Foreman.Models.JavaLogMessage.from_output (line);
    }

}
