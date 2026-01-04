# Week 1: Linux Basics & Command Line Mastery

## 🎯 Learning Objectives
By the end of this week, you will:
- Navigate the Linux file system confidently
- Understand Linux permissions and user management
- Master essential command-line tools
- Perform basic system administration tasks

---

## Day 1-2: Linux Fundamentals & Navigation

### What is Linux?
Linux is an open-source operating system kernel that powers everything from smartphones to supercomputers. As a cloud engineer, Linux proficiency is essential because:
- **90%+ of cloud servers** run Linux
- **Container technologies** are built on Linux
- **Most cloud tools** are designed for Linux environments

### Linux Distributions Overview
```
Enterprise:     RHEL, CentOS, SUSE
Beginner:       Ubuntu, Linux Mint, Pop!_OS
Advanced:       Debian, Arch, Gentoo
Cloud-focused:  Amazon Linux, CoreOS
```

### Essential Navigation Commands

**File System Navigation:**
```bash
# Print working directory
pwd

# List directory contents
ls                    # Basic listing
ls -l                # Long format (detailed)
ls -la               # Include hidden files
ls -lh               # Human-readable file sizes

# Change directory
cd /home/user        # Absolute path
cd ../               # Parent directory
cd ~                 # Home directory
cd -                 # Previous directory

# Create directories
mkdir mydir          # Single directory
mkdir -p path/to/dir # Create parent directories
```

**File Operations:**
```bash
# Create files
touch file.txt       # Create empty file
echo "content" > file.txt  # Create with content

# Copy files/directories
cp file.txt backup.txt     # Copy file
cp -r dir1 dir2           # Copy directory recursively

# Move/rename files
mv oldname.txt newname.txt # Rename file
mv file.txt /path/to/     # Move file

# Remove files/directories
rm file.txt          # Remove file
rm -r directory      # Remove directory recursively
rm -rf directory     # Force remove (be careful!)
```

### 🧪 Hands-On Exercise: Day 1-2

**Exercise 1: File System Exploration**
```bash
# Navigate to root directory
cd /

# Explore important directories
ls -la
cd /etc && ls -la     # Configuration files
cd /var && ls -la     # Variable data
cd /usr && ls -la     # User programs
cd /home && ls -la    # User home directories

# Return to your home directory
cd ~
pwd
```

**Exercise 2: Create Directory Structure**
```bash
# Create a project structure
mkdir -p projects/web-app/{src,config,logs,docs}
mkdir -p projects/scripts/{bash,python,monitoring}

# Verify structure
tree projects/  # If tree is installed
# Or use: find projects/ -type d
```

**Exercise 3: File Manipulation Practice**
```bash
# Create sample files
echo "This is a web application" > projects/web-app/docs/README.md
echo "#!/bin/bash" > projects/scripts/bash/backup.sh
echo "server_name=web01" > projects/web-app/config/app.conf

# Practice copying and moving
cp projects/web-app/docs/README.md projects/web-app/docs/README.backup
mv projects/web-app/config/app.conf projects/web-app/config/application.conf

# List all files recursively
find projects/ -type f
```

---

## Day 3-4: File Permissions & User Management

### Understanding Linux Permissions

Linux uses a permission system based on three types of users:
- **Owner (u)** - The file creator
- **Group (g)** - Users in the same group
- **Others (o)** - Everyone else

**Permission Types:**
- **Read (r)** - View file contents or list directory
- **Write (w)** - Modify file or create/delete files in directory
- **Execute (x)** - Run file as program or enter directory

### Reading Permission Notation

**Symbolic Notation:**
```bash
ls -l file.txt
# -rwxr-xr-- 1 user group 1024 Dec 16 10:30 file.txt
#  ||||||||| 
#  ||||||++-- Others permissions (r--)
#  |||+++---- Group permissions (r-x)
#  +++------- Owner permissions (rwx)
#  +--------- File type (- = file, d = directory)
```

**Numeric Notation:**
```
Read (r)    = 4
Write (w)   = 2
Execute (x) = 1

Examples:
755 = rwxr-xr-x (Owner: rwx=7, Group: r-x=5, Others: r-x=5)
644 = rw-r--r-- (Owner: rw-=6, Group: r--=4, Others: r--=4)
600 = rw------- (Owner: rw-=6, Group: ---=0, Others: ---=0)
```

### Permission Management Commands

```bash
# Change file permissions
chmod 755 script.sh        # Numeric method
chmod u+x script.sh        # Add execute for owner
chmod g-w file.txt         # Remove write for group
chmod o=r file.txt         # Set others to read-only

# Change file ownership
chown user:group file.txt  # Change owner and group
chown user file.txt        # Change owner only
chgrp group file.txt       # Change group only

# Change permissions recursively
chmod -R 755 directory/
chown -R user:group directory/
```

