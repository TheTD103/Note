# Tài liệu hướng dẫn chuyển định dạng disk MBR -> GPT mà không mất dữ liệu

**Trước khi thực hiện**

![Ảnh 1](https://imgur.com/s5Dj1n0.jpg)

**Các bước thực hiện**

Trước khi bắt đầu, hãy đảm bảo bạn có bản sao lưu

1. Sử dụng gdisk để chuyển đổi bảng phân vùng sang GPT.

```sh
yum install gdisk -y
gdisk /dev/sda
```

![Ảnh 2](https://imgur.com/mWaf6SD.jpg)

2. Reload lại bảng phân vùng
```sh
partprobe /dev/sda
```
3. Cài đặt lại bộ tải khởi động GRUB bằng sơ đồ phân vùng mới.

```sh
yum install grub2 -y
/usr/sbin/grub2-install /dev/sda
```
4. Reboot

