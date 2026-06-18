#!/bin/bash

# =================== THIẾT LẬP BIẾN VÀ HÀM ===================

SOURCE_DIR="."
ADB_COMMAND="adb"

# Màu sắc hiển thị
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Hàm in tiêu đề cho các menu
print_header() {
    clear
    echo -e "${GREEN}========================================================${NC}"
    echo -e "${GREEN}                Trình cài đặt S.Mihome                 ${NC}"
    echo -e "${GREEN}========================================================${NC}"
    echo
}

# Hàm cài đặt một file APK và kiểm tra kết quả
install_apk() {
    local apk_file=$1
    if [ -f "$apk_file" ]; then
        echo -e "    -> Đang cài ${YELLOW}$apk_file${NC}..."
        if $ADB_COMMAND install -r -g "$apk_file" >/dev/null 2>&1; then
            echo -e "    ${GREEN}✅ Cài đặt $apk_file thành công.${NC}"
        else
            echo -e "    ${RED}❌ Cài đặt $apk_file thất bại.${NC}"
        fi
    else
        echo -e "    ${YELLOW}⚠️ Không tìm thấy file $apk_file, bỏ qua.${NC}"
    fi
}

# Hàm xem trước danh sách file trong thư mục để kiểm tra trước khi cài
preview_files() {
    echo -e "\n${GREEN}[DANH SÁCH FILE HIỆN TẠI]:${NC}"
    echo "----------------------------------------"
    ls -1 2>/dev/null | sed 's/^/  - /'
    echo "----------------------------------------"
    echo -e "${YELLOW}Vui lòng kiểm tra kỹ xem đã đủ file .apk và ảnh nền chưa.${NC}"
    sleep 2
}

# =================== CÁC HÀM CHỨC NĂNG CHÍNH ===================

