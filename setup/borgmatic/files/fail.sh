#! /bin/bash
echo "Borgmatic failed to create a backup." | mail -s "Unsuccessful backup for $(hostname)" "$1"