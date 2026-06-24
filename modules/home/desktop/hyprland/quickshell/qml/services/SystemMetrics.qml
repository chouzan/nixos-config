pragma Singleton

import Quickshell
import Quickshell.Io

// Shared system metrics: one sampler feeding every monitor's SystemGauge.
// Views acquire a reference while visible; the poll runs only while at least
// one non-occluded gauge holds one, so it pauses when every bar is covered
// (mirrors the old per-gauge occlusion gate) but samples once, not per monitor.
Singleton {
    id: root

    property real cpuUsage: 0
    property real ramUsage: 0
    property real gpuUsage: 0

    property int ramTotalKB: 0
    property int ramAvailKB: 0
    property int gpuTempMilli: 0
    property real vramUsed: 0
    property real vramTotal: 0

    property int activeViews: 0

    function acquire() {
        root.activeViews += 1;
    }

    function release() {
        root.activeViews = Math.max(0, root.activeViews - 1);
    }

    Process {
        id: statProc
        command: [
            "bash",
            "-c",
            "gpu_path=''; gpu_temp_path=''; vram_used_path=''; vram_total_path=''; " + "for card in /sys/class/drm/card*/; do " + "  if [ \"$(cat \"$card/device/boot_vga\" 2>/dev/null)\" = 1 ] && " + "     [ -f \"$card/device/gpu_busy_percent\" ]; then " + "    gpu_path=\"$card/device/gpu_busy_percent\"; " + "    vram_used_path=\"$card/device/mem_info_vram_used\"; " + "    vram_total_path=\"$card/device/mem_info_vram_total\"; " + "    for h in \"$card/device/hwmon/\"hwmon*; do " + "      [ -f \"$h/temp1_input\" ] && gpu_temp_path=\"$h/temp1_input\"; " + "    done; " + "    break; " + "  fi; " + "done; " + "prev_total=0; prev_idle=0; " + "while true; do " + "  read _ user nice sys idle iow irq sirq steal _ _ < /proc/stat; " + "  total=$((user+nice+sys+idle+iow+irq+sirq+steal)); " + "  if [ $prev_total -gt 0 ]; then " + "    dt=$((total-prev_total)); di=$((idle-prev_idle)); " + "    cpu=$((100*(dt-di)/dt)); " + "  else cpu=0; fi; " + "  prev_total=$total; prev_idle=$idle; " + "  while IFS=': ' read -r key val _; do " + "    case $key in MemTotal) mt=$val;; MemAvailable) ma=$val;; esac; " + "  done < /proc/meminfo; " + "  gpu=0; " + "  [ -r \"$gpu_path\" ] && read gpu < \"$gpu_path\"; " + "  gpu_temp=0; " + "  [ -r \"$gpu_temp_path\" ] && read gpu_temp < \"$gpu_temp_path\"; " + "  vram_u=0; vram_t=0; " + "  [ -r \"$vram_used_path\" ] && read vram_u < \"$vram_used_path\"; " + "  [ -r \"$vram_total_path\" ] && read vram_t < \"$vram_total_path\"; " + "  echo \"$cpu $mt $ma $gpu $gpu_temp $vram_u $vram_t\"; " + "  sleep 2; " + "done"
        ]

        // Runs while any non-occluded gauge is active; killed when all are
        // occluded. On resume the process restarts fresh (one 0% CPU tick,
        // then real values).
        running: root.activeViews > 0

        stdout: SplitParser {
            onRead: (line) => {
                var parts = line.trim().split(" ");
                if (parts.length >= 7) {
                    root.cpuUsage = parseInt(parts[0]) / 100;
                    root.ramTotalKB = parseInt(parts[1]);
                    root.ramAvailKB = parseInt(parts[2]);
                    root.ramUsage = root.ramTotalKB > 0 ? (root.ramTotalKB - root.ramAvailKB) / root.ramTotalKB : 0;
                    root.gpuUsage = parseInt(parts[3]) / 100;
                    root.gpuTempMilli = parseInt(parts[4]);
                    root.vramUsed = parseFloat(parts[5]);
                    root.vramTotal = parseFloat(parts[6]);
                }
            }
        }
    }
}
