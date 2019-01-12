resource drbd {
  protocol C;
  meta-disk internal;
  device /dev/drbd1;
  on d1 {
    disk /dev/sdb;
    address 192.168.1.101:7789;
  }
  on d2 {
    disk /dev/sdb;
    address 192.168.1.102:7789;
  }
}
