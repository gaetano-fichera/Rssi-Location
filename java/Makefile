all: RssiMain.class

BeaconMessage.class: BeaconMessage.java
	javac $<

BlindMain.class: BlindMain.java BeaconMessage.java
	javac $^

BeaconMessage.java: ../BeaconMessage.h
	mig java -target=null -java-classname=BeaconMessage $< Beacon_msg -o $@