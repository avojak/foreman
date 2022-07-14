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

    public static void extract_archive (GLib.File archive_file) {
        Archive.ExtractFlags flags;
        flags = Archive.ExtractFlags.TIME;
        flags |= Archive.ExtractFlags.PERM;
        flags |= Archive.ExtractFlags.ACL;
        flags |= Archive.ExtractFlags.FFLAGS;

        Archive.Read archive = new Archive.Read ();
        archive.support_format_all ();
        archive.support_filter_all ();

        Archive.WriteDisk extractor = new Archive.WriteDisk ();
        extractor.set_options (flags);
        extractor.set_standard_lookup ();

        if (archive.open_filename (archive_file.get_path (), 10240) != Archive.Result.OK) {
            warning ("Error opening %s: %s (%d)", archive_file.get_path (), archive.error_string (), archive.errno ());
            return;
        }

        unowned Archive.Entry entry;
        Archive.Result last_result;
        while ((last_result = archive.next_header (out entry)) == Archive.Result.OK) {
            entry.set_pathname (archive_file.get_parent ().get_path () + "/" + entry.pathname ());
            if (extractor.write_header (entry) != Archive.Result.OK) {
                continue;
            }
            uint8[] buffer;
            Archive.int64_t offset;
            while (archive.read_data_block (out buffer, out offset) == Archive.Result.OK) {
                if (extractor.write_data_block (buffer, offset) != Archive.Result.OK) {
                    break;
                }
            }
        }

        if (last_result != Archive.Result.EOF) {
            warning ("Error extracting archive: %s (%d)", archive.error_string (), archive.errno ());
        }
    }

}
