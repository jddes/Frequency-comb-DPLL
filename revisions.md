
Version log

2024-05-15: Firmware update to protect against loss-of-clock event leaving high-voltage switcher mosfet on.
Firmware: red_pitaya_ext_int.bit, SHA256: 4d83b4fa4c193436f55c7a2073a280628674aa820281b9103575daefaa624e45
Software: monitor-tcp, SHA256: cbb631b80abc9637c54b17ec44e433554113236aa91ca6bb917a3eee9bf1173f
Commit SHA-1: 20b1279327b9d203d13bd3085a35b6858f87d2c1


**** Reminder of how to compute a file's SHA256 on Windows:
certutil -hashfile red_pitaya_top_ext_int.bit SHA256
On Linux:
sha256sum /opt/red_pitaya_top.bit
