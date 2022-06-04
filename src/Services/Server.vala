/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.Server : GLib.Object {

    public enum State {

        NOT_RUNNING, // Not running - nominal
        STARTING, // Startup
        RUNNING, // Running
        STOPPING, // Stopping
        ERRORED; // Not running - off-nominal

        public string get_display_string () {
            switch (this) {
                case NOT_RUNNING:
                    return "Not Running";
                case STARTING:
                    return "Starting";
                case RUNNING:
                    return "Running";
                case STOPPING:
                    return "Stopping";
                case ERRORED:
                    return "Errored";
                default:
                    assert_not_reached ();
            }
        }

        public static State get_value_by_name (string name) {
            EnumClass enumc = (EnumClass) typeof (State).class_ref ();
            unowned EnumValue? eval = enumc.get_value_by_name (name);
            if (eval == null) {
                assert_not_reached ();
            }
            return (State) eval.value;
        }

    }

    private class ProcessLauncher : GLib.Object {

        public GLib.File working_directory { get; construct; }
        private GLib.SubprocessLauncher launcher;

        public ProcessLauncher (GLib.File working_directory) {
            Object (
                working_directory: working_directory
            );
        }

        construct {
            launcher = new GLib.SubprocessLauncher (GLib.SubprocessFlags.STDOUT_PIPE | GLib.SubprocessFlags.STDERR_PIPE | GLib.SubprocessFlags.STDIN_PIPE);
            launcher.set_cwd (working_directory.get_path ());
            launcher.set_environ (GLib.Environ.get ());
        }

        public GLib.Subprocess spawn (string cmd) throws GLib.Error {
            return launcher.spawnv (cmd.split (" "));
        }

    }

    public class Context : GLib.Object {

        public string uuid { get; set; }
        public string name { get; set; }
        public string server_version { get; set; }
        public GLib.File server_directory { get; set; }
        public State state { get; set; }

        public Context.new_for_version (string name, string server_version) {
            this.new_for_uuid (name, server_version, GLib.Uuid.string_random ());
        }

        public Context.new_for_uuid (string name, string server_version, string uuid) {
            Object (
                uuid: uuid,
                name: name,
                server_version: server_version,
                server_directory: GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, Foreman.Services.ServerManager.servers_dir_path, uuid)),
                state: State.NOT_RUNNING
            );
        }

    }

    public Context context { get; construct; }

    private GLib.Cancellable cancellable = new GLib.Cancellable ();
    private GLib.Thread<void>? stdout_thread;
    private GLib.Thread<void>? stderr_thread;
    private GLib.Thread<void>? monitor_thread;
    private GLib.Subprocess? process;
    private Gee.List<Foreman.Services.LogHandler> log_handlers;

    public Server (string name, string server_version) {
        this.new_for_context (new Context.new_for_version (name, server_version));
    }

    public Server.new_for_context (Context context) {
        Object (
            context: context
        );
    }

    construct {
        var startup_log_handler = new Foreman.Services.StartupLogHandler ();
        startup_log_handler.starting.connect (on_server_starting);
        startup_log_handler.progress.connect (on_server_startup_progress);
        startup_log_handler.complete.connect (on_server_started);
        startup_log_handler.failed.connect (on_server_startup_failed);

        var player_join_log_handler = new Foreman.Services.PlayerJoinLogHandler ();
        player_join_log_handler.player_joined.connect (on_player_joined);

        var player_left_log_handler = new Foreman.Services.PlayerLeftLogHandler ();
        player_left_log_handler.player_left.connect (on_player_left);

        var sink_log_handler = new Foreman.Services.SinkLogHandler ();
        sink_log_handler.message_logged.connect (on_message_logged);
        sink_log_handler.warning_logged.connect (on_warning_logged);
        sink_log_handler.error_logged.connect (on_error_logged);

        log_handlers = new Gee.ArrayList<Foreman.Services.LogHandler> ();
        log_handlers.add (startup_log_handler);
        log_handlers.add (player_join_log_handler);
        log_handlers.add (player_left_log_handler);
        log_handlers.add (sink_log_handler);
    }

    private void on_server_starting () {
        context.state = State.STARTING;
        startup_beginning ();
    }

    private void on_server_startup_progress (double progress) {
        startup_progress (progress);
    }

    private void on_server_started () {
        context.state = State.RUNNING;
        startup_complete ();
    }

    private void on_server_startup_failed () {
        context.state = State.ERRORED;
        // TODO: Look for session.lock file in the world/ directory and report that
        startup_failed ();
    }

    private void on_player_joined (string username) {
        player_joined (username);
    }

    private void on_player_left (string username) {
        player_left (username);
    }

    private void on_message_logged (string message) {
        server_message_logged (message);
    }

    private void on_warning_logged (string message) {
        server_warning_logged (message);
    }

    private void on_error_logged (string message) {
        server_error_logged (message);
    }

    public void start () {
        if (process != null) {
            warning ("Server process already created");
            return;
        }

        string cmd = "java -Xmx1024M -Xms1024M -jar server.jar nogui"; // TODO: Tune JVM settings
        try {
            process = new ProcessLauncher (context.server_directory).spawn (cmd);
        } catch (GLib.Error e) {
            warning (e.message);
            return;
        }

        var stdout = new GLib.DataInputStream (process.get_stdout_pipe ());
        var stderr = new GLib.DataInputStream (process.get_stderr_pipe ());

        // Thread to monitor stdout
        stdout_thread = new Thread<void> ("%s-stdout".printf (context.uuid), () => {
            try {
                string? line = null;
                while ((line = stdout.read_line ()) != null) {
                    handle_stdout (line);
                }
            } catch (GLib.Error e) {
                warning (e.message);
                return;
            }
        });

        // Thread to monitor stderr
        stderr_thread = new Thread<void> ("%s-stderr".printf (context.uuid), () => {
            try {
                string? line = null;
                while ((line = stderr.read_line ()) != null) {
                    handle_stderr (line);
                }
            } catch (GLib.Error e) {
                warning (e.message);
                return;
            }
        });

        // Thread to monitor the process and react to exiting or cancellation
        monitor_thread = new Thread<void> ("%s-monitor".printf (context.uuid), () => {
            try {
                process.wait ();
            } catch (GLib.Error e) {
                warning ("Error waiting for process to terminate normally: %s", e.message);
            }

            if (!process.get_if_exited ()) {
                // Check if the process exited abnormally
                errored ();
            } else if (!cancellable.is_cancelled ()) {
                // If the process exited for any reason other than calling stop(), it's an error
                errored ();
            } else {
                stopped ();
            }

            process = null;
        });
    }

    private void handle_stdout (string line) {
        //  print ("stdout: %s\n", line.strip ());
        foreach (var handler in log_handlers) {
            if (!handler.handle (new Models.LogMessage.from_output (line), Foreman.Services.LogHandler.Source.STDOUT)) {
                return;
            }
        }
    }

    private void handle_stderr (string line) {
        //  print ("stderr: %s\n", line.strip ());
        foreach (var handler in log_handlers) {
            if (!handler.handle (new Models.LogMessage.from_output (line), Foreman.Services.LogHandler.Source.STDERR)) {
                return;
            }
        }
    }

    public void stop () {
        stopping ();
        cancellable.cancel ();
        // TODO: Send /stop command instead
        if (process != null) {
            //  process.send_signal (GLib.ProcessSignal.INT);
            send_command ("stop");
            //  process = null;
        }
        //  stopped ();
    }

    public void restart () {

    }

    public void send_command (string command) {
        string line = @"$command\n";
        try {
            process.get_stdin_pipe ().write (line.data);
        } catch (GLib.Error e) {
            warning ("Error writing command to process: %s", e.message);
        }
    }

    public string? get_pid () {
        return process == null ? null : process.get_identifier ();
    }

    public signal void startup_beginning ();
    public signal void startup_progress (double progress);
    public signal void startup_complete ();
    public signal void startup_failed ();
    public signal void stopping ();
    public signal void stopped ();
    public signal void errored (); // TODO: combine with startup_failed?
    public signal void player_joined (string username);
    public signal void player_left (string username);
    public signal void server_message_logged (string message);
    public signal void server_warning_logged (string message);
    public signal void server_error_logged (string message);

}
