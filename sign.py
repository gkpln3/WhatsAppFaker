import subprocess
import os

print("Please choose an identity to sign with:")
identities = subprocess.check_output(["security", "find-identity", "-v", "-p", "codesigning"]).decode("utf-8")

print(identities)
selected_index = int(input("Enter number: "))-1

identities = identities.splitlines()

selected_identity = identities[selected_index].split("\"")[-2]
print("Selected identity: " + selected_identity)

print("Signing...")
os.system("codesign --entitlements app.entitlements   -f -s \"" + selected_identity + "\" *.app")