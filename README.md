# Python Fail2Ban Script

This script simulates a simplified version of Fail2Ban.

The program analyzes login logs and finds IP addresses that failed to log in multiple times.

How it works:

1. A list called `login_logs` contains login attempts.
2. The function `analyze_logs()` loops through the logs and counts failed login attempts for each IP address using a dictionary.
3. If an IP fails 3 or more times, it is added to the banned list.
4. The function `block_ip()` is called to simulate blocking that IP on three different firewalls using a while loop.
5. Finally, the script prints all banned IP addresses.

This demonstrates Python concepts such as:

* functions
* loops
* dictionaries
* condition checking
* list operations
