/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Utils.NetUtils {

    public static string? get_private_ip_addr () {
        string stdout;
        string stderr;
        int exit_status;
        try {
            GLib.Process.spawn_command_line_sync ("ip -j addr", out stdout, out stderr, out exit_status);
        } catch (GLib.SpawnError e) {
            warning (e.message);
            return null;
        }
        try {
            if (GLib.Process.check_exit_status (exit_status)) {
                var addrs = parse_addrs (stdout);
                return addrs.size > 0 ? addrs.get (0) : null;
            }
        } catch (GLib.Error e) {
            warning (stderr);
            warning (e.message);
        }
        return null;
    }

    private static Gee.List<string> parse_addrs (string json) throws GLib.Error {
        var addrs = new Gee.ArrayList<string> ();
        var parser = new Json.Parser ();
        parser.load_from_data (json);
        var root = parser.get_root ();
        root.get_array ().foreach_element ((addr_array, addr_index, addr_element) => {
            var addr_object = addr_element.get_object ();
            if (addr_object.get_string_member ("operstate") != "UP") {
                return;
            }
            var addr_info = addr_object.get_array_member ("addr_info");
            addr_info.foreach_element ((addr_info_array, addr_info_index, addr_info_element) => {
                var addr_info_object = addr_info_element.get_object ();
                if (addr_info_object.get_string_member ("family") != "inet") {
                    return;
                }
                addrs.add (addr_info_object.get_string_member ("local"));
            });
        });
        return addrs;
    }

    public static string? get_public_ip_addr () {
        try {
            return Foreman.Utils.HttpUtils.get_as_string ("https://ifconfig.me/ip", null);
        } catch (GLib.Error e) {
            warning (e.message);
            return null;
        }
    }

}
