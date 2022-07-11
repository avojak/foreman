conf_data = configuration_data()
conf_data.set('APP_ID', application_id)
conf_data.set('APP_NAME', application_name)
conf_data.set('VERSION', meson.project_version())

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

application_files = files(
    join_paths('Core', 'Client.vala'),
    join_paths('Layouts', 'MainLayout.vala'),
    join_paths('Models', 'ColorPalette.vala'),
    join_paths('Models', 'Difficulty.vala'),
    join_paths('Models', 'GameMode.vala'),
    join_paths('Models', 'LogMessage.vala'),
    join_paths('Models', 'SemVer.vala'),
    join_paths('Models', 'ServerExecutable.vala'),
    join_paths('Models', 'ServerProperties.vala'),
    join_paths('Models', 'ServerProperty.vala'),
    join_paths('Models', 'VersionDetails.vala'),
    join_paths('Models', 'VersionManifest.vala'),
    join_paths('Models', 'WorldPreset.vala'),
    join_paths('Services', 'LogHandler', 'LogHandler.vala'),
    join_paths('Services', 'LogHandler', 'PlayerJoinLogHandler.vala'),
    join_paths('Services', 'LogHandler', 'PlayerLeftLogHandler.vala'),
    join_paths('Services', 'LogHandler', 'SinkLogHandler.vala'),
    join_paths('Services', 'LogHandler', 'StartupLogHandler.vala'),
    join_paths('Services', 'ActionManager.vala'),
    join_paths('Services', 'JavaExecutionService.vala'),
    join_paths('Services', 'Server.vala'),
    join_paths('Services', 'ServerDownloadService.vala'),
    join_paths('Services', 'ServerExecutableRepository.vala'),
    join_paths('Services', 'ServerManager.vala'),
    join_paths('Services', 'ServerRepository.vala'),
    join_paths('Services', 'SQLClient.vala'),
    join_paths('Utils', 'FileUtils.vala'),
    join_paths('Utils', 'FontUtils.vala'),
    join_paths('Utils', 'HttpUtils.vala'),
    join_paths('Utils', 'JsonUtils.vala'),
    join_paths('Utils', 'NetUtils.vala'),
    # join_paths('Views', 'Settings', 'AbstractSettingsView.vala'),
    join_paths('Views', 'Settings', 'GameplaySettingsPage.vala'),
    join_paths('Views', 'Settings', 'GameplaySettingsPage.vala'),
    join_paths('Views', 'Settings', 'JavaRuntimeSettingsPage.vala'),
    join_paths('Views', 'Settings', 'ModerationSettingsPage.vala'),
    join_paths('Views', 'Settings', 'NetworkSettingsPage.vala'),
    join_paths('Views', 'Settings', 'WorldBuildingSettingsPage.vala'),
    join_paths('Views', 'ServerDetailView.vala'),
    join_paths('Views', 'WelcomeView.vala'),
    join_paths('Widgets', 'Dialogs', 'Settings', 'AbstractPreferencesDialog.vala'),
    join_paths('Widgets', 'Dialogs', 'Settings', 'PreferencesDialog.vala'),
    join_paths('Widgets', 'Dialogs', 'AvailableServerDownloadsDialog.vala'),
    join_paths('Widgets', 'Dialogs', 'ConfigureServerDialog.vala'),
    join_paths('Widgets', 'Dialogs', 'CreateNewServerDialog.vala'),
    join_paths('Widgets', 'Dialogs', 'DownloadingDialog.vala'),
    join_paths('Widgets', 'Dialogs', 'HelpDialog.vala'),
    join_paths('Widgets', 'Dialogs', 'MojangEULADialog.vala'),
    join_paths('Widgets', 'LogOutput.vala'),
    join_paths('Widgets', 'NewServerActionBar.vala'),
    join_paths('Widgets', 'PrimaryHeaderBar.vala'),
    join_paths('Widgets', 'ProgressButton.vala'),
    join_paths('Windows', 'MainWindow.vala'),
    join_paths('Application.vala')
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    application_id,
    application_files,
    config_header,
    css_gresource,
    dependencies: [
        dependency('gtk+-3.0', version: '>= 3.24.20'),
        dependency('gee-0.8', version: '>= 0.20.3'),
        dependency('glib-2.0', version: '>= 2.64.6'),
        dependency('gobject-2.0', version: '>= 2.64.6'),
        dependency('granite', version: '>= 6.2.0'),
        dependency('libhandy-1', version: '>= 1.2.0'),
        dependency('sqlite3', version: '>= 3.22.0'),
        dependency('libsoup-2.4'),
        dependency('json-glib-1.0'),
        # dependency('livechart', version: '>= 1.9.1'),
        # dependency('libnm', version: '>= 1.22.10'),
        dependency('semver-1', version: '>= 1.0.0'),
        meson.get_compiler('vala').find_library('posix')
    ],
    vala_args: vala_args,
    install: true
)