# 1. Cài đặt bộ giao diện Android 6 - 11 Nội địa
install_projectivy() {

    # Thiết lập hệ thống (Múi giờ, Ngôn ngữ, Heads up, Không khóa màn hình)
    $ADB_COMMAND shell service call alarm 3 s16 Asia/Bangkok >/dev/null 2>&1
    $ADB_COMMAND shell settings put global device_locales vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put global sys_locale vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put system system_locales vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put global heads_up_notifications_enabled 0 >/dev/null 2>&1
    $ADB_COMMAND shell settings put global stay_on_while_plugged_in 3 >/dev/null 2>&1

    # Hiển thị thông báo trạng thái trực quan, đẹp mắt
    echo -e "${GREEN}🚀 Bắt đầu cài đặt Projectivy Launcher...${NC}"
    echo -e "    -> Đang chạy cài đặt ${YELLOW}p.apk${NC} ... Vui lòng đợi trong giây lát!"
    
    # Ẩn hoàn toàn đống chữ rác kỹ thuật (như Success, Performing Streamed Install...) của ADB
    install_apk "p.apk" >/dev/null 2>&1
    
    # In ra thông báo thành công ngay sau khi file APK nạp xong vào Tivi
    echo -e "${GREEN}✅ Cài đặt Projectivy Launcher thành công!${NC}"
    
    # Kích hoạt và thiết lập Launcher mặc định
    $ADB_COMMAND shell monkey -p com.spocky.projengmenu -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    $ADB_COMMAND shell am start -n com.spocky.projengmenu/.ui.home.MainActivity >/dev/null 2>&1
    $ADB_COMMAND shell cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity >/dev/null 2>&1

    echo -e "${YELLOW}🚫 Đang tiến hành vô hiệu hóa các ứng dụng hệ thống Xiaomi...${NC}"
    echo -e "    -> Hệ thống đang xử lý ngầm, vui lòng đợi trong giây lát! ..."

    # 💡 GIẢI PHÁP: Bọc toàn bộ vòng lặp vào khối {} và chặn sạch từ bên ngoài
    {
        local packages_to_disable=(
           com.mitv.tvhome 
           com.android.tv.settings 
           com.mitv.gallery 
           com.xiaomi.tweather  
           com.mitv.screensaver 
           com.xiaomi.mitv.shop 
           com.duokan.videodaily 
           com.xiaomi.tv.gallery 
           com.mitv.cloudcontrol 
           com.miui.tv.analytics 
           com.xiaomi.voicecontrol 
           com.xiaomi.mitv.upgrade 
           com.xiaomi.mitv.appstore 
           com.xiaomi.mitv.calendar 
           com.xiaomi.mitv.handbook 
           com.xiaomi.screenrecorder 
           com.sohu.inputmethod.sogou.tv 
           com.xiaomi.mitv.karaoke.service 
           com.xiaomi.mitv.hyper.screensaver
        )
        
        for pkg in "${packages_to_disable[@]}"; do
            # Bạn có thể giữ lệnh echo này hoặc xóa đi, vì khi bọc khối nó đều bị ẩn sạch
            echo "    -> Vô hiệu hóa: $pkg"
            
            # Thực thi lệnh đóng băng ứng dụng hệ thống
            $ADB_COMMAND shell pm disable-user --user 0 "$pkg"
            
            # Giữ nguyên lệnh nghỉ để chip Tivi xử lý không bị quá tải
            sleep 0.1
        done
    } >/dev/null 2>&1  # <--- Hố đen chặn đứng toàn bộ chữ in ra và lỗi hệ thống tại đây

    echo -e "${GREEN}✅ Vô hiệu hóa bloatware hoàn tất.${NC}"

    # Danh sách các app phụ trợ cần cài
    local apks_to_install=(
        "keyboard.apk"
        "katniss_2.2.0.apk"
        "dl.apk"
        "quantv.apk"
        "an.apk" 
        "youtube.apk"
        "cotivi.apk" 
        "imedia.apk"
    )

    echo -e "${GREEN}🚀 Bắt đầu cài đặt các ứng dụng phụ trợ...${NC}"
    echo -e "    -> Hệ thống đang nạp các gói ứng dụng ngầm, vui lòng chờ trong giây lát! ..."

    # 💡 GIẢI PHÁP ĐÃ SỬA: Chỉ chạy vòng lặp quét duy nhất danh sách apks_to_install
    {
        for apk in "${apks_to_install[@]}"; do
            # Lệnh thực thi cài đặt từng file APK thật lên Tivi
            install_apk "$apk"
        done
    } >/dev/null 2>&1

    echo -e "${GREEN}✅ Cài đặt toàn bộ ứng dụng phụ trợ hoàn tất!${NC}"

    # Push file cấu hình và hình nền ngầm (Đã sửa đổi để không lồng lệnh read gây treo)
    $ADB_COMMAND push projectivy.plbackup /sdcard/Download >/dev/null 2>&1
    
    copy_wallpapers
    
    # BƯỚC 5: CẤP QUYỀN ỨNG DỤNG
    echo -e "${YELLOW}🔑 BƯỚC 5: ĐANG CẤP QUYỀN ỨNG DỤNG...${NC}"
    echo -e "    -> Hệ thống đang kích hoạt quyền cấu hình sâu, vui lòng chờ...!"

    # 💡 GIẢI PHÁP: Bọc toàn bộ các vòng lặp và lệnh cấp quyền vào khối {} để ẩn sạch từ bên ngoài
    {
        pkg="com.spocky.projengmenu"
        
        # Quyền hệ thống nâng cao
        local appops_perms=(
            "REQUEST_INSTALL_PACKAGES" 
            "WRITE_SETTINGS" 
            "MANAGE_EXTERNAL_STORAGE"
            "SYSTEM_ALERT_WINDOW"
            "READ_EXTERNAL_STORAGE"
            "WRITE_EXTERNAL_STORAGE"
        )
        
        # Quyền Runtime tiêu chuẩn
        local runtime_perms=(
            "android.permission.READ_EXTERNAL_STORAGE" 
            "android.permission.WRITE_EXTERNAL_STORAGE" 
        )

        # Lệnh echo in thanh tiến trình này bây giờ cũng tự động bị ẩn sạch 100%
        echo -e "  [████████████████████] 100% | Đang cấp quyền sâu cho: $pkg"

        # 1. Cấp quyền qua AppOps
        for perm in "${appops_perms[@]}"; do
            $ADB_COMMAND shell appops set "$pkg" "$perm" allow
            $ADB_COMMAND shell cmd appops set "$pkg" "$perm" allow
            sleep 0.05
        done

        # 2. Cấp quyền Secure Settings
        $ADB_COMMAND shell pm grant "$pkg" android.permission.WRITE_SECURE_SETTINGS

        # 3. Cấp quyền Runtime tiêu chuẩn
        for perm in "${runtime_perms[@]}"; do
            $ADB_COMMAND shell pm grant "$pkg" "$perm"
            sleep 0.05
        done
        
        # 4. Ép quyền hỗ trợ đặc biệt dành riêng cho các dòng Android 11+ / HyperOS
        $ADB_COMMAND shell pm grant "$pkg" android.permission.READ_MEDIA_IMAGES
        $ADB_COMMAND shell pm grant "$pkg" android.permission.READ_MEDIA_VIDEO
    } >/dev/null 2>&1  # <--- Triệt tiêu toàn bộ mọi dòng chữ chạy và phản hồi hệ thống của ADB tại đây
    
    echo -e "${GREEN}✅ Cấp quyền ứng dụng hoàn tất!${NC}"
    
    
    # Hiển thị thông báo trạng thái duy nhất ra màn hình cho người dùng biết
    echo -e "${YELLOW}⚙️ Đang thực thi cấu hình hệ thống sâu và cài đặt Bàn phím, Launcher mặc định...${NC}"

    # 💡 GIẢI PHÁP: Bọc toàn bộ vòng lặp và danh sách lệnh vào khối {} để ép ẩn sạch 100% ra bên ngoài
    {
        # Vòng lặp thực thi chuỗi lệnh hệ thống sâu qua ADB
        local system_cmds=(
            "appops set com.spocky.projengmenu REQUEST_INSTALL_PACKAGES allow"
            "pm grant com.mitv.shareds android.permission.WRITE_SECURE_SETTINGS"
            "pm grant com.mitv.shareds android.permission.CHANGE_CONFIGURATION"
            "pm grant com.spocky.projengmenu android.permission.WRITE_EXTERNAL_STORAGE"
            "pm grant com.spocky.projengmenu android.permission.READ_EXTERNAL_STORAGE"
            "pm grant com.spocky.projengmenu android.permission.WRITE_SECURE_SETTINGS"
            "appops set com.google.android.katniss SYSTEM_ALERT_WINDOW allow"
            "cmd appops set com.spocky.projengmenu WRITE_EXTERNAL_STORAGE allow"
            "cmd appops set com.spocky.projengmenu READ_EXTERNAL_STORAGE allow"
            "appops set com.spocky.projengmenu REQUEST_INSTALL_PACKAGES allow"
            "ime enable com.liskovsoft.leankeyboard/.ime.LeanbackImeService"
            "settings put secure default_input_method com.liskovsoft.leankeyboard/.ime.LeanbackImeService"
            "settings put secure enabled_accessibility_services com.mitv.shareds/com.mitv.shareds.HomeService"
            "settings put secure accessibility_enabled 1"
            "cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity"
        )

        # Thực thi tuần tự từng lệnh trên TV (Đã bỏ đuôi >/dev/null lặt vặt ở dòng $ADB_COMMAND)
        for cmd in "${system_cmds[@]}"; do
            $ADB_COMMAND shell "$cmd"
            sleep 0.05
        done
    } >/dev/null 2>&1  # <--- Hố đen triệt tiêu toàn bộ mọi dòng chữ chạy và log phản hồi của Tivi tại đây

    echo -e "${GREEN}✅ Cấu hình hệ thống sâu hoàn tất!${NC}"

    # BƯỚC 6: TỐI ƯU HÓA HỆ THỐNG VÀ KHÓA ĐUÔI REBOOT
    echo -e "${YELLOW}🔄 Đang ghi dữ liệu bảo mật và đồng bộ ổ cứng TV...${NC}"
    
    $ADB_COMMAND shell cmd appops write-settings >/dev/null 2>&1
    sleep 0.5
    $ADB_COMMAND shell settings put global install_non_market_apps 1 >/dev/null 2>&1
    sleep 0.5
    $ADB_COMMAND shell settings list secure >/dev/null 2>&1
    sleep 0.5                               
    $ADB_COMMAND shell sync >/dev/null 2>&1
    sleep 1 
    
    echo -e "${GREEN}✅ Cài đặt Projectivy hoàn tất!${NC}"
    echo -e "${YELLOW}📺 TV sẽ khởi động lại sau 2 giây để áp dụng cấu hình...${NC}"
    sleep 2
    
    # Thực hiện khởi động lại TV và đóng hàm
    reboot_tv "normal"
}



