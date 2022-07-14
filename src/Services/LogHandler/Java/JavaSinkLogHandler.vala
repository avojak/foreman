/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Foreman.Services.JavaSinkLogHandler : Foreman.Services.LogHandler<Foreman.Models.JavaLogMessage> {

    protected override bool do_handle (Foreman.Models.JavaLogMessage message, Foreman.Services.LogHandler.Source source) {
        switch (source) {
            case STDOUT:
                if (message.log_level != null) {
                    switch (message.log_level) {
                        case "INFO":
                            message_logged (message.raw);
                            break;
                        case "WARN":
                            warning_logged (message.raw);
                            break;
                        case "ERROR":
                            error_logged (message.raw);
                            break;
                        default:
                            message_logged (message.raw);
                            break;
                    }
                } else {
                    message_logged (message.raw);
                }
                break;
            case STDERR:
                error_logged (message.raw);
                break;
            default:
                break;
        }
        return true;
    }

    protected override bool can_handle (Foreman.Models.JavaLogMessage message, Foreman.Services.LogHandler.Source source) {
        return true;
    }

    public signal void message_logged (string message);
    public signal void warning_logged (string message);
    public signal void error_logged (string message);

}
