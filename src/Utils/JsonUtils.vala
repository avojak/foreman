/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Utils.JsonUtils {

    public static Json.Object? get_json_object (string? json_data) {
        try {
            var parser = new Json.Parser ();
            parser.load_from_data (json_data);
            return parser.get_root ().get_object ();
        } catch (Error e) {
            warning (e.message);
            return null;
        }
    }

    public static Gee.List<GLib.Object>? parse_json_array (string? json_data, JsonDeserializer deserializer) {
        try {
            var parser = new Json.Parser ();
            parser.load_from_data (json_data);
            var root_array = parser.get_root ().get_array ();
            var results = new Gee.ArrayList<GLib.Object> ();
            foreach (var item in root_array.get_elements ()) {
                results.add (deserializer (item.get_object ()));
            }
            return results;
        } catch (Error e) {
            warning (e.message);
            return null;
        }
    }

    public static GLib.Object? parse_json_obj (string? json_data, JsonDeserializer deserializer) {
        Json.Object? root_object = get_json_object (json_data);
        return root_object == null ? null : deserializer (root_object);
    }

    public delegate GLib.Object? JsonDeserializer (Json.Object? json_obj);

}
