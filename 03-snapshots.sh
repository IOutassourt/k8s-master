#Make snapshot

cp -a ~/.lima/master/diffdisk ~/.lima/master/diffdisk.snapshot-$(date +%F)

#Restore snapshot
#limactl stop <instance>
#rm ~/.lima/<instance>/diffdisk
#cp -a ~/.lima/<instance>/diffdisk.snapshot-YYYY-MM-DD ~/.lima/<instance>/diffdisk
#limactl start <instance>

#/Users/leradicator/.lima/master/diffdisk.snapshot-2025-12-22
#snapshot with k8s k3s installed
