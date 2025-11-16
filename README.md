# box64-builds

> [!CAUTION]
> This is a work-in-progress. No actual releases exist at this point in time. 

Here you can find various versions of box64 that are automatically built upon a new release or commit to the [ptitSeb/box64](https://github.com/ptitSeb/box64) repository.

## Details regarding releases

- This repository includes versions with the dynamic recompiler (introduced in box64 v0.0.6 for aarch64, and in box64 v0.2.4 for rv64gc) under the "DynaRec" section.
- All releases include box32 by default, starting with box64 v0.3.2.

## Executable list

Executable Name | Chip architecture | Target | Latest release | Version list
------------ | ------------- | ------------- | ------------- | -------------
box64-aarch64 | ARM 64-bit (aarch64), 4K pages | Generic ARM64 (aarch64) systems | [DynaRec]() / [Regular]() | N/A (coming soon)
box64-rv64gc | RISC-V 64-bit (rv64gc), 4K pages | Generic RISC-V (rv64gc) systems | [DynaRec]() / [Regular]() | N/A (coming soon)

Have a target that you would like to see supported? [Open an issue!](https://github.com/alipex/box64-builds/issues/)

## Why?

This project originated with creating box64 executables for custom PufferPanel templates which needed to run on ARM.

Since it is near impossible to actually do the compilation in such a container, this ended up happening as a result.

Anyone can implement these executables into their projects without needing to compile the project or extract the release from a package.

## License

These builds are provided under the Unlicense - the terms can be found [here.](https://github.com/alipex/box64-builds/LICENSE)

Box64 is licensed under the MIT license. If you use box64, you are agreeing to the terms as stipulated [here.](https://github.com/ptitSeb/box64/LICENSE)