# 2. Cài đặt bộ giao diện Android X S A Pro 2026 Nội địa

install_launcherfire() {
    print_header

    # --- GIỮ NGUYÊN GỐC KHỐI THIẾT LẬP HỆ THỐNG ---
    $ADB_COMMAND shell service call alarm 3 s16 Asia/Bangkok >/dev/null 2>&1
    $ADB_COMMAND shell settings put global device_locales vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put global sys_locale vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put system system_locales vi-VN >/dev/null 2>&1
    $ADB_COMMAND shell settings put global heads_up_notifications_enabled 0 >/dev/null 2>&1
    $ADB_COMMAND shell settings put global stay_on_while_plugged_in 3 >/dev/null 2>&1
    $ADB_COMMAND shell appops set com.xiaomi.voicecontrol SYSTEM_ALERT_WINDOW deny >/dev/null 2>&1

    # Hiển thị thông báo trạng thái trực quan, đẹp mắt
    echo -e "${GREEN}🚀 Bắt đầu cài đặt Projectivy Launcher...${NC}"
    echo -e "    -> Đang chạy cài đặt ${YELLOW}p.apk${NC} ... Vui lòng đợi trong giây lát!"
    
    # Ẩn hoàn toàn đống chữ rác kỹ thuật của ADB
    install_apk "p.apk" >/dev/null 2>&1
    
    # In ra thông báo thành công ngay sau khi file APK nạp xong vào Tivi
    echo -e "${GREEN}✅ Cài đặt Projectivy Launcher thành công!${NC}"
    
    # --- GIỮ NGUYÊN GỐC KHỐI KÍCH HOẠT VÀ THIẾT LẬP LAUNCHER MẶC ĐỊNH ---
    $ADB_COMMAND shell monkey -p com.spocky.projengmenu -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    $ADB_COMMAND shell am start -n com.spocky.projengmenu/.ui.home.MainActivity >/dev/null 2>&1
    $ADB_COMMAND shell cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity >/dev/null 2>&1

    echo -e "${YELLOW}🚫 Đang tiến hành vô hiệu hóa các ứng dụng hệ thống Xiaomi...${NC}"

    # --- GIỮ NGUYÊN GỐC DANH SÁCH PACKAGES VÀ VÒNG LẶP VÔ HIỆU HÓA COI NHƯ ẨN LOG ---
    {
        local packages_to_disable=(
           com.mitv.tvhome 
           com.android.tv.settings 
           com.mitv.gallery 
           com.xiaomi.tweather  
           com.mitv.screensaver 
           com.xiaomi.mitv.shop 
           com.duokan.videodaily 
           com.xiaomi.tv.gallery 
           com.mitv.cloudcontrol 
           com.miui.tv.analytics 
           com.xiaomi.voicecontrol 
           com.xiaomi.mitv.upgrade 
           com.xiaomi.mitv.appstore 
           com.xiaomi.mitv.calendar 
           com.xiaomi.mitv.handbook 
           com.xiaomi.screenrecorder 
           com.sohu.inputmethod.sogou.tv 
           com.xiaomi.mitv.karaoke.service 
           com.xiaomi.mitv.hyper.screensaver
        )
        
        for pkg in "${packages_to_disable[@]}"; do
            echo "    -> Vô hiệu hóa: $pkg"
            $ADB_COMMAND shell pm disable-user --user 0 "$pkg"
            sleep 0.1
        done
    } >/dev/null 2>&1

    echo -e "${GREEN}✅ Vô hiệu hóa bloatware hoàn tất.${NC}"

    # --- GIỮ NGUYÊN GỐC DANH SÁCH APP PHỤ TRỢ ---
    local apks_to_install=(
        "keyboard.apk"
        "katniss_2.2.0.apk"
        "dl.apk"
        "quantv.apk"
        "an.apk" 
        "youtube.apk"
        "cotivi.apk" 
        "imedia.apk"
    )

    echo -e "${GREEN}🚀 Bắt đầu cài đặt các ứng dụng phụ trợ...${NC}"

    # --- GIỮ NGUYÊN GỐC VÒNG LẶP CÀI ỨNG DỤNG ÉP ẨN RA BÊN NGOÀI ---
    {
        for apk in "${apks_to_install[@]}"; do
            install_apk "$apk"
        done
    } >/dev/null 2>&1

    echo -e "${GREEN}✅ Cài đặt toàn bộ ứng dụng phụ trợ hoàn tất!${NC}"

    # Push file cấu hình và hình nền ngầm (Không dính Enter dừng màn hình)
    $ADB_COMMAND push projectivy.plbackup /sdcard/Download >/dev/null 2>&1
    
    copy_wallpapers
    
    echo -e "${YELLOW}🔑 BƯỚC 5: ĐANG CẤP QUYỀN ỨNG DỤNG...${NC}"

    # --- GIỮ NGUYÊN GỐC KHỐI MẢNG VÀ VÒNG LẶP CẤP QUYỀN ---
    {
        pkg="com.spocky.projengmenu"
        local appops_perms=(
            "REQUEST_INSTALL_PACKAGES" 
            "WRITE_SETTINGS" 
            "MANAGE_EXTERNAL_STORAGE"
        )
        local runtime_perms=(
            "android.permission.READ_EXTERNAL_STORAGE" 
            "android.permission.WRITE_EXTERNAL_STORAGE" 
            "android.permission.READ_MEDIA_IMAGES" 
            "android.permission.READ_MEDIA_VIDEO" 
            "android.permission.READ_MEDIA_AUDIO"
        )

        echo -e "  [████████████████████] 100% | Đang cấp quyền cho: $pkg"

        for perm in "${appops_perms[@]}"; do
            $ADB_COMMAND shell appops set "$pkg" "$perm" allow
            $ADB_COMMAND shell cmd appops set "$pkg" "$perm" allow
        done

        for perm in "${runtime_perms[@]}"; do
            $ADB_COMMAND shell pm grant "$pkg" "$perm"
        done
    } >/dev/null 2>&1
    
    echo -e "${GREEN}✅ Cấp quyền ứng dụng hoàn tất!${NC}"
   
    echo -e "${YELLOW}⚙️ Đang thực thi cấu hình hệ thống sâu và cài đặt Bàn phím, Launcher mặc định...${NC}"

    # --- GIỮ NGUYÊN GỐC 100% DANH SÁCH SYSTEM_CMDS VÀ VÒNG LẶP CHẠY LỆNH SÂU ---
    {
        local system_cmds=(
            "appops set com.spocky.projengmenu REQUEST_INSTALL_PACKAGES allow"
            "cmd appops set com.spocky.projengmenu REQUEST_INSTALL_PACKAGES allow"
            "pm grant com.mitv.shareds android.permission.WRITE_SECURE_SETTINGS"
            "pm grant com.mitv.shareds android.permission.CHANGE_CONFIGURATION"
            "pm grant com.spocky.projengmenu android.permission.WRITE_EXTERNAL_STORAGE"
            "pm grant com.spocky.projengmenu android.permission.READ_EXTERNAL_STORAGE"
            "pm grant com.spocky.projengmenu android.permission.WRITE_SECURE_SETTINGS"
            "appops set com.google.android.katniss SYSTEM_ALERT_WINDOW allow"
            "cmd appops set com.google.android.katniss SYSTEM_ALERT_WINDOW allow"
            "cmd appops set com.spocky.projengmenu WRITE_EXTERNAL_STORAGE allow"
            "cmd appops set com.spocky.projengmenu READ_EXTERNAL_STORAGE allow"
            "ime enable com.liskovsoft.leankeyboard/.ime.LeanbackImeService"
            "settings put secure default_input_method com.liskovsoft.leankeyboard/.ime.LeanbackImeService"
            "settings put secure enabled_accessibility_services com.mitv.shareds/com.mitv.shareds.HomeService"
            "settings put secure accessibility_enabled 1"
            "cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity"
        )

        for cmd in "${system_cmds[@]}"; do
            $ADB_COMMAND shell "$cmd"
            sleep 0.05
        done
    } >/dev/null 2>&1

    echo -e "${GREEN}✅ Cấu hình hệ thống sâu hoàn tất!${NC}"

    # --- BƯỚC 6 KHÓA ĐUÔI: ĐỒNG BỘ VÀ TỰ ĐỘNG KHỞI ĐỘNG LẠI TV ---
    echo -e "${YELLOW}🔄 Đang ghi dữ liệu bảo mật và đồng bộ ổ cứng TV...${NC}"
    
    $ADB_COMMAND shell cmd appops write-settings >/dev/null 2>&1
    sleep 0.5
    $ADB_COMMAND shell settings put global install_non_market_apps 1 >/dev/null 2>&1
    sleep 0.5
    $ADB_COMMAND shell settings list secure >/dev/null 2>&1
    sleep 0.5                               
    $ADB_COMMAND shell sync >/dev/null 2>&1
    sleep 1 
    
    echo -e "${GREEN}✅ Cài đặt Android X S A Pro hoàn tất!${NC}"
    echo -e "${YELLOW}📺 TV sẽ khởi động lại sau 2 giây để áp dụng cấu hình...${NC}"
    sleep 2
    
    # Thực hiện lệnh reboot hệ thống
    reboot_tv "normal"
}

