/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.Server : GLib.Object {

    public class Launcher : GLib.Object {

        public GLib.File working_directory { get; construct; }
        private GLib.SubprocessLauncher launcher;

        public Launcher (GLib.File working_directory) {
            Object (
                working_directory: working_directory
            );
        }

        construct {
            launcher = new GLib.SubprocessLauncher (GLib.SubprocessFlags.STDOUT_PIPE | GLib.SubprocessFlags.STDERR_PIPE);
            launcher.set_cwd (working_directory.get_path ());
            launcher.set_environ (GLib.Environ.get ());
        }

        public GLib.Subprocess spawn (string cmd) throws GLib.Error {
            return launcher.spawnv (cmd.split (" "));
        }

    }

    public class Context : GLib.Object {

        public string uuid { get; construct; }
        public string server_version { get; construct; }
        public GLib.File server_directory { get; construct; }

        public Context (string server_version) {
            this.for_uuid (GLib.Uuid.string_random (), server_version);
        }

        public Context.for_uuid (string uuid, string server_version) {
            Object (
                uuid: uuid,
                server_version: server_version,
                server_directory: GLib.File.new_for_path (GLib.Path.build_path (GLib.Path.DIR_SEPARATOR_S, Foreman.Services.ServerManager.servers_dir_path, uuid))
            );
        }

    }

    public Context context { get; construct; }

    //  private GLib.Thread<void>? thread;
    private GLib.Cancellable cancellable = new GLib.Cancellable ();

    private GLib.Subprocess? process;

    public Server (string server_version) {
        this.for_context (new Context (server_version));
    }

    public Server.for_context (Context context) {
        Object (
            context: context
        );
    }

    public void start () {
        if (process != null) {
            warning ("Server process already created");
            return;
        }

        string cmd = "java -Xmx1024M -Xms1024M -jar server.jar nogui";
        try {
            process = new Launcher (context.server_directory).spawn (cmd);
            //  process = new GLib.Subprocess.newv (argv, GLib.SubprocessFlags.STDOUT_PIPE | GLib.SubprocessFlags.STDERR_PIPE);
        } catch (GLib.Error e) {
            warning (e.message);
            return;
        }

        var stdout = new GLib.DataInputStream (process.get_stdout_pipe ());
        var stderr = new GLib.DataInputStream (process.get_stderr_pipe ());

        new Thread<void> ("stdout", () => {
            try {
                string? line = null;
                while ((line = stdout.read_line (null, cancellable)) != null) {
                    handle_stdout (line);
                }
            } catch (GLib.Error e) {
                warning (e.message);
                return;
            }
        });
        new Thread<void> ("stderr", () => {
            try {
                string? line = null;
                while ((line = stderr.read_line (null, cancellable)) != null) {
                    handle_stderr (line);
                }
            } catch (GLib.Error e) {
                warning (e.message);
                return;
            }
        });
    }

    private void handle_stdout (string line) {
        print ("stdout: %s\n", line.strip ());
    }

    private void handle_stderr (string line) {
        print ("stderr: %s\n", line.strip ());
    }

    public void stop () {
        if (process != null) {
            process.send_signal (GLib.ProcessSignal.INT);
        }
    }

    public void restart () {

    }

}