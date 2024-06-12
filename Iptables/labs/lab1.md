# Cấu hình SNAT và DNAT trên IPTABLES
## Cấu hình SNAT
### 1. Mô hình

<div style="text-align: center;">
    <img src="https://imgur.com/v67wAYx.jpg">
</div>

 **Yêu cầu**
-  Server trong LAN iptables có thể đi interner (ping được đến google.com)
- Sơ đồ IP 
<div style="text-align: center;">
    <img src="https://imgur.com/MuFVCMl.jpg">
</div>

### 2. Cấu hình triển khai
- Thực hiện cấu hình NAT để server trong mạng LAN có thể kết nối ra ngoài internet
- Bật tính năng định tuyến cho firewall
```sh
echo '1' > /proc/sys/net/ipv4/ip_forward
```
Hoặc thêm trong ***/etc/sysctl.conf***
```sh
net.ipv4.ip_forward = 1
sysctl -p
```
- Để Server có thể ping ra ngoài internet thì firewall cần dùng SNAT và đặt rule ở chain **POSTROUTING** với **MASQUERADE**. **MASQUERADE** thường dùng cho các kết nối internet thông qua ppo hoặc ip động
```sh
iptables -t nat -A POSTROUTING -o ens34 -j MASQUERADE
# Hoặc 
iptables -t nat -A POSTROUTING -o ens34 -j SNAT --to-source 192.168.146.214
# Ghi log gói tin icmp đi qua khi ping 
iptables -A FORWARD -p icmp -j LOG --log-prefix "ICMP Packet: " --log-level 4
```
- Lưu config và restart lại iptables
```sh
service iptables save
service iptables restart
```
**Kết quả**
- Trên Server CentOS 7
<div style="text-align: center;">
    <img src="https://imgur.com/AmCW5bf.jpg">
</div>
- Logs trả về trên iptables
<div style="text-align: center;">
    <img src="https://imgur.com/uNeWLWq.jpg">
</div>

Kết quả gồm các thông tin như:
- IN=ens33 OUT=ens34: Gói tin đi vào qua ens33 và đi ra qua ens34.
- MAC=00:0c:29:e7:90:31:00:0c:29:47:b3:5c:08:00: Địa chỉ MAC của các thiết bị liên quan.
- SRC=192.168.114.129: Địa chỉ IP nguồn (máy ảo test2).
- DST=172.217.27.14: Địa chỉ IP đích (một máy chủ của Google).