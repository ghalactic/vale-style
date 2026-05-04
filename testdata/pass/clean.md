# Installing the application

This guide helps you install and configure the application.

## Before you begin

Make sure you have the following prerequisites:

- A supported operating system (Linux, macOS, or Windows)
- At least 4 GB of RAM
- Network access to the package registry

## Installing on Linux

To install the application on Linux, run the following command:

```sh
sudo apt-get install myapp
```

The installer downloads the package and configures the default settings.

## Configuring the application

After installation, update the configuration file:

1. Open the configuration file at `/etc/myapp/config.yaml`.
1. Set the `port` field to the port number you want.
1. Set the `log_level` field to `info`, `warn`, or `error`.
1. Save the file and restart the service.

## Verifying the installation

To verify that the application is running, use the following command:

```sh
systemctl status myapp
```

If the output shows `active (running)`, the installation succeeded.
