#Import uuid4
from uuid import uuid4

uuid_list = []

#Create uuid file and open in write mode
file1 = open("uuids.txt", "w")

#Change range for... the range of UUIDs need
for i in range(135):
    uuid_list.append(str(uuid4()) + "\n")

print(uuid_list)

file1.writelines(uuid_list)
file1.close()