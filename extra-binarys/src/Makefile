CC?=gcc
BINDIR=/usr/bin

all::	shc kcpupdate v2update addroute syncthingready

shc: 
	shc -r -U -v -B -f kcpupdate.sh
	shc -r -U -v -B -f v2update.sh
	shc -r -U -v -B -f addroute.sh
	shc -r -U -v -B -f syncthingready.sh

kcpupdate: kcpupdate.sh.x.c
	$(CC) -o kcpupdate kcpupdate.sh.x.c

v2update: v2update.sh.x.c
	$(CC) -o v2update v2update.sh.x.c

addroute: addroute.sh.x.c
	$(CC) -o addroute addroute.sh.x.c

syncthingready: syncthingready.sh.x.c
	$(CC) -o syncthingready syncthingready.sh.x.c

clean:
	rm -f *~ *.o $(TARGETS)

# install:
	# mkdir -p $(BINDIR)
	# cp kcpupdate $(BINDIR)

# uninstall:
	# rm -f $(BINDIR)/kcpupdate
