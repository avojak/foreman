/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public abstract class Foreman.Models.ServerExecutable : GLib.Object {

    public string version { get; set; }
    public GLib.File directory { get; set; }

}
