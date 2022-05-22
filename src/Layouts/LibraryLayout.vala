//  /*
//   * SPDX-License-Identifier: GPL-3.0-or-later
//   * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
//   */

//  public class Foreman.Layouts.LibraryLayout : Gtk.Grid {

//      public unowned Foreman.Windows.MainWindow window { get; construct; }

//      private Gtk.Stack stack;

//      public LibraryLayout (Foreman.Windows.MainWindow window) {
//          Object (
//              window: window
//          );
//      }

//      construct {
//          var header_bar = new Foreman.Widgets.HeaderBar ();

//          stack = new Gtk.Stack () {
//              expand = true
//          };
//          stack.add_named (new Foreman.Views.Welcome (window), Foreman.Views.Welcome.NAME);

//          var base_grid = new Gtk.Grid () {
//              expand = true
//          };
//          base_grid.attach (stack, 0, 0);

//          attach (header_bar, 0, 0);
//          attach (base_grid, 0, 1);

//          show_all ();
//      }

//  }
