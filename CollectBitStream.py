import os
import time
from pathlib import Path
import paramiko
from datetime import datetime

# === CẤU HÌNH KẾT NỐI PYNQ ===
PYNQ_IP = "192.168.2.99"
PYNQ_USER = "xilinx"
PYNQ_PASS = "xilinx"
PYNQ_BASE_DIR = "/home/xilinx"  # Các file bit và hwh sẽ được đẩy lên thư mục con trùng tên dự án, trong thư mục này
# =============================

def get_file_info(file_path):
    """Lấy thời điểm sửa đổi và khoảng thời gian so với hiện tại"""
    mtime = os.path.getmtime(file_path)
    mod_time = datetime.fromtimestamp(mtime)
    diff = datetime.now() - mod_time
    
    if diff.total_seconds() < 60:
        time_str = f"{int(diff.total_seconds())} giây trước"
    else:
        time_str = f"{int(diff.total_seconds() // 60)} phút trước"
        
    return mod_time.strftime("%Y-%m-%d %H:%M:%S"), time_str

def collect_and_upload():
    current_dir = Path.cwd()
    project_name = current_dir.name
    remote_project_dir = f"{PYNQ_BASE_DIR}/{project_name}"
    
    print(f"🚀 Dự án: {project_name}")
    print("-" * 45)

    # Đường dẫn file nguồn trong cấu trúc Vivado
    bit_src = current_dir / f"{project_name}.runs" / "impl_1" / "mainsystem_wrapper.bit"
    hwh_src = current_dir / f"{project_name}.gen" / "sources_1" / "bd" / "mainsystem" / "hw_handoff" / "mainsystem.hwh"

    # Kiểm tra file nguồn
    files_to_check = [("BIT", bit_src), ("HWH", hwh_src)]
    all_exists = True

    for label, path in files_to_check:
        if path.exists():
            m_date, diff = get_file_info(path)
            print(f"📝 {label} found: {m_date} ({diff})")
        else:
            print(f"❌ {label} NOT FOUND at: {path}")
            all_exists = False

    if not all_exists:
        print("\n⚠️ Dừng lại! Vui lòng kiểm tra lại quá trình Generate Bitstream.")
        input("\nBấm phím bất kì để kết thúc...")
        return

    try:
        print("-" * 45)
        print(f"📡 Đang kết nối tới PYNQ ({PYNQ_IP})...")
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(PYNQ_IP, username=PYNQ_USER, password=PYNQ_PASS)

        # Tạo thư mục dự án trên PYNQ
        ssh.exec_command(f"mkdir -p {remote_project_dir}")

        sftp = ssh.open_sftp()
        
        # Upload BIT
        print(f"📤 Uploading BIT... ", end="", flush=True)
        sftp.put(str(bit_src), f"{remote_project_dir}/{project_name}.bit")
        print("OK")

        # Upload HWH
        print(f"📤 Uploading HWH... ", end="", flush=True)
        sftp.put(str(hwh_src), f"{remote_project_dir}/{project_name}.hwh")
        print("OK")

        sftp.close()
        ssh.close()
        
        print("-" * 45)
        print(f"✅ THÀNH CÔNG! File đã nằm tại: {remote_project_dir}")
        print(f"💡 Trong Jupyter, bạn gọi: Overlay('{project_name}.bit')")

    except Exception as e:
        print(f"\n❌ LỖI TRUYỀN TẢI: {e}")

    print("-" * 45)
    input("Bấm phím bất kì để kết thúc...")

if __name__ == "__main__":
    collect_and_upload()