### User and Group Management

```bash
# View current user information
whoami                     # Current username
id                        # User ID and group memberships
groups                    # Groups you belong to

# User management (requires sudo)
sudo useradd newuser      # Add new user
sudo usermod -aG group user # Add user to group
sudo passwd user          # Set user password
sudo userdel user         # Delete user

# Group management
sudo groupadd newgroup    # Create new group
sudo groupdel group       # Delete group
```

### 🧪 Hands-On Exercise: Day 3-4

**Exercise 1: Permission Practice**
```bash
# Create test files with different permissions
touch public.txt private.txt script.sh

# Set different permissions
chmod 644 public.txt      # Read/write for owner, read for others
chmod 600 private.txt     # Read/write for owner only
chmod 755 script.sh       # Executable script

# Verify permissions
ls -l public.txt private.txt script.sh

# Test permissions
echo "Public content" > public.txt
echo "Private content" > private.txt
echo "#!/bin/bash\necho 'Hello World'" > script.sh

# Try to execute script
./script.sh
```

**Exercise 2: Directory Permissions**
```bash
# Create directories with different permissions
mkdir public_dir private_dir shared_dir

# Set directory permissions
chmod 755 public_dir      # Standard directory permissions
chmod 700 private_dir     # Private directory
chmod 775 shared_dir      # Shared directory

# Test directory access
ls -ld public_dir private_dir shared_dir
cd public_dir && pwd && cd ..
cd private_dir && pwd && cd ..
```

**Exercise 3: Ownership Management**
```bash
# Create files as current user
touch myfile.txt
ls -l myfile.txt

# If you have sudo access, practice ownership changes
# (Skip if you don't have sudo)
sudo chown root:root myfile.txt
ls -l myfile.txt

# Change back to your user
sudo chown $USER:$USER myfile.txt
ls -l myfile.txt
```

---

## Day 5-7: Text Processing & Command Line Tools

### Essential Text Processing Commands

**Viewing File Contents:**
```bash
# Display entire file
cat file.txt           # Show all content
less file.txt          # Page through content (q to quit)
more file.txt          # Similar to less
head file.txt          # First 10 lines
head -n 20 file.txt    # First 20 lines
tail file.txt          # Last 10 lines
tail -f file.txt       # Follow file changes (useful for logs)
```

**Text Search and Filtering:**
```bash
# Search for patterns
grep "pattern" file.txt           # Find lines containing pattern
grep -i "pattern" file.txt        # Case-insensitive search
grep -r "pattern" directory/      # Recursive search
grep -n "pattern" file.txt        # Show line numbers
grep -v "pattern" file.txt        # Show lines NOT containing pattern

# Advanced pattern matching
grep "^start" file.txt            # Lines starting with "start"
grep "end$" file.txt              # Lines ending with "end"
grep -E "pattern1|pattern2" file.txt  # Multiple patterns
```

**Text Manipulation:**
```bash
# Sort and unique
sort file.txt                     # Sort lines alphabetically
sort -n numbers.txt               # Sort numerically
sort -r file.txt                  # Reverse sort
uniq file.txt                     # Remove duplicate lines
sort file.txt | uniq              # Sort then remove duplicates

# Cut and paste
cut -d',' -f1 data.csv           # Extract first column (comma-separated)
cut -c1-10 file.txt              # Extract characters 1-10
paste file1.txt file2.txt        # Combine files side by side

# Text replacement
sed 's/old/new/' file.txt        # Replace first occurrence per line
sed 's/old/new/g' file.txt       # Replace all occurrences
sed -i 's/old/new/g' file.txt    # Edit file in place
```

### Pipes and Redirection

**Understanding Pipes:**
Pipes (`|`) connect the output of one command to the input of another:

```bash
# Basic pipe examples
ls -l | grep "txt"               # List files, show only .txt files
cat /etc/passwd | grep "user"    # Show user accounts
ps aux | grep "firefox"          # Find Firefox processes
history | tail -10               # Show last 10 commands
```

**Redirection Operators:**
```bash
# Output redirection
command > file.txt               # Redirect stdout to file (overwrite)
command >> file.txt              # Redirect stdout to file (append)
command 2> error.log             # Redirect stderr to file
command &> all.log               # Redirect both stdout and stderr

# Input redirection
command < input.txt              # Use file as input
command << EOF                   # Here document
This is input
EOF
```

