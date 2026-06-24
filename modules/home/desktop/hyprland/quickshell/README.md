# Quickshell bar

This directory contains the configuration of the Quickshell bar.
The Nix module in `default.nix` finds the QML files and sends them to the
configuration directory of the user.

This document gives the guidelines for the QML code.
It does not enforce them.
Three checks in `checks/default.nix` enforce the rules that a machine can test.

## Structure

The code has two layers.
The services layer connects to data outside the process.
The interface layer shows the data to the user.

| Directory              | Content                                                      |
| ---------------------- | ------------------------------------------------------------ |
| `shell.qml`            | The start of the configuration. It makes the three surfaces.  |
| `config/`              | `Config.qml` and `Theme.qml`. Nix puts values into these files.|
| `services/`            | Singletons that own a resource outside the process.            |
| `components/base/`     | Parts that know no domain.                                     |
| `components/bar/`      | The bar windows and the layout of the widgets.                 |
| `components/<domain>/` | All parts of one feature.                                      |

A service gives the interface the data and the actions of one outside system.
Examples are the audio devices, the network, the compositor, and the
notifications.
A service also holds the knowledge of that system, such as the command that
ends the session, or the moment the daemon accepts a scan.

A part may read a value that a service gave it, and name it for the user.
A part must not read the outside system itself, and must not act on it.
The row that shows a device reads the state of that device and writes the word
for it, but it asks the service to connect the device.

A timer that only repaints a part is not a service.
A clock that shows the time belongs to the part that shows it, and a clock that
decides when something happens belongs to a service.
A singleton that holds only interface state is not a service either.
Put such a singleton in the interface layer.

## Rules that the checks test

1. A service must not import the interface layer.
2. A part in `components/base/` must import only `config/`.
3. A domain must not import a different domain.

The check `quickshell-layers` tests these three rules.
The build stops if you break a rule.
Domains meet in `components/bar/BarContent.qml`, and not in each other.

## Facts about QML

QML finds a type in the same directory only.
There is no global scope.
Import each other directory that you use.

An import is text.
You cannot calculate an import path.
Keep the tree one level deep, because each import is a relative path.

A `qmldir` file replaces the scan of its directory.
The file must name every type in that directory.
If the file names only the singletons, QML hides the other types.
The Nix module writes these files from the sources.
Do not write a `qmldir` file by hand.

Other directories cannot see a singleton without a `qmldir` file.

`Qt.resolvedUrl()` gives a path from the file that calls it.
A part that moves to a different directory gets a different path.
Use `Config.iconRoot` for the assets, because the location of `Config.qml` is stable.

`qmllint` does not find these errors.
Start the configuration to test them.

## How to make a change

Send a value down with a property.
Send an event up with a signal.
A part must not read a property of its parent.

Mark a property `required` when the parent must always give a value.
The part then fails immediately if the parent forgets the value.

To add a part to a domain:

1. Put the file in the directory of the domain.
2. Import `../base` for the shared parts, and `../../config` for the tokens.
3. Use the new part in the domain only.

To add a domain:

1. Make a directory in `components/`.
2. Give the domain one public part. Use the name of the domain for this part.
3. Use the public part in `components/bar/BarContent.qml`.
4. Give the values to the part with properties.

To read data from outside the process:

1. Make a singleton in `services/`.
2. Give the data as properties, and give the actions as functions.
3. Read the singleton from the parts of the domain.

To share state between two domains:

1. Do not import one domain from the other.
2. Put the state in a singleton, and let both domains read it.
3. Put the singleton in `services/` if it owns a resource outside the process.
4. Put the singleton in `components/base/` if it holds interface state only.

A singleton that counts its users must give a function to take a reference,
and a function to release it.
Release the reference also when the part is destroyed.

## Guidelines

Give each domain one public part.
Other directories use that part only.
Keep the other parts of the domain private, because you can then change them freely.

Make a directory for each domain, also for a domain with one file.
The directory is the unit of growth.

Do not divide a file before it has two reasons to change.
A long file with one responsibility can stay as one file.

Move code to `components/base/` when a second domain needs it.
Do not move code there for the first domain.

Reserve space for a condition that can occur.
A widget that shows two values from a set can show some pairs only.
A reservation of two times the widest value gives space that no state uses.

Put the work with data in a service.
Keep the parts in `components/` for the display.
