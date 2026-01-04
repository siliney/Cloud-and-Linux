# Week 2: System Administration Essentials

## 🎯 Learning Objectives
By the end of this week, you will:
- Master process management and monitoring
- Understand package management systems
- Configure basic networking
- Manage system services and startup processes

---

## Day 1-2: Process Management & System Monitoring

### Understanding Processes

Every running program in Linux is a process. Processes have:
- **PID (Process ID)** - Unique identifier
- **PPID (Parent Process ID)** - Parent process that started it
- **State** - Running, sleeping, stopped, zombie
- **Priority** - CPU scheduling priority
- **Resources** - Memory, CPU usage

### Process Viewing Commands

```bash
# Basic process listing
ps                    # Show processes for current terminal
ps aux               # Show all processes (detailed)
ps -ef               # Show all processes (different format)

# Real-time process monitoring
top                  # Interactive process viewer
htop                 # Enhanced version (if installed)
atop                 # Advanced system monitor

# Process tree
pstree               # Show process hierarchy
ps --forest          # Tree view with ps
```

### Process Management

```bash
# Background and foreground jobs
command &            # Run command in background
jobs                 # List background jobs
fg %1                # Bring job 1 to foreground
bg %1                # Send job 1 to background
nohup command &      # Run command immune to hangups

# Process control
kill PID             # Terminate process (SIGTERM)
kill -9 PID          # Force kill process (SIGKILL)
killall firefox      # Kill all firefox processes
pkill -f "pattern"   # Kill processes matching pattern

# Process priority
nice -n 10 command   # Start with lower priority
renice 5 PID         # Change priority of running process
```

### System Resource Monitoring

```bash
# Memory usage
free -h              # Show memory usage (human readable)
cat /proc/meminfo    # Detailed memory information
vmstat 1 5           # Virtual memory statistics

# CPU information
lscpu                # CPU architecture info
cat /proc/cpuinfo    # Detailed CPU information
uptime               # System load averages

# Disk I/O
iostat               # I/O statistics
iotop                # Real-time I/O monitoring
lsof                 # List open files
```

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: Process Exploration**
```bash
# Start some background processes
sleep 300 &          # Long-running background process
sleep 600 &          # Another background process

# Monitor processes
jobs                 # See background jobs
ps aux | grep sleep  # Find sleep processes
pstree | grep sleep  # See in process tree

# Practice process control
kill %1              # Kill first background job
jobs                 # Verify it's gone
kill $(pgrep sleep)  # Kill remaining sleep processes
```

**Exercise 2: System Monitoring Script**
```bash
# Create system monitoring script
cat > system_monitor.sh << 'EOF'
#!/bin/bash

echo "=== System Monitor Report ==="
echo "Date: $(date)"
echo ""

echo "=== System Uptime ==="
uptime
echo ""

echo "=== Memory Usage ==="
free -h
echo ""

echo "=== Disk Usage ==="
df -h
echo ""

echo "=== Top 5 CPU Processes ==="
ps aux --sort=-%cpu | head -6
echo ""

echo "=== Top 5 Memory Processes ==="
ps aux --sort=-%mem | head -6
EOF

chmod +x system_monitor.sh
./system_monitor.sh
```

**Exercise 3: Process Monitoring Challenge**
```bash
# Start a CPU-intensive process
yes > /dev/null &
CPU_PID=$!

# Monitor its impact
top -p $CPU_PID       # Monitor specific process
# Press 'q' to quit top

# Check system load
uptime

# Kill the process
kill $CPU_PID
```

---

## Day 3-4: Package Management Systems

### Understanding Package Management

Package managers handle software installation, updates, and removal. Different distributions use different systems:

- **Debian/Ubuntu**: APT (Advanced Package Tool)
- **Red Hat/CentOS**: YUM/DNF (Yellowdog Updater Modified)
- **SUSE**: Zypper
- **Arch**: Pacman

### APT Package Management (Debian/Ubuntu)

```bash
# Update package database
sudo apt update              # Refresh package lists
sudo apt upgrade             # Upgrade installed packages
sudo apt full-upgrade        # Upgrade with dependency changes

# Package installation
sudo apt install package     # Install package
sudo apt install -y package # Install without confirmation
sudo apt reinstall package  # Reinstall package

# Package removal
sudo apt remove package      # Remove package (keep config)
sudo apt purge package       # Remove package and config
sudo apt autoremove          # Remove unused dependencies

# Package information
apt search keyword           # Search for packages
apt show package            # Show package details
apt list --installed        # List installed packages
apt list --upgradable       # List upgradable packages
```

### YUM/DNF Package Management (Red Hat/CentOS)