**Advanced Pipe Combinations:**
```bash
# Complex pipeline examples
cat /var/log/syslog | grep "error" | sort | uniq -c | sort -nr
# Explanation:
# 1. Show log file
# 2. Find lines with "error"
# 3. Sort the lines
# 4. Count unique occurrences
# 5. Sort by count (highest first)

# Process monitoring
ps aux | sort -k3 -nr | head -10
# Show top 10 processes by CPU usage

# Disk usage analysis
du -h /home | sort -hr | head -20
# Show largest directories in /home
```

### 🧪 Hands-On Exercise: Day 5-7

**Exercise 1: Log Analysis Practice**
```bash
# Create sample log file
cat > sample.log << EOF
2024-01-15 10:30:15 INFO User login successful: john
2024-01-15 10:31:22 ERROR Database connection failed
2024-01-15 10:32:10 INFO User login successful: mary
2024-01-15 10:33:45 WARNING High memory usage detected
2024-01-15 10:34:12 ERROR Database connection failed
2024-01-15 10:35:30 INFO User logout: john
2024-01-15 10:36:18 INFO User login successful: bob
2024-01-15 10:37:25 ERROR File not found: /tmp/data.txt
EOF

# Practice text processing
grep "ERROR" sample.log                    # Find all errors
grep -c "login successful" sample.log      # Count successful logins
grep "ERROR\|WARNING" sample.log           # Find errors and warnings
cut -d' ' -f4 sample.log | sort | uniq    # Extract and count log levels
```

**Exercise 2: System Information Gathering**
```bash
# Combine commands to gather system info
echo "=== System Information ===" > system_info.txt
uname -a >> system_info.txt
echo "" >> system_info.txt

echo "=== Disk Usage ===" >> system_info.txt
df -h >> system_info.txt
echo "" >> system_info.txt

echo "=== Memory Usage ===" >> system_info.txt
free -h >> system_info.txt
echo "" >> system_info.txt

echo "=== Top Processes ===" >> system_info.txt
ps aux | sort -k3 -nr | head -5 >> system_info.txt

# View the report
cat system_info.txt
```

**Exercise 3: Data Processing Pipeline**
```bash
# Create sample data
cat > users.csv << EOF
name,age,department,salary
John,25,IT,50000
Mary,30,HR,45000
Bob,35,IT,60000
Alice,28,Finance,55000
Charlie,32,IT,58000
EOF

# Process the data
echo "IT Department employees:"
grep "IT" users.csv | cut -d',' -f1,4

echo -e "\nAverage age calculation:"
tail -n +2 users.csv | cut -d',' -f2 | awk '{sum+=$1; count++} END {print "Average age:", sum/count}'

echo -e "\nDepartment summary:"
tail -n +2 users.csv | cut -d',' -f3 | sort | uniq -c
```

---

## 🎯 Week 1 Summary & Assessment

### Skills Mastered
- ✅ **File System Navigation** - Confidently move around Linux directories
- ✅ **File Operations** - Create, copy, move, and delete files/directories
- ✅ **Permission Management** - Understand and modify file permissions
- ✅ **User Management** - Basic user and group operations
- ✅ **Text Processing** - Search, filter, and manipulate text files
- ✅ **Command Pipelines** - Combine commands for complex operations

### Key Commands Reference
```bash
# Navigation
pwd, ls, cd, mkdir, rmdir

# File Operations
touch, cp, mv, rm, find, locate

# Permissions
chmod, chown, chgrp, umask

# Text Processing
cat, less, head, tail, grep, sort, uniq, cut, sed, awk

# System Info
whoami, id, groups, uname, df, free, ps, top
```

### Practice Challenges

**Challenge 1: System Cleanup Script**
Create a script that:
- Finds files older than 30 days in /tmp
- Lists files larger than 100MB in home directory
- Shows disk usage by directory

**Challenge 2: Log Monitoring**
Set up monitoring for:
- Failed login attempts
- Error messages in system logs
- High resource usage processes

**Challenge 3: User Management**
Practice:
- Creating users with specific permissions
- Setting up shared directories
- Managing group memberships

### Next Steps
You're ready for **Week 2: System Administration Essentials** where you'll learn:
- Process management and monitoring
- Package management systems
- Network configuration basics
- System services and automation

---

## 📚 Additional Resources

### Documentation
- [Linux Command Line Basics](https://ubuntu.com/tutorials/command-line-for-beginners)
- [File Permissions Guide](https://www.redhat.com/sysadmin/linux-file-permissions-explained)
- [Text Processing Tools](https://www.gnu.org/software/grep/manual/grep.html)

### Practice Environments
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) - Linux command line challenges
- [Linux Journey](https://linuxjourney.com/) - Interactive Linux learning
- [Vim Adventures](https://vim-adventures.com/) - Learn Vim through games

**Ready for Week 2?** Continue to [Week 2: System Administration Essentials](../week-02-system-admin/README.md)
