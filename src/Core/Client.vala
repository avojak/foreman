/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Core.Client : GLib.Object {

    private static GLib.Once<Foreman.Core.Client> instance;
    public static unowned Foreman.Core.Client get_default () {
        return instance.once (() => { return new Foreman.Core.Client (); });
    }

    public Foreman.Services.ServerDownloadService server_download_service;
    public Foreman.Services.ServerExecutableRepository server_executable_repository;
    public Foreman.Services.JavaExecutionService java_execution_service;
    public Foreman.Services.ServerRepository server_repository;
    public Foreman.Services.ServerManager server_manager;

    construct {
        server_download_service = Foreman.Services.ServerDownloadService.get_default ();
        server_executable_repository = Foreman.Services.ServerExecutableRepository.get_default ();
        java_execution_service = Foreman.Services.JavaExecutionService.get_default ();
        server_repository = Foreman.Services.ServerRepository.get_default ();
        server_manager = Foreman.Services.ServerManager.get_default ();

        server_manager.server_created.connect (server_repository.on_server_created);
        server_manager.server_starting.connect (server_repository.on_server_state_changed);
        server_manager.server_started.connect (server_repository.on_server_state_changed);
        //  server_manager.server_stopping.connect (server_repository.on_server_state_changed);
        //  server_manager.server_stopped.connect (server_repository.on_server_state_changed);
        //  server_manager.server_startup_failed.connect (server_repository.on_server_state_changed);
        //  server_manager.server_errored.connect (server_repository.on_server_state_changed);
        server_manager.server_deleted.connect (server_repository.on_server_deleted);
    }

}