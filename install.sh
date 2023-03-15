#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "  lỗi：phải sử dụng quyền root để chạy tập lệnh này！\n" && exit 1

install_x-ui() {
    systemctl stop x-ui
    cd /usr/local/

    if  [ $# == 0 ] ;then
        last_version=$(curl -Ls "https://api.github.com/repos/vaxilu/x-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            echo -e "  Phát hiện x-ui Phiên bản không thành công，Có thể vượt ra ngoài Github API Hạn chế, vui lòng thử lại sau hoặc chỉ định thủ công x-ui Cài đặt phiên bản ${plain}"
            exit 1
        fi
        echo -e "  Đã phát hiện phiên bản mới nhất của x-ui：${last_version}，bắt đầu cài đặt"
        wget -N --no-check-certificate -O /usr/local/x-ui-linux-${arch}.tar.gz https://github.com/vaxilu/x-ui/releases/download/${last_version}/x-ui-linux-${arch}.tar.gz
        if [[ $? -ne 0 ]]; then
            echo -e "  Tải xuống x-ui không thành công, vui lòng đảm bảo máy chủ của bạn có thể tải xuống tệp Github${plain}"
            exit 1
        fi
    else
        last_version=$1
        url="https://github.com/vaxilu/x-ui/releases/download/${last_version}/x-ui-linux-${arch}.tar.gz"
        echo -e "  bắt đầu cài đặt x-ui v$1"
        wget -N --no-check-certificate -O /usr/local/x-ui-linux-${arch}.tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "  Tải xuống x-ui v$1 Không thành công, hãy đảm bảo rằng phiên bản này tồn tại${plain}"
            exit 1
        fi
    fi

    if [[ -e /usr/local/x-ui/ ]]; then
        rm /usr/local/x-ui/ -rf
    fi

    tar zxvf x-ui-linux-${arch}.tar.gz
    rm x-ui-linux-${arch}.tar.gz -f
    cd x-ui
    chmod +x x-ui bin/xray-linux-${arch}
    cp -f x-ui.service /etc/systemd/system/
    wget -O /usr/bin/x-ui -N --no-check-certificate https://raw.githubusercontent.com/DauDau432/VH_x-ui/main/x-ui.sh
    chmod +x /usr/bin/x-ui
    systemctl daemon-reload
    systemctl enable x-ui
    systemctl start x-ui
    # gọi IP server
    intenal_ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
    bash <(curl -Ls https://raw.githubusercontent.com/DauDau432/scan/main/vps)
    clear 
    echo ""
    echo -e "  ${green}x-ui v${last_version}${plain} Quá trình cài đặt hoàn tất và bảng điều khiển đã được bật"
    echo -e ""
    echo -e "  Hãy đảm bảo cổng ${green}54321${plain} không bị các chương trình khác chiếm Và Cổng ${green}54321${plain} đã được mở"
    echo -e "  Nếu bạn muốn đổi ${green}54321${plain} thành một cổng khác, hãy nhập lệnh ${green}x-ui${plain} để đổi và đảm bảo cổng đã đó cũng được mở"
    echo -e ""
    echo -e "  Vào trình duyệt truy cập  ${green}http://${intenal_ip}:54321${plain}  để vào bảng điều khiển"
    echo -e "  Tài khoản và mật khẩu mặc định là:  ${green}admin${plain}"
    echo -e ""
    echo -e "      Cách sử dụng tập lệnh quản lý: "
    echo -e "--------------${green}[Đậu Đậu việt hóa]${plain}--------------"     
    echo -e "  x-ui              - Menu quản lý x-ui (nhiều chức năng hơn)"
    echo -e "  x-ui start        - Khởi chạy bảng điều khiển x-ui"
    echo -e "  x-ui stop         - Dừng bảng điều khiển x-ui"
    echo -e "  x-ui restart      - Khởi động lại bảng điều khiển x-ui"
    echo -e "  x-ui status       - Xem trạng thái x-ui"
    echo -e "  x-ui enable       - Đặt tự động khởi động x-ui"
    echo -e "  x-ui disable      - Hủy tự động khởi động x-ui"
    echo -e "  x-ui log          - Xem nhật ký x-ui"
    echo -e "  x-ui v2-ui        - Di chuyển dữ liệu tài khoản v2-ui của máy này sang x-ui"
    echo -e "  x-ui update       - Cập nhật bảng điều khiển x-ui"
    echo -e "  x-ui install      - Cài đặt bảng điều khiển x-ui"
    echo -e "  x-ui uninstall    - Gỡ cài đặt bảng điều khiển x-ui"
    echo -e "----------------------------------------------"   
}

echo -e "  bắt đầu cài đặt${plain}"
install_base
install_x-ui $1
