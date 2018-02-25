import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class BlindMain implements MessageListener {

  private MoteIF moteIF;
  
  public BlindMain(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new Pos(), this);
  }

  public void messageReceived(int to, Message message) {
    Pos msg = (Pos) message;
    int source = message.getSerialPacket().get_header_src();
    
    /*
    System.out.println("Received beacon dal nodo: " + msg.get_anchor_id() + "\n" +
      "X: " + msg.get_coordinate_x() + "\n" +
      "Y: " + msg.get_coordinate_y() + "\n" +
      "Beacon Period: " + msg.get_beacon_period());
    */
    System.out.println("Posizione Blind \n" +
      "X: " + msg.get_coordinate_x() + "\n" +
      "Y: " + msg.get_coordinate_y());
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