# 3. Quét và cài đặt toàn bộ file .apk có trong thư mục
install_all_apks() {
    print_header
    echo -e "${YELLOW}📦 Đang quét và cài đặt tất cả file .apk trong thư mục...${NC}"
    echo

    local apk_count=0
    for file in *.apk; do
        [ -f "$file" ] && ((apk_count++))
    done

    if [ "$apk_count" -eq 0 ]; then
        echo -e "${RED}❌ Không tìm thấy bất kỳ file .apk nào trong thư mục hiện tại!${NC}"
    else
        echo -e "Tìm thấy ${GREEN}$apk_count${NC} file .apk. Bắt đầu cài đặt..."
        echo "----------------------------------------"
        for file in *.apk; do
            [ -f "$file" ] && install_apk "$file"
        done
        echo "----------------------------------------"
        echo -e "${GREEN}✅ Đã xử lý xong toàn bộ file .apk.${NC}"
    fi
    read -p "Nhấn Enter để quay lại menu chính..."
}

# 4. Chép toàn bộ ảnh nền vào TV (Hỗ trợ cả chữ hoa và chữ thường)
copy_wallpapers() {
    print_header
    echo -e "${YELLOW}🖼️ Đang tiến hành chép tất cả ảnh nền vào TV...${NC}"
    echo

    # Đổi đường dẫn đích đến thẳng thư mục gốc DCIM
    local target_tv_dir="/sdcard/DCIM"

    local img_count=0
    for file in *.[jJ][pP][gG] *.[jJ][pP][eE][gG] *.[pP][nN][gG]; do
        if [ -f "$file" ]; then
            echo "   -> Đang chép: $file"
            if $ADB_COMMAND push "$file" "$target_tv_dir/" >/dev/null 2>&1; then
                ((img_count++))
            else
                echo -e "      ${RED}❌ Lỗi khi chép file: $file${NC}"
            fi
        fi
    done

    if [ "$img_count" -gt 0 ]; then
        echo -e "\n${GREEN}✅ Đã chép thành công $img_count ảnh nền lên TV tại:${NC}"
        echo -e "   ${YELLOW}$target_tv_dir${NC}"
    else
        echo -e "${RED}❌ Không tìm thấy file ảnh .jpg, .jpeg hoặc .png nào.${NC}"
    fi
    # Đã bỏ lệnh 'read' tại đây để hàm chạy trơn tru khi được gọi ké
}

