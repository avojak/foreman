/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Utils.FileUtils {

    public static bool copy_recursive (GLib.File src, GLib.File dest, GLib.FileCopyFlags flags = GLib.FileCopyFlags.NONE, GLib.Cancellable? cancellable = null) throws GLib.Error {
        GLib.FileType src_type = src.query_file_type (GLib.FileQueryInfoFlags.NONE, cancellable);
        if (src_type == GLib.FileType.DIRECTORY) {
            dest.make_directory (cancellable);
            src.copy_attributes (dest, flags, cancellable);

            string src_path = src.get_path ();
            string dest_path = dest.get_path ();
            GLib.FileEnumerator enumerator = src.enumerate_children (GLib.FileAttribute.STANDARD_NAME, GLib.FileQueryInfoFlags.NONE, cancellable);
            for (GLib.FileInfo? info = enumerator.next_file (cancellable) ; info != null ; info = enumerator.next_file (cancellable)) {
                copy_recursive (
                    GLib.File.new_for_path (GLib.Path.build_filename (src_path, info.get_name ())),
                    GLib.File.new_for_path (GLib.Path.build_filename (dest_path, info.get_name ())),
                    flags,
                    cancellable);
            }
        } else if (src_type == GLib.FileType.REGULAR) {
            src.copy (dest, flags, cancellable);
        }

        return true;
    }

    public static void delete_recursive (GLib.File file, GLib.Cancellable? cancellable = null) throws GLib.Error {
        GLib.FileType file_type = file.query_file_type (GLib.FileQueryInfoFlags.NONE, cancellable);
        if (file_type == GLib.FileType.DIRECTORY) {
            GLib.FileEnumerator enumerator = file.enumerate_children (GLib.FileAttribute.STANDARD_NAME, GLib.FileQueryInfoFlags.NONE, cancellable);
            for (GLib.FileInfo? info = enumerator.next_file (cancellable) ; info != null ; info = enumerator.next_file (cancellable)) {
                delete_recursive (GLib.File.new_for_path (GLib.Path.build_filename (file.get_path (), info.get_name ())), cancellable);
            }
            file.delete (cancellable);
        } else if (file_type == GLib.FileType.REGULAR) {
            file.delete (cancellable);
        }
    }

}
