# Mac Battery Drain Fix - Recommendations

## 🔧 Recommended Solution

### Apply Battery Power Settings

```bash
# Disable Power Nap on battery
sudo pmset -b powernap 0

# Disable Wake on Network on battery
sudo pmset -b womp 0

# Ensure Network over Sleep is disabled on battery
sudo pmset -b networkoversleep 0

# Keep TCP Keep Alive enabled (required for Find My Mac)
sudo pmset -b tcpkeepalive 1
```

### Recommended Configuration

#### Battery Power Settings (When Unplugged)

```
Battery Power:
 powernap             0        ✅ DISABLED (prevents constant wakes)
 womp                 0        ✅ DISABLED (prevents WiFi/BT wakes)
 networkoversleep     0        ✅ DISABLED
 tcpkeepalive         1        ⚠️  ENABLED (required for Find My Mac)
```

#### AC Power Settings (When Plugged In)

```
AC Power:
 powernap             1        ✅ ENABLED (background tasks when plugged in)
 womp                 1        ✅ ENABLED (wake on network when plugged in)
 networkoversleep     0
 tcpkeepalive         1
```

---

## 🔍 Verification & Monitoring

### Check Current Settings

```bash
# View all power settings
sudo pmset -g custom

# View currently active settings
pmset -g

# Check battery status
pmset -g batt

# Check what's preventing sleep (run when system is awake)
pmset -g assertions
```

### Monitor Sleep/Wake Events

```bash
# View recent sleep/wake log (last 100 events)
pmset -g log | grep -E "(Sleep|Wake|DarkWake)" | tail -100

# Count DarkWake events today
pmset -g log | grep "$(date +%Y-%m-%d)" | grep "DarkWake" | wc -l

# Check wake reasons for specific date (replace YYYY-MM-DD with your date)
pmset -g log | grep "YYYY-MM-DD" | grep "DarkWake" | head -20

# View what's requesting wakes
pmset -g log | grep "Wake Requests" | tail -10
```

### Check Battery Drain

```bash
# View battery charge levels over time
pmset -g log | grep "Charge:" | tail -20

# Check for specific time period (replace YYYY-MM-DD with your date)
pmset -g log | grep "YYYY-MM-DD 1[0-4]:" | grep "Charge:"
```

---

## 📝 Testing Instructions

### Overnight Test

1. Note battery percentage before sleep
2. Put Mac to sleep by closing lid
3. Leave unplugged overnight
4. Check battery percentage in the morning
5. Review wake events:

   ```bash
   pmset -g log | grep "$(date +%Y-%m-%d)" | grep "DarkWake" | wc -l
   ```

### Success Criteria

- ✅ Battery drain < 15% overnight (8 hours)
- ✅ DarkWake events < 30 per hour
- ✅ Find My Mac still functional

---

## 🛠️ Additional Troubleshooting

### If Battery Drain Still High

#### Option 1: Temporarily Disable TCP Keep Alive

```bash
# WARNING: This disables Find My Mac
sudo pmset -b tcpkeepalive 0
```

#### Option 2: Check for Other Wake Sources

```bash
# Check what's preventing sleep
pmset -g assertions

# Look for specific processes
pmset -g log | grep "Wake Requests" | tail -20
```

#### Option 3: Increase Standby Delay

```bash
# Wait 24 hours before deep sleep (hibernate to disk)
sudo pmset -b standbydelay 86400
```

### Restore Default Settings

```bash
# Reset to defaults for battery
sudo pmset -b powernap 1 womp 1 tcpkeepalive 1

# Or reset everything to defaults
sudo pmset -a restoredefaults
```

---

## 📚 Power Management Settings Reference

### Key Settings Explained

| Setting            | Description                                                                 | Values                   |
| ------------------ | --------------------------------------------------------------------------- | ------------------------ |
| `powernap`         | Allow system to wake for background tasks (Time Machine, iCloud sync, etc.) | 0=off, 1=on              |
| `tcpkeepalive`     | Maintain network connections during sleep (Find My Mac)                     | 0=off, 1=on              |
| `womp`             | Wake on Magic Packet / Wake for network access                              | 0=off, 1=on              |
| `networkoversleep` | Network access during sleep                                                 | 0=off, 1=on              |
| `standby`          | Enable standby mode (hibernate after delay)                                 | 0=off, 1=on              |
| `standbydelay`     | Seconds before entering standby                                             | Default: 10800 (3 hours) |
| `hibernatemode`    | Sleep mode: 0=RAM only, 3=RAM+disk, 25=disk only                            | 3=hybrid (recommended)   |
| `displaysleep`     | Minutes until display sleeps                                                | Number of minutes        |
| `sleep`            | Minutes until system sleeps                                                 | Number of minutes        |

### Power Management Modes

**-a** : Apply to all power sources (AC + Battery)  
**-b** : Apply to battery power only  
**-c** : Apply to AC power only  
**-u** : Apply to UPS power only

---

## 🔗 Useful Resources

### Apple Documentation

- [Power Management in macOS](https://developer.apple.com/library/archive/documentation/Darwin/Reference/ManPages/man1/pmset.1.html)
- [Understanding Power Nap](https://support.apple.com/en-us/HT204032)

### Quick Reference Commands

```bash
# Quick battery health check
pmset -g batt

# Full power settings
sudo pmset -g custom

# Recent wake events
pmset -g log | grep DarkWake | tail -50

# What's preventing sleep now
pmset -g assertions

# Wake requests scheduled
pmset -g log | grep "Wake Requests" | tail -10
```

---

## ✅ Checklist

- [ ] Apply battery-specific power settings
- [ ] Verify settings with `sudo pmset -g custom`
- [ ] Test overnight battery drain
- [ ] Monitor wake events
- [ ] Verify Find My Mac still works
