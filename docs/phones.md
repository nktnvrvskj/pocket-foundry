# Phones and drivers

Pocket Foundry draws the game with Mesa's Zink, which runs OpenGL on a Vulkan driver. The bundled driver, Turnip,
only drives Adreno GPUs. For other GPUs you can import a community driver in **Settings → Driver → Import**.

## Adreno 6xx and newer (Snapdragon)

Works out of the box. Tested on a vivo X200 Ultra (Adreno 830, Android 16): 60 FPS and 60 UPS on an early-game save.

A newer Turnip can be imported, such as the `turnip_*_arm64.tar.gz` builds from
[lfdevs/mesa-for-android-container](https://github.com/lfdevs/mesa-for-android-container/releases). Freedreno
(OpenGL straight on the GPU) is in the same list. If text looks garbled, try Freedreno.

## Xclipse (Samsung Exynos)

Import `RADV-Xclipse-upstream-Linux.zip` from
[The412Banner/droiddeck-nonadreno-drivers](https://github.com/The412Banner/droiddeck-nonadreno-drivers/releases/tag/radv-xclipse-upstream).
It's a community build of [JimVulkan/radv-xclipse](https://github.com/JimVulkan/radv-xclipse), not made by Pocket
Foundry.

## Mali (MediaTek, Google Tensor, older Exynos)

The runtime ships **PanVK**, Mesa's Vulkan driver for Mali v9 and newer over Android's own `mali_kbase`, and picks it
by default on those phones: there's nothing to import. It comes from
[PanVK-kbase](https://github.com/zenithblue-oss/panvk-kbase-android), a community build of Mesa, not made by Pocket
Foundry. Sprite quality defaults to Medium there.

The crash to watch for is the sprite upload. PanVK puts two parts of it on the graphics pipeline, where it covers a
whole 4K atlas in one draw and fills the GPU's tiler heap: image copies into its tiled (AFBC) images, and the BC
decode for Factorio's DXT atlases (Mali has no BC textures). `mali_kbase` then reports `tiler heap OOM` during the
upload and the queue group dies (`zink: DEVICE LOST!`). On PanVK the app therefore:

- passes `PANVK_DEBUG=noafbc,bc_compute`, which keeps both the copies and the BC decode on the compute path (no tiler
  heap at all). **Options** may add flags, but these two are kept even if the field sets `PANVK_DEBUG` itself;
- writes **4K atlases, a medium video-memory budget and low-VRAM optimisation** into Factorio's config.

- If Logs still shows `tiler heap OOM` / `DEVICE LOST`, set **Sprite quality** to Low. A newer driver reads
  `PANVK_KBASE_HEAP_CHUNKS=4,400` in **Options** (4 initial and up to 400 two-MiB chunks); the bundled build ignores it.
- Newer PanVK builds also fix kbase bugs behind some of these crashes: import `libvulkan_panfrost-glibc-aarch64.so`
  from a newer [PanVK-kbase release](https://github.com/zenithblue-oss/panvk-kbase-android/releases) once one ships a
  Linux (glibc) driver.
- Older Malis below v9 (G52, G76) aren't covered yet.

Status and reports: [Mali GPUs](https://github.com/JulioFerrero/pocket-foundry/issues/21).

## PowerVR and Adreno 5xx

PowerVR (Pixel 10) has no driver that works here yet. Adreno 5xx and older can't run Turnip, and their kernels lack
what freedreno needs.

## Known to work

| Phone | GPU | Driver | |
|---|---|---|---|
| vivo X200 Ultra | Adreno 830 | Bundled | 60 FPS |
| OnePlus 15 | Adreno 840 | Bundled | |
| Galaxy S24 Ultra | Adreno 750 | Bundled | |
| Xiaomi 13 | Adreno 740 | Bundled | |
| POCO F5 Pro | Adreno 730 | Bundled | 60 FPS ([#20](https://github.com/JulioFerrero/pocket-foundry/issues/20)) |
| Galaxy Z Fold 8 Ultra | Adreno | Bundled | Folded and unfolded |
| Retroid Pocket Flip 2 | Adreno 650 | Bundled | With its own controls |
| Nothing Phone (1) | Adreno 642L | Freedreno | Turnip garbles the main menu's text |
| Galaxy S25 FE | Xclipse 940 | RADV-Xclipse-upstream | 60 FPS ([#18](https://github.com/JulioFerrero/pocket-foundry/issues/18)) |
| Pixel 6 | Mali-G78 | Bundled PanVK | Medium sprites ([#11](https://github.com/JulioFerrero/pocket-foundry/issues/11)) |

Yours works, or doesn't? [Open an issue](https://github.com/JulioFerrero/pocket-foundry/issues) with the Logs
screen's Copy.

## Importing a driver

- Linux (glibc) builds only. Android builds (AdrenoTools, Winlator, emulator packages) can't load in the game.
- A `.tar.gz`, `.tar.xz`, `.zip` or the `.so` alone. Libraries in the package come along.
- Pocket Foundry checks that the driver loads before keeping it.
- **Options** passes `NAME=value` settings to the driver (`PANVK_DEBUG=…`, `TU_DEBUG=…`). Logs shows them.

![Choosing the graphics driver](screenshots/driver.jpg)
