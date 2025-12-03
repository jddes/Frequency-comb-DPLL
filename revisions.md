
Version log

2024-05-15: Firmware update to protect against loss-of-clock event leaving high-voltage switcher mosfet on.
Firmware: red_pitaya_ext_int.bit, SHA256: 4d83b4fa4c193436f55c7a2073a280628674aa820281b9103575daefaa624e45
Software: monitor-tcp, SHA256: 63ad3b3e57df7c65615f8fccf5e76b86de2a5764975532f332a415cbf7afd346
Commit SHA-1: de7f8c4ff1635bc6103efce52a896e75078ecbe6


**** Reminder of how to compute a file's SHA256 on Windows:
certutil -hashfile red_pitaya_top_ext_int.bit SHA256
On Linux:
sha256sum /opt/red_pitaya_top.bit