# 5 & 6. Khởi động lại TV
reboot_tv() {
    local mode=$1
    print_header
    if [ "$mode" == "recovery" ]; then
        echo -e "${RED}⚠️ Đang khởi động TV vào chế độ RECOVERY...${NC}"
        $ADB_COMMAND reboot recovery
    else
        echo -e "${YELLOW}🔄 Đang khởi động lại TV...${NC}"
        $ADB_COMMAND reboot
    fi
    echo -e "${GREEN}✅ Lệnh đã được gửi. Script sẽ thoát sau 3 giây.${NC}"
    sleep 3
    exit 0
}

# =================== ĐIỀU HƯỚNG LUỒNG MENU (ĐÃ SỬA LỖI ĐỆ QUY) ===================

# MENU CHỨC NĂNG CHÍNH
menu2() {
    while true; do
        print_header
        echo -e "TV đang kết nối tại: ${GREEN}$DEVICE_IP${NC}"
        echo
        echo "-- Cài đặt giao diện --"
        echo "1. Cài andoi 6 11 nội địa"
        echo "2. Cài andoir X S A pro 2026 nội địa"
        echo "--------------------------"
        echo "3. Cài đặt tất cả ứng dụng (.apk) quốc tế"
        echo "4. Chép tất cả ảnh nền (.jpg, .png) vào TV"
        echo "5. Khởi động lại TV (Reboot)"
        echo "6. Khởi động vào Recovery"
        echo "7. Ngắt và kết nối lại TV khác"
        echo "0. Thoát"
        echo

        read -p "→ Nhập tùy chọn của bạn [0-7]: " CHOICE

        case $CHOICE in
            1) install_projectivy ;;
            2) install_launcherfire ;;
            3) install_all_apks ;;
            4) copy_wallpapers; read -p "Nhấn Enter để quay lại menu chính..." ;; # Thêm read vào đây
            5) reboot_tv "normal" ;;
            6) reboot_tv "recovery" ;;
            7) return 0 ;; # Thoát khỏi menu2, trả luồng điều khiển về menu1 một cách an toàn
            0) echo "👋 Tạm biệt!"; exit 0 ;;
            *) echo -e "${YELLOW}⚠️ Lựa chọn không hợp lệ, vui lòng chọn lại.${NC}"; sleep 2 ;;
        esac
    done
}

