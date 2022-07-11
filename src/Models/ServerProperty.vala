/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public abstract class Foreman.Models.ServerProperty<T> : GLib.Object {

    public string schema_key { get; construct; }
    public string property_key { get; construct; }
    public T value { get; set; }

    protected ServerProperty (string schema_key, string? property_key = null) {
        Object (
            schema_key: schema_key,
            property_key: property_key == null ? schema_key : property_key,
            value: get_default_value ()
        );
    }

    protected abstract T get_default_value ();

    public abstract void set_from_string (string str);
    public abstract string as_string ();

}

public class Foreman.Models.StringServerProperty : Foreman.Models.ServerProperty<string> {

    public StringServerProperty (string schema_key, string? property_key = null) {
        this (schema_key, property_key);
    }

    protected override string get_default_value () {
        return Foreman.Application.settings.get_string (schema_key);
    }

    public override void set_from_string (string str) {
        this.value = str;
    }

    public override string as_string () {
        return this.value;
    }

}

public class Foreman.Models.BooleanServerProperty : Foreman.Models.ServerProperty<bool> {

    public BooleanServerProperty (string schema_key, string? property_key = null) {
        this (schema_key, property_key);
    }

    protected override bool get_default_value () {
        return Foreman.Application.settings.get_boolean (schema_key);
    }

    public override void set_from_string (string str) {
        this.value = bool.parse (str);
    }

    public override string as_string () {
        return this.value.to_string ();
    }

}

public class Foreman.Models.IntegerServerProperty : Foreman.Models.ServerProperty<int> {

    public IntegerServerProperty (string schema_key, string? property_key = null) {
        this (schema_key, property_key);
    }

    protected override int get_default_value () {
        return Foreman.Application.settings.get_int (schema_key);
    }

    public override void set_from_string (string str) {
        this.value = int.parse (str);
    }

    public override string as_string () {
        return this.value.to_string ();
    }

}

//  public class Foreman.Models.EnumServerProperty<T> : Foreman.Models.ServerProperty<T> {

//      public EnumServerProperty (string schema_key, string? property_key = null) {
//          this (schema_key, property_key);
//      }

//      protected override T get_default_value () {
//          return Foreman.Application.settings.get_string (schema_key);
//      }

//  }