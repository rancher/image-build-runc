# rancher/hardened-runc

## Build

```sh
TAG=v0.4.0 make
```

The `TAG` file contains the two newest supported runc minor versions. Running `make` builds the newest version; use `make image-build-all` to build both maintained versions.