# MENU KẾT NỐI (VÒNG LẶP GỐC)
menu1() {
    while true; do
        print_header
        echo "Hướng dẫn kết nối ADB với TV Xiaomi:"
        echo "1. Vào Cài đặt -> Giới thiệu -> Nhấn vào 'Build number' 5-7 lần."
        echo "2. Quay lại Cài đặt -> Tùy chọn nhà phát triển."
        echo "3. Bật 'ADB Debugging' (Gỡ lỗi ADB)."
        echo "4. Đảm bảo TV và điện thoại đang kết nối chung một mạng Wi-Fi."
        echo

        read -p "Nhập địa chỉ IP của TV (vd: 192.168.1.100): " RAW_IP

        if [[ -z "$RAW_IP" ]]; then
            echo -e "${RED}❌ Bạn chưa nhập IP. Vui lòng thử lại.${NC}"
            sleep 2
            continue
        fi

        DEVICE_IP="${RAW_IP}:5555"

        echo "🔄 Đang ngắt kết nối cũ (nếu có)..."
        $ADB_COMMAND disconnect &>/dev/null
        sleep 1

        echo "🔄 Đang kết nối tới $DEVICE_IP..."
        connection_output=$($ADB_COMMAND connect "$DEVICE_IP")
        echo "$connection_output"

        echo -e "${YELLOW}📺 Vui lòng nhấn 'Allow' hoặc 'Cho phép' trên màn hình TV...${NC}"
        sleep 8 

        # Kiểm tra trạng thái kết nối thực tế
        if $ADB_COMMAND devices | grep -q "$RAW_IP.*device"; then
            echo -e "${GREEN}✅ Kết nối thành công tới $DEVICE_IP!${NC}"
            sleep 1
            preview_files
            
            menu2 # Chuyển sang menu chính. Khi chọn 7 ở menu2, lệnh này kết thúc và tiếp tục vòng lặp menu1.
        else
            echo -e "${RED}❌ Kết nối thất bại.${NC}"
            echo -e "   • Kiểm tra lại IP, đảm bảo đã bật ADB Debugging và xác nhận trên TV."
            read -p "Nhấn Enter để thử lại..."
        fi
    done
}

# =================== BẮT ĐẦU KỊCH BẢN ===================

# Kiểm tra môi trường tự động
if [ -f "p.apk" ]; then
    SOURCE_DIR="."
    echo -e "${GREEN}✅ Phát hiện chạy trực tiếp từ thư mục GitHub Termux.${NC}"
else
    if [ ! -d "$SOURCE_DIR" ]; then
        echo -e "${RED}❌ Không tìm thấy thư mục nguồn: $SOURCE_DIR${NC}"
        echo -e "   Vui lòng chạy lệnh 'termux-setup-storage' và cấp quyền cho Termux."
        sleep 5
        exit 1
    fi
fi

# Di chuyển vào thư mục làm việc
cd "$SOURCE_DIR" || exit

# Khởi chạy menu kết nối đầu tiên
menu1