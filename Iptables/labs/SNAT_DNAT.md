# Lab mô phỏng SNAT, DNAT trên Centos 7

- server **test01** (SNAT): IP là 192.168.80.134
- server **test02** (DNAT): IP là 192.168.80.133

### Cấu hình SNAT trên server test01 (192.168.80.134)

SNAT được sử dụng để thay đổi địa chỉ IP nguồn của gói tin khi nó rời khỏi mạng nội bộ.

1. **Kích hoạt tính năng chuyển tiếp IP trên server test01**:
   ```sh
   echo 1 > /proc/sys/net/ipv4/ip_forward
   ```

   Để cấu hình vĩnh viễn:
   ```sh
   echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
   sysctl -p
   ```

2. **Cấu hình iptables để thực hiện SNAT**:
   Giả sử server test01 sẽ thay đổi địa chỉ IP nguồn của gói tin từ mạng nội bộ thành IP công cộng của nó (nếu có). Nếu bạn chỉ muốn thay đổi thành IP của server test01 thì làm như sau:
   ```sh
   iptables -t nat -A POSTROUTING -s 10.3.2.0/24 -o ens33 -j SNAT --to-source 192.168.80.134
   ```

3. **Lưu cấu hình iptables**:
   ```sh
   service iptables save
   ```

4. **Khởi động lại dịch vụ iptables**:
   ```sh
   systemctl restart iptables
   ```

### Cấu hình DNAT trên máy chủ B (192.168.80.133)

DNAT được sử dụng để thay đổi địa chỉ IP đích của gói tin khi nó vào mạng nội bộ từ bên ngoài.

1. **Kích hoạt tính năng chuyển tiếp IP trên máy chủ B**:
   ```sh
   echo 1 > /proc/sys/net/ipv4/ip_forward
   ```

   Để cấu hình vĩnh viễn:
   ```sh
   echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
   sysctl -p
   ```

2. **Cấu hình iptables để thực hiện DNAT**:
   Giả sử máy chủ B sẽ chuyển tiếp gói tin đến IP nội bộ khác (ví dụ: 10.3.2.194) khi nhận gói tin từ một địa chỉ IP công cộng.

   ```sh
   iptables -t nat -A PREROUTING -d 192.168.80.133 -p tcp --dport 80 -j DNAT --to-destination 10.3.2.194:80
   ```

   Bạn có thể thay đổi địa chỉ IP và cổng tùy theo yêu cầu của bạn.

3. **Lưu cấu hình iptables**:
   ```sh
   service iptables save
   ```

4. **Khởi động lại dịch vụ iptables**:
   ```sh
   systemctl restart iptables
   ```

### Kiểm tra cấu hình

Để kiểm tra xem cấu hình SNAT và DNAT đã hoạt động chưa, bạn có thể thực hiện các bước sau:

1. **Trên server test01 (SNAT)**, kiểm tra xem các gói tin từ mạng nội bộ có được thay đổi địa chỉ IP nguồn thành IP của server test01 hay không. Bạn có thể sử dụng `tcpdump` để theo dõi các gói tin:
   ```sh
   tcpdump -i eth0
   ```

2. **Trên máy chủ B (DNAT)**, kiểm tra xem các gói tin đến IP của máy chủ B có được chuyển tiếp đến địa chỉ IP đích đã cấu hình hay không. Bạn có thể sử dụng `tcpdump` để theo dõi các gói tin:
   ```sh
   tcpdump -i eth0
   ```

3. **Kiểm tra `conntrack`** để theo dõi các kết nối và NAT:
   ```sh
   conntrack -L
   ```

4. **Dùng `curl` hoặc `wget` để gửi yêu cầu đến máy chủ B và kiểm tra xem nó có được chuyển tiếp đúng hay không**:
   ```sh
   curl http://192.168.80.133
   ```

5. **Sử dụng công cụ `ping` hoặc `traceroute`** từ một máy ngoài mạng để kiểm tra đường đi của gói tin:
   ```sh
   ping 192.168.80.133
   traceroute 192.168.80.133
   ```

Với các bước trên, bạn sẽ có thể cấu hình và kiểm tra hoạt động của SNAT và DNAT trên hai máy chủ CentOS 7 với các địa chỉ IP được cung cấp.