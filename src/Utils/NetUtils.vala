/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Utils.NetUtils {

    //  public static Gee.List<string> get_private_ip_addrs () {
    //      var addrs = new Gee.ArrayList<string> ();
    //      string stdout;
    //      string stderr;
    //      int exit_status;
    //      try {
    //          GLib.Process.spawn_command_line_sync ("ip -j addr | jq '.[] | select(.operstate==\"UP\") | .addr_info[] | select(.family==\"inet\") | .local' | xargs", out stdout, out stderr, out exit_status);
    //          try {
    //              if (GLib.Process.check_exit_status (exit_status)) {
    //                  addrs.add_all_array (stdout.split (" "));
    //              }
    //          } catch (GLib.Error e) {
    //              warning (stderr);
    //              warning (e.message);
    //          }
    //      } catch (GLib.SpawnError e) {
    //          warning (e.message);
    //      }
    //      return addrs;
    //  }

    //  public static string? get_public_ip_addr () {
    //      string stdout;
    //      string stderr;
    //      int exit_status;
    //      try {
    //          GLib.Process.spawn_command_line_sync ("curl https://ifconfig.me", out stdout, out stderr, out exit_status);
    //          try {
    //              if (GLib.Process.check_exit_status (exit_status)) {
    //                  return stdout;
    //              }
    //          } catch (GLib.Error e) {
    //              warning (e.message);
    //          }
    //      } catch (GLib.SpawnError e) {
    //          warning (e.message);
    //      }
    //      return null;
    //  }

}
