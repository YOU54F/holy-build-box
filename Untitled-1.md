# Holy Build Box Variants

| Platform                 | Architecture | Image                                      | Alpine | Ubuntu | Centos
|--------------------------|--------------|--------------------------------------------|-----------|-----------|-----------|
| ARMv8 64-bit (`arm64v8`) | ARMv8        | [arm64v8](https://hub.docker.com/u/arm64v8/) | ✅  |✅ |✅ |
| Linux x86-64 (`amd64`)   | x86-64       | [amd64](https://hub.docker.com/u/amd64/)     | ✅  |🚧 |✅ |
| x86/i686 (`i386`)        | x86/i686     | [i386](https://hub.docker.com/u/i386/)       | ✅  |🚧 |❌ |
| IBM z Systems (`s390x`)  | z Systems    | [s390x](https://hub.docker.com/u/s390x/)     | ✅  |🚧 |❌ |
| IBM POWER8 (`ppc64le`)   | POWER8       | [ppc64le](https://hub.docker.com/u/ppc64le/) | ✅  |🚧 |🚧 |
| ARMv6 32-bit (`arm32v6`) | ARMv6        | [arm32v6](https://hub.docker.com/u/arm32v6/) | 🚧  |🚧 |❌|
| ARMv7 32-bit (`arm32v7`) | ARMv7        | [arm32v7](https://hub.docker.com/u/arm32v7/) | 🚧  |🚧 |❌|
| ARMv5 32-bit (`arm32v5`) | ARMv5        | [arm32v5](https://hub.docker.com/u/arm32v5/) | 🚧  |🚧 |❌|
| MIPS64 LE (`mips64le`)   | MIPS64 LE    | [mips64le](https://hub.docker.com/u/mips64le/) | ❌ | ❌|❌|
| RISC-V 64-bit (`riscv64`) | RISC-V       | [riscv64](https://hub.docker.com/u/riscv64/) | ❌ | ❌ |❌|
| Windows x86-64 (`windows-amd64`) | x86-64 | [winamd64](https://hub.docker.com/u/winamd64/) | ❌   |❌ |❌|

- Alpine images built against 3.15
- Ubuntu images built against 14.04 (glibc 2.19)
- Centos images built against 7 (glibc 2.17)

Centos RHEL based alternatives

- AlmaLinux 8
  - Update `devtoolset-9` to `gcc-toolset-9`

## Building images

Select a variant

- `alpine`
- `ubuntu`
- `centos7`

Select an arch

- `amd64`
- `arm-v6`
- `arm-v7`
- `arm64`
- `s390x`
- `ppc64le`

Run the following command to build the image

```bash
make build_image VARIANT=ubuntu ARCH=ppc64le
```

Images are loaded to the local docker daemon

Format

`you54f/holy-build-box:<version>-<arch>-<variant>`

Images are pushed to the docker hub, and combined locally into a single image

`you54f/holy-build-box:<variant>`

## Traveling Ruby Supported Platforms

### Linux

| Platform                 | Architecture  | Musl | Glibc
|--------------------------|---------------|------|-------
| ARMv8 64-bit (`arm64v8`) | ARMv8         |  ✅  | ✅
| Linux x86-64 (`amd64`)   | x86-64        |  ✅  | 🚧
| x86/i686 (`i386`)        | x86/i686      |  ✅  | 🚧
| IBM z Systems (`s390x`)  | z Systems     |  ✅  | 🚧
| IBM POWER8 (`ppc64le`)   | POWER8        |  ✅  | 🚧

- Alpine images built against 3.15
- Ubuntu images built against 14.04 (glibc 2.19)
- Centos based packages built against Centos7 (glibc 2.17)

## MacOS

| Platform                 | Architecture  | Supported
|--------------------------|---------------|------
| MacOS x86-64 (`darwin-x86_64`) | x86-64 |  ✅  
| MacOS arm64 (`darwin-arm64`)   | arm64     |  ✅

- macos x86_64 binaries - 10.15 Catalina onwards
- macos arm64 binaries - 11.0 Big Sur onwards

## Windows

| Platform                 | Architecture  | Supported
|--------------------------|---------------|------
| Windows x86-64 (`windows-x86_64`) | x86-64 |  ✅  
| Windows x86 (`windows-x86`)   | x86     |  ✅
| Windows arm64 (`windows-arm64`)   | arm64     |  🚧

- windows-arm64, ruby 3.1.4 only

- 🚧 Native extensions not currently supported
  - Use ocran or aibika (forks of ocran) to build native extensions
- Docker Support
  - Nanoserver images, will work if libgmp from package is copied to C:\Windows\System32
- Wine support
  - x86_64 package fails on darwin-arm64 with unexpected ucrtbase.dll error
    - Workaround, use x86 package on darwin-arm64
- Windows VM support
  - x86_64 package fails when emulated in vm's on darwin-arm64 with unexpected ucrtbase.dll error
    - Workaround, use x86 package on darwin-arm64
    - Workaround, use arm64 package on darwin-arm64
