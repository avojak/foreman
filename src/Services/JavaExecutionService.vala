/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.JavaExecutionService : GLib.Object {

    private static GLib.Once<Foreman.Services.JavaExecutionService> instance;
    public static unowned Foreman.Services.JavaExecutionService get_default () {
        return instance.once (() => { return new Foreman.Services.JavaExecutionService (); });
    }

    public async bool execute_async (string cmd) {
        GLib.SourceFunc callback = execute_async.callback;

        bool result = false;
        new GLib.Thread<void> ("java-cmd", () => {
            result = execute_sync (cmd);
            Idle.add ((owned) callback);
        });
        yield;

        return result;
    }

    public bool execute_sync (string cmd, string? working_dir = null) {
        return new Thread<bool> ("cmd", () => {
            string[] spawn_args = cmd.split (" ");
            string[] spawn_env = GLib.Environ.get ();
            GLib.Pid child_pid;
            int stdin;
            int stdout;
            int stderr;
            bool? is_success = null;
            try {
                GLib.Process.spawn_async_with_pipes (working_dir,
                    spawn_args,
                    spawn_env,
                    GLib.SpawnFlags.SEARCH_PATH | GLib.SpawnFlags.DO_NOT_REAP_CHILD,
                    null,
                    out child_pid,
                    out stdin,
                    out stdout,
                    out stderr);
                GLib.IOChannel output = new GLib.IOChannel.unix_new (stdout);
                output.add_watch (GLib.IOCondition.IN | GLib.IOCondition.HUP, (channel, condition) => {
                    return process_line (channel, condition, "stdout");
                });
                GLib.IOChannel error = new GLib.IOChannel.unix_new (stderr);
                error.add_watch (GLib.IOCondition.IN | GLib.IOCondition.HUP, (channel, condition) => {
                    return process_line (channel, condition, "stderr");
                });
                GLib.ChildWatch.add (child_pid, (pid, status) => {
                    GLib.Process.close_pid (pid);
                    try {
                        is_success = GLib.Process.check_exit_status (status);
                    } catch (GLib.Error e) {
                        warning (e.message);
                    }
                });
            } catch (GLib.SpawnError e) {
                warning (e.message);
                return false;
            }
            while (is_success == null) {
                Thread.usleep (100000);
            }
            return is_success;
        }).join ();
    }

    private bool process_line (GLib.IOChannel channel, GLib.IOCondition condition, string stream_name) {
        if (condition == GLib.IOCondition.HUP) {
            print ("%s: The fd has been closed\n", stream_name);
            return false;
        }
        try {
            string line;
            channel.read_line (out line, null, null);
            print ("%s: %s\n", stream_name, line.strip ());
        } catch (GLib.IOChannelError e) {
            print ("%s: IOChannelError: %s\n", stream_name, e.message);
            return false;
        } catch (GLib.ConvertError e) {
            print ("%s: ConvertError: %s\n", stream_name, e.message);
            return false;
        }
        return true;
    }

    public double? get_heap_size (string pid) {
        string command = "bash -c \"(jstat -gc %s 2>/dev/null || echo \"0 0 0 0 0 0 0 0 0\") | tail -n 1 | awk '{split($0,a,\" \"); sum=a[3]+a[4]+a[6]+a[8]; print sum/1024}'\"".printf (pid);
        try {
            string stdout;
            string stderr;
            int retcode;
            GLib.Process.spawn_command_line_sync (command, out stdout, out stderr, out retcode);
            return double.parse (stdout);
        } catch (GLib.SpawnError e) {
            warning (e.message);
            return null;
        }
    }

}