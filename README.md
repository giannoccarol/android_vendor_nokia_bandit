# Vendor files for the Nokia Lumia 1520 (bandit)

Proprietary files for the LineageOS 18.1 port. Empty for now.

- Firmware specific to the 1520 is extracted from the phone's own Windows
  Phone image (`qcadsp8974.mbn`, `qcwcnss8974.mbn`, modem and Venus images)
  and split into `.mdt`/`.bNN` files.
- MAC addresses, EFS/modem data and other per-device data are never
  committed here.
- Generic MSM8974 Android blobs come from TheMuppets
  (`proprietary_vendor_oppo`, `proprietary_vendor_oneplus`, lineage-18.1).
