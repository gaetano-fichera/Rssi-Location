import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class BlindMain implements MessageListener {

  private MoteIF moteIF;
  
  public BlindMain(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new BeaconMsg(), this);
  }

  public void messageReceived(int to, Message message) {
    BeaconMsg msg = (BeaconMsg)message;
    int source = message.getSerialPacket().get_header_src();
    
    System.out.println("Received beacon " + msg.toString());
  }
  
  private static void usage() {
    System.err.println("usage: BlindMain [-comm <source>]");
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    if (args.length == 2) {
      if (!args[0].equals("-comm")) {
  usage();
  System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }

    MoteIF mif = new MoteIF(phoenix);
    BlindMain serial = new BlindMain(mif);
  }

}