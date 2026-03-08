# sample-data
login_logs = [
    {"ip": "192.168.1.15", "user": "admin", "status": "failed"},
    {"ip": "10.0.0.45", "user": "root", "status": "success"},
    {"ip": "192.168.1.15", "user": "root", "status": "failed"},
    {"ip": "172.16.0.5", "user": "ubuntu", "status": "success"},
    {"ip": "192.168.1.15", "user": "admin", "status": "failed"},
    {"ip": "10.0.0.45", "user": "admin", "status": "failed"},
    {"ip": "203.0.113.8", "user": "root", "status": "failed"},
    {"ip": "203.0.113.8", "user": "root", "status": "failed"},
    {"ip": "203.0.113.8", "user": "admin", "status": "failed"},
    {"ip": "10.0.0.45", "user": "root", "status": "success"}
]

# function that print blocking IP address on firewalls
def block_ip(ip_address):
    firewall = 1

    # print IP address on firewall until number will be 3
    while firewall <= 3:
        print(f"Blocking {ip_address} on Firewall {firewall}")
        firewall += 1

# functon that analyzes login logs
def analyze_logs(logs):
    failed_counts = {}

    # loop for each log item
    for x in logs:

        # check if status is failed 
        if x['status'] == "failed":
            ip = x['ip']
            # check if ip exists in dictionary and increas it
            if ip in failed_counts:
                failed_counts[ip] += 1
            else:
                failed_counts[ip] = 1
    banned_ips = []

    # for loop that check if value is equal or more 3 and adds in new list
    for key, value in failed_counts.items():
        if value >= 3:
            banned_ips.append(key)
            block_ip(key) 
    return banned_ips    

# call main function    
analyze_logs(login_logs)