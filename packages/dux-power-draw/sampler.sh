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
pkg='' core='' range=0
for zone in /sys/class/powercap/intel-rapl:*; do
  if is "$zone/name" package-0; then
    pkg=$zone/energy_uj
    get range "$zone/max_energy_range_uj"
  fi
  if is "$zone/name" core; then core=$zone/energy_uj; fi
done

# the board ec's cpu rail, tctl
amps='' vcore='' tctl=''
for file in /sys/class/hwmon/hwmon*/curr*_label; do
  if is "$file" CPU; then amps=${file%_label}_input; fi
done
for file in /sys/class/hwmon/hwmon*/in*_label; do
  if is "$file" "CPU Core"; then vcore=${file%_label}_input; fi
done
for file in /sys/class/hwmon/hwmon*/temp*_label; do
  if is "$file" Tctl; then tctl=${file%_label}_input; fi
done

freqs=(/sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq)

model=''
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
printf '{"model":"%s","maxKhz":%s}\n' "${model//\"/}" "$maxKhz"

energy=null coreEnergy=null current=null voltage=null temp=null
while :; do
  get energy "$pkg"
  get coreEnergy "$core"
  get current "$amps"
  get voltage "$vcore"
  get temp "$tctl"

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
  busy='' total=''
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

  printf '{"t":%s,"pkg":%s,"core":%s,"range":%s,"amps":%s,"vcore":%s,"tctl":%s,"khz":%s,"busy":[%s],"total":[%s]}\n' \
    "$EPOCHREALTIME" "$energy" "$coreEnergy" "$range" "$current" "$voltage" "$temp" "$khz" "${busy#,}" "${total#,}"
  sleep 1
done
