all: RssiMain.class

BeaconMessage.class: BeaconMessage.java
	javac $<

Pos.class: Pos.java
	javac $<

BlindMain.class: BlindMain.java BeaconMessage.java Pos.java
	javac $^

BeaconMessage.java: ../BeaconMessage.h
	mig java -target=null -java-classname=BeaconMessage $< Beacon_msg -o $@

Pos.java: ../Pos.h
	mig java -target=null -java-classname=Pos $< Pos_t -o $@