/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

 public class Foreman.Widgets.Dialogs.MojangEULADialog : Granite.MessageDialog {

    public MojangEULADialog (Foreman.Windows.MainWindow main_window) {
        Object (
            primary_text: _("End User License Agreement"),
            secondary_text: _("By checking the box below you are indicating your agreement to the Minecraft EULA."),
            image_icon: new GLib.ThemedIcon ("text-x-copying"),
            badge_icon: new GLib.ThemedIcon ("dialog-information"),
            modal: true,
            transient_for: main_window
        );
    }

    construct {
        var eula_link = new Gtk.LinkButton.with_label ("https://account.mojang.com/documents/minecraft_eula", "Minecraft End User License Agreement");
        var check_button = new Gtk.CheckButton.with_label (_("I accept the terms in the Minecraft EULA"));

        var custom_content = new Gtk.Grid () {
            row_spacing = 20
        };
        custom_content.attach (eula_link, 0, 0);
        custom_content.attach (check_button, 0, 1);
        custom_content.show_all ();

        custom_bin.add (custom_content);

        unowned var accept_button = add_button ("Accept", Gtk.ResponseType.ACCEPT);
        unowned var decline_button = add_button ("Decline", Gtk.ResponseType.REJECT);

        accept_button.set_sensitive (false);
        accept_button.bind_property ("sensitive", check_button, "active", GLib.BindingFlags.BIDIRECTIONAL, null, null);

        set_focus (decline_button);
    }

}
