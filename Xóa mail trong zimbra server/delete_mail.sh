#!/bin/bash

# ============================
# Script: delete_mail.sh
# Purpose: Xoá email spam
# Author: Thế Trần
# ============================

# Yêu cầu nhập email spam
read -p "📨 Nhập địa chỉ email spam cần xoá: " SPAM_SENDER
LIMIT=50

if [[ -z "$SPAM_SENDER" ]]; then
    echo "❌ Bạn chưa nhập địa chỉ email. Thoát script."
    exit 1
fi

# Lấy danh sách toàn bộ tài khoản Zimbra
users=$(zmprov -l gaa)

echo "=== Bắt đầu xoá spam từ: $SPAM_SENDER ==="
echo "Số thư tối đa mỗi user: $LIMIT"
echo "Thời gian bắt đầu: $(date)"
echo "=========================================="

# Duyệt từng tài khoản
for user in $users; do
    echo "📂 Kiểm tra hộp thư: $user"

    # Lấy danh sách ID các email từ địa chỉ spam
    message_ids=$(zmmailbox -z -m "$user" s -t message -l $LIMIT "from:$SPAM_SENDER" | awk '/^[0-9]+/ {print $2}')

    if [ -n "$message_ids" ]; then
        for id in $message_ids; do
            echo "🗑️ Đang xoá message ID $id từ $user"
            zmmailbox -z -m "$user" deleteMessage "$id"
        done
    else
        echo "✅ Không tìm thấy spam trong hộp thư $user"
    fi

    echo "-------------------------------"
done

echo "✅ Hoàn tất lúc: $(date)"
