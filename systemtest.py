from pynq import Overlay
import time

CLOCK_DIV_PERIOD = 1  
'''
Chu kì update của 1 lượt xử lý thông tin SNN. Đơn vị second.
Chu kì CPU đọc thông tin từ mạng SNN trong FPGA phải đúng bằng chu kì update trong bộ testbench
để tránh việc đọc khối FPGA quá nhanh/quá chậm, làm số liệu bị duplicate hoặc mất.
'''


# Load bitstream
BIT_FILE='SNN_SingleLIF.bit'
print(f"Nạp cấu hình FPGA {BIT_FILE}..")
ol = Overlay(BIT_FILE)

# Ánh xạ IP AXI GPIO (tên phải khớp với tên trong Block Design)
# Giả sử kênh 1 là Vmem, kênh 2 là SpikeOut
axi_gpio = ol.axi_gpio_0

print("--- Đang theo dõi Neuron LIF (Clock 1Hz) ---")
print("Hãy nhấn các nút trên board để tạo Spike đầu vào...")

try:
    while True:
        # Đọc giá trị từ AXI GPIO
        v_mem = axi_gpio.read(0x0)      # Channel 1 offset
        spike_out = axi_gpio.read(0x8)  # Channel 2 offset (thường cách 8 byte)
        
        # Hiển thị ra console
        status = "BẮN XUNG!" if spike_out == 1 else ""
        print(f"Vmem: {v_mem:5d} | Spike Out: {spike_out} {status}")
        
        # Đợi tới chu kì SNN cập nhật thông tin tiếp theo
        # Fix-bug: Phải đợi đúng bằng chu kì system-test (bộ clock-div-50M) để tránh việc đọc khối FPGA quá nhanh/quá chậm, làm số liệu bị duplicate hoặc mất.
        time.sleep(CLOCK_DIV_PERIOD)
except KeyboardInterrupt:
    print("Dừng mô phỏng.")