/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public abstract class Foreman.Services.LogHandler : GLib.Object {

    public enum Source {
        STDOUT, STDERR;
    }

    public bool handle (Foreman.Models.LogMessage message, Source source) {
        if (can_handle (message, source)) {
            return do_handle (message, source);
        }
        return true;
    }

    /**
     * Returns whether or not to continue propogating the line to other handlers.
     */
    protected abstract bool do_handle (Foreman.Models.LogMessage message, Source source);

    /**
     * Returns whether or not this handler can handle the line of output.
     */
    protected abstract bool can_handle (Foreman.Models.LogMessage message, Source source);

}
