# Vendor files for the Nokia Lumia 1520 (bandit)

Proprietary files for the LineageOS 18.1 port. **This repository is public
and contains no blob**: the files of the 1520 are taken from your own phone
and stay in a local folder ignored by git.

## Files of the 1520 (local only)

`extract-local.sh` fills `proprietary-local/` (in `.gitignore`) from the
folder where the bandit installer/kit extracted the phone's files
(`private/firmware-YYYYMMDD-HHMMSS/`, with `split/`, `stock/` and their
`.sha256` lists). It checks the hashes, copies the files and writes
`proprietary-local/SHA256SUMS` and `SOURCE`.

```bash
./extract-local.sh                         # newest private/firmware-* above this folder
./extract-local.sh /path/to/private/firmware-20261101-160046
```

Run it in every checkout you build from (for example
`los18/vendor/nokia/bandit`): the build container only sees the source tree.

| From the phone (`stock/Windows/system32`, `split/`) | Installed as |
|---|---|
| `qcadsp8974.mbn` → `adsp.mdt/.bNN` | `/vendor/firmware/adsp.*` |
| `qcdsp28974.mbn` → `modem.mdt/.bNN`, `qcdsp1v28974.mbn` → `mba.b00` | `/vendor/firmware/modem.*`, `mba.b00` |
| `qcwcnss8974.mbn` → `wcnss.mdt/.bNN` | `/vendor/firmware/wcnss.*` |
| `qcvss8974.mbn` → `venus.mdt/.bNN` | `/vendor/firmware/venus.*` |
| `qcwlan8974cfg.dat` (same format as `WCNSS_cfg.dat`) | `/vendor/firmware/wlan/prima/WCNSS_cfg.dat` |
| `<Name>_cal_8974.acdb` | `/system/etc/acdbdata/MTP/MTP_<Name>_cal.acdb` |

`bandit-vendor.mk` lists whatever is present in `proprietary-local/` before
the generic files, so the 1520 files win. If the folder is missing the build
still works, without them (and without Venus firmware).

Not taken from the phone yet: the WCNSS NV (`WCNSS_qcom_wlan_nv.bin`, the
generic one from `msm8974-common` is used; the Windows registry has no
separate copy), MAC addresses, EFS/modem data. Per-device data is never
committed here.

## Generic MSM8974 blobs

Adreno, QMI/RIL, location and the other common blobs come from TheMuppets
(`proprietary_vendor_oppo`, `msm8974-common`, lineage-18.1), included by
`bandit-vendor.mk`. The OnePlus One Venus firmware it carries is filtered
out.

## Credits

- [TheMuppets](https://github.com/TheMuppets) — `proprietary_vendor_oppo`
  (generic MSM8974 blobs).
- [LineageOS](https://github.com/LineageOS) — `android_device_oppo_msm8974-common`
  (layout of the blob lists, Wi-Fi/audio configuration).
- [KorelisLabs/lumia-1520-mainline](https://github.com/KorelisLabs/lumia-1520-mainline)
  (HEAD `04f8972`) — list of the 1520 firmware images and `tools/pil-split.py`,
  used by the kit to split them into `.mdt`/`.bNN`.
- [WPinternals](https://github.com/ReneLergner/WPinternals) — mass storage
  access used to extract the files from the phone.