```bash
# Update system
sudo yum update              # Update all packages
sudo dnf update              # DNF version (newer systems)

# Package installation
sudo yum install package     # Install package
sudo yum groupinstall "Development Tools"  # Install package group

# Package removal
sudo yum remove package      # Remove package
sudo yum autoremove          # Remove unused dependencies

# Package information
yum search keyword           # Search packages
yum info package            # Package information
yum list installed          # List installed packages
```

### Software Sources and Repositories

```bash
# APT repositories (Ubuntu/Debian)
sudo add-apt-repository ppa:user/repo  # Add PPA
sudo apt-key add keyfile               # Add repository key
# Edit /etc/apt/sources.list for manual changes

# YUM repositories (CentOS/RHEL)
sudo yum-config-manager --add-repo URL
# Repository files in /etc/yum.repos.d/

# Install from downloaded packages
sudo dpkg -i package.deb     # Debian package
sudo rpm -i package.rpm      # RPM package
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: Package Management Practice**
```bash
# Update system (choose based on your distribution)
sudo apt update && sudo apt upgrade    # Debian/Ubuntu
# OR
sudo yum update                         # CentOS/RHEL

# Install useful tools
sudo apt install tree htop curl wget git  # Debian/Ubuntu
# OR
sudo yum install tree htop curl wget git  # CentOS/RHEL

# Verify installations
tree --version
htop --version
curl --version
```

**Exercise 2: Software Installation from Source**
```bash
# Install development tools first
sudo apt install build-essential       # Debian/Ubuntu
# OR
sudo yum groupinstall "Development Tools"  # CentOS/RHEL

# Download and compile a simple program (example: htop from source)
cd /tmp
wget https://github.com/htop-dev/htop/archive/refs/tags/3.2.2.tar.gz
tar -xzf 3.2.2.tar.gz
cd htop-3.2.2

# Configure, compile, and install
./configure
make
sudo make install

# Verify installation
which htop
htop --version
```

**Exercise 3: Repository Management**
```bash
# List current repositories
apt policy                   # Debian/Ubuntu
# OR
yum repolist                # CentOS/RHEL

# Search for packages
apt search "text editor"     # Debian/Ubuntu
# OR
yum search "text editor"    # CentOS/RHEL

# Get package information
apt show vim                # Debian/Ubuntu
# OR
yum info vim               # CentOS/RHEL
```

---

## Day 5-7: Network Configuration & Services

### Understanding Linux Networking

Linux networking involves several components:
- **Network interfaces** - Physical or virtual network connections
- **IP configuration** - Address assignment and routing
- **DNS resolution** - Domain name to IP translation
- **Firewall rules** - Traffic filtering and security

### Network Interface Management

```bash
# View network interfaces
ip addr show             # Modern command (preferred)
ifconfig                 # Traditional command
ip link show             # Show interface status

# Configure network interfaces
sudo ip addr add 192.168.1.100/24 dev eth0    # Add IP address
sudo ip link set eth0 up                       # Bring interface up
sudo ip link set eth0 down                     # Bring interface down

# Traditional method (still works)
sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0
sudo ifconfig eth0 up
```

### Routing and Connectivity

```bash
# View routing table
ip route show            # Modern command
route -n                 # Traditional command

# Add/remove routes
sudo ip route add 192.168.2.0/24 via 192.168.1.1    # Add route
sudo ip route del 192.168.2.0/24                     # Delete route

# Test connectivity
ping google.com          # Test internet connectivity
ping -c 4 192.168.1.1   # Ping with count limit
traceroute google.com    # Trace route to destination
mtr google.com           # Real-time traceroute
```

### DNS Configuration

```bash
# DNS configuration files
cat /etc/resolv.conf     # DNS servers
cat /etc/hosts           # Local hostname resolution
cat /etc/nsswitch.conf   # Name resolution order

# DNS testing
nslookup google.com      # DNS lookup
dig google.com           # Detailed DNS query
host google.com          # Simple DNS lookup
```

### Network Services and Ports

```bash
# View listening ports
netstat -tuln            # Traditional command
ss -tuln                 # Modern command (preferred)
lsof -i                  # List open network files

# View network connections
netstat -tupln           # Show processes using ports
ss -tupln                # Modern equivalent

# Test port connectivity
telnet hostname 80       # Test if port is open
nc -zv hostname 80       # Netcat port test
```

### Basic Firewall Management

```bash
# UFW (Ubuntu Firewall) - Debian/Ubuntu
sudo ufw status          # Check firewall status
sudo ufw enable          # Enable firewall
sudo ufw allow 22        # Allow SSH
sudo ufw allow 80/tcp    # Allow HTTP
sudo ufw deny 23         # Deny telnet
sudo ufw delete allow 80 # Remove rule

