/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Utils.HttpUtils {

    public class DownloadContext : GLib.Object {

        public string url { get; construct; }
        public GLib.File file { get; construct; }
        public int64 total_size { get; construct; }
        public int64 total_read { get; set; }

        public DownloadContext (string url, GLib.File file, int64 total_size) {
            Object (
                url: url,
                file: file,
                total_size: total_size,
                total_read: 0
            );
        }

        public signal void complete ();
        //  public signal void progress (double progress);
        public signal void progress ();

    }

    /**
     * Downloads the file at the given URL.
     *
     * @param url pointing to the file to download
     * @param file where the downloaded content will be saved
     */
    public static void download_file (DownloadContext context, GLib.Cancellable? cancellable = null) throws GLib.Error {
        var session = new Soup.Session ();
        var input_stream = new DataInputStream (session.send (new Soup.Message.from_uri ("GET", new Soup.URI (context.url)), cancellable));
        var output_stream = context.file.replace (null, false, GLib.FileCreateFlags.NONE, cancellable);
        GLib.Bytes bytes;
        while ((bytes = input_stream.read_bytes (256, cancellable)).length != 0) {
            output_stream.write_bytes (bytes, cancellable);
            context.total_read += bytes.length;
            context.progress ();
        }
        //  size_t bytes_read;
        //  uint8[] buffer = new uint8[256];
        //  while ((bytes_read = input_stream.read (buffer, cancellable)) != 0) {
        //      output_stream.write (buffer, cancellable);
        //      context.total_read += bytes_read;
        //      //  context.progress ((double) context.total_read / (double) context.total_size);
        //      context.progress ();
        //  }
        context.complete ();
    }

}
