# Cấu hình SNAT và DNAT trên IPTABLES
## Cấu hình SNAT
### 1. Mô hình

<div style="text-align: center;">
    <img src="https://imgur.com/v67wAYx.jpg">
</div>

 **Yêu cầu**
-  Server trong LAN iptables có thể đi interner (ping được đến google.com)
- Sơ đồ IP 

|server|IP|
|------|--|
|Server Centso 7|ens33 IP: 192.168.114.129
||Gateway: 192.168.114.130|
|Firewall-iptables|ens33 IP: 192.168.114.130
||ens34 IP: 192.168.146.214