# Firewalld (CentOS/RHEL)
sudo firewall-cmd --state                    # Check status
sudo firewall-cmd --list-all                 # List all rules
sudo firewall-cmd --add-service=ssh          # Allow SSH
sudo firewall-cmd --add-port=8080/tcp        # Allow port 8080
sudo firewall-cmd --runtime-to-permanent     # Make changes permanent
```

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: Network Interface Exploration**
```bash
# Examine network configuration
ip addr show             # List all interfaces
ip route show            # Show routing table
cat /etc/resolv.conf     # Check DNS servers

# Test connectivity
ping -c 3 8.8.8.8       # Test internet (Google DNS)
ping -c 3 google.com     # Test DNS resolution
traceroute 8.8.8.8      # Trace route to Google DNS
```

**Exercise 2: Network Monitoring Script**
```bash
# Create network monitoring script
cat > network_check.sh << 'EOF'
#!/bin/bash

echo "=== Network Configuration Check ==="
echo "Date: $(date)"
echo ""

echo "=== Network Interfaces ==="
ip addr show | grep -E "^[0-9]+:|inet "
echo ""

echo "=== Default Gateway ==="
ip route | grep default
echo ""

echo "=== DNS Servers ==="
cat /etc/resolv.conf | grep nameserver
echo ""

echo "=== Connectivity Tests ==="
echo -n "Internet connectivity (8.8.8.8): "
if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "OK"
else
    echo "FAILED"
fi

echo -n "DNS resolution (google.com): "
if ping -c 1 -W 2 google.com >/dev/null 2>&1; then
    echo "OK"
else
    echo "FAILED"
fi

echo ""
echo "=== Listening Ports ==="
ss -tuln | head -10
EOF

chmod +x network_check.sh
./network_check.sh
```

**Exercise 3: Basic Firewall Configuration**
```bash
# Check current firewall status
sudo ufw status          # Ubuntu/Debian
# OR
sudo firewall-cmd --state  # CentOS/RHEL

# If UFW is available (Ubuntu/Debian)
if command -v ufw >/dev/null; then
    echo "Configuring UFW firewall..."
    sudo ufw --force reset     # Reset to defaults
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw --force enable
    sudo ufw status numbered
fi

# If firewalld is available (CentOS/RHEL)
if command -v firewall-cmd >/dev/null; then
    echo "Configuring firewalld..."
    sudo systemctl start firewalld
    sudo systemctl enable firewalld
    sudo firewall-cmd --list-all
fi
```

---

## 🎯 Week 2 Summary & Assessment

### Skills Mastered
- ✅ **Process Management** - Monitor, control, and troubleshoot processes
- ✅ **System Monitoring** - Track resource usage and performance
- ✅ **Package Management** - Install, update, and remove software
- ✅ **Network Configuration** - Basic networking and connectivity
- ✅ **Service Management** - Control system services and daemons
- ✅ **Security Basics** - Firewall configuration and access control

### Key Commands Reference
```bash
# Process Management
ps, top, htop, kill, killall, jobs, nohup

# System Monitoring
free, df, uptime, iostat, vmstat, lsof

# Package Management
apt/yum: install, remove, update, search, show

# Network Tools
ip, ping, traceroute, netstat, ss, dig, nslookup

# Firewall
ufw, firewall-cmd, iptables
```

### Practice Challenges

**Challenge 1: System Health Check Script**
Create a comprehensive script that:
- Checks system resources (CPU, memory, disk)
- Monitors critical processes
- Tests network connectivity
- Reports any issues found

**Challenge 2: Automated Package Management**
Set up:
- Automatic security updates
- Package installation from custom repositories
- Cleanup of unused packages

**Challenge 3: Network Troubleshooting**
Practice diagnosing:
- Connectivity issues
- DNS resolution problems
- Port accessibility
- Firewall blocking

### Next Steps
You're ready for **Week 3: Advanced Linux & Automation** where you'll learn:
- Shell scripting fundamentals
- Task automation with cron
- System service management
- Log analysis and troubleshooting

---

## 📚 Additional Resources

### Documentation
- [Linux System Administration Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/system_administrators_guide/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [Network Configuration Guide](https://www.redhat.com/sysadmin/network-interface-linux)

### Practice Labs
- [Linux Academy Labs](https://linuxacademy.com/)
- [KodeKloud Linux Basics](https://kodekloud.com/courses/linux-basics-course/)
- [OverTheWire Natas](https://overthewire.org/wargames/natas/) - Web security challenges

**Ready for Week 3?** Continue to [Week 3: Advanced Linux & Automation](../week-03-advanced-linux/README.md)
