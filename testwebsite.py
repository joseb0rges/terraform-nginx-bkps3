import httplib
import sys

url_website = sys.argv[1]
conn = httplib.HTTPConnection(url_website)
conn.request("HEAD", "/")
r1 = conn.getresponse()
if r1.status == 200:
    print("STATUS SITE: ",r1.status, r1.reason)
else: 
    print("ERROR: ",r1.status)
