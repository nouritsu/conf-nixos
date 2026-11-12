shopt -s nullglob

# EPOCHREALTIME follows the locale's decimal point
export LC_ALL=C

# a sysfs value into the named variable, or null when it's missing or unreadable
get() {
  local value
  if [ -n "$2" ] && read -r value 2> /dev/null < "$2"; then
    printf -v "$1" %s "$value"
  else
    printf -v "$1" null
  fi
}

# whether a label file reads $2
is() {
  local value
  read -r value 2> /dev/null < "$1" && [ "$value" = "$2" ]
}

# rapl zones; root-only unless udev opened them up
declare -A zone=([pkg]="" [core]="" [uncore]="" [psys]="")
declare -A range=([pkg]=null [core]=null [uncore]=null [psys]=null)
for dir in /sys/class/powercap/intel-rapl:*; do
  for key in pkg core uncore psys; do
    name=$key
    if [ "$key" = pkg ]; then name=package-0; fi
    if is "$dir/name" "$name"; then
      zone[$key]=$dir/energy_uj
      get "range[$key]" "$dir/max_energy_range_uj"
    fi
  done
done

# the board ec's cpu rail
amps="" vcore=""
for file in /sys/class/hwmon/hwmon*/curr*_label; do
  if is "$file" CPU; then amps=${file%_label}_input; fi
done
for file in /sys/class/hwmon/hwmon*/in*_label; do
  if is "$file" "CPU Core"; then vcore=${file%_label}_input; fi
done

# amd's tctl or intel's package temperature
temp="" tcrit=null
for file in /sys/class/hwmon/hwmon*/temp*_label; do
  if is "$file" Tctl || is "$file" "Package id 0"; then
    temp=${file%_label}_input
    get tcrit "${file%_label}_crit"
  fi
done

freqs=(/sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq)

# an intel igpu's clock and name
igpu="" igpuMax=null igpuName=""
for file in /sys/class/drm/card*/gt_act_freq_mhz; do
  igpu=$file
  get igpuMax "${file%/*}/gt_RP0_freq_mhz"
  slot=$(basename "$(readlink -f "${file%/*}/device")")
  while IFS=$'\t' read -r key value; do
    if [ "$key" = Device: ]; then
      igpuName=$value
      break
    fi
  done < <(lspci -vmm -s "$slot")
done

volts=""
for dir in /sys/class/power_supply/*; do
  if is "$dir/type" Battery; then volts=$dir/voltage_now; fi
done

conservation=""
if [ -e /sys/bus/platform/devices/VPC2004:00/conservation_mode ]; then
  conservation=/sys/bus/platform/devices/VPC2004:00/conservation_mode
fi

model=""
while IFS= read -r line; do
  case $line in
    "model name"*)
      model=${line#*: }
      break
      ;;
  esac
done < /proc/cpuinfo
maxKhz=null
get maxKhz /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
printf '{"model":"%s","maxKhz":%s,"ranges":{"pkg":%s,"core":%s,"uncore":%s,"psys":%s},"tcrit":%s,"igpuName":"%s","igpuMax":%s}\n' \
  "${model//\"/}" "$maxKhz" "${range[pkg]}" "${range[core]}" "${range[uncore]}" "${range[psys]}" "$tcrit" "${igpuName//\"/}" "$igpuMax"

pkg=null core=null uncore=null psys=null current=null voltage=null cpuTemp=null igpuMhz=null battery=null conserving=null
while :; do
  get pkg "${zone[pkg]}"
  get core "${zone[core]}"
  get uncore "${zone[uncore]}"
  get psys "${zone[psys]}"
  get current "$amps"
  get voltage "$vcore"
  get cpuTemp "$temp"
  get igpuMhz "$igpu"
  get battery "$volts"
  get conserving "$conservation"

  sum=0 count=0
  for file in "${freqs[@]}"; do
    if read -r khz 2> /dev/null < "$file"; then
      sum=$((sum + khz))
      count=$((count + 1))
    fi
  done
  khz=null
  if [ "$count" -gt 0 ]; then khz=$((sum / count)); fi

  # cpu time: the aggregate first, then each thread
  busy="" total=""
  while read -r name user nice system idle iowait irq softirq steal _; do
    case $name in
      cpu*)
        used=$((user + nice + system + irq + softirq + steal))
        busy+=,$used
        total+=,$((used + idle + iowait))
        ;;
      *) break ;;
    esac
  done < /proc/stat

  printf '{"t":%s,"pkg":%s,"core":%s,"uncore":%s,"psys":%s,"amps":%s,"vcore":%s,"temp":%s,"khz":%s,"igpuMhz":%s,"volts":%s,"conservation":%s,"busy":[%s],"total":[%s]}\n' \
    "$EPOCHREALTIME" "$pkg" "$core" "$uncore" "$psys" "$current" "$voltage" "$cpuTemp" "$khz" "$igpuMhz" "$battery" "$conserving" "${busy#,}" "${total#,}"
  sleep 1
done
