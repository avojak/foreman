/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public abstract class Foreman.Models.LogMessage : GLib.Object {

    public string raw { get; set; }
    public string? timestamp { get; set; }
    public string? thread_name { get; set; }
    public string? log_level { get; set; }
    public string? message { get; set; }

}
