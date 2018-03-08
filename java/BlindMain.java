import java.io.IOException;
import java.io.*;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class BlindMain implements MessageListener {

  private MoteIF moteIF;
  private final static String fileLog = "LogBlind.txt";
  Writer logWriter;

  public BlindMain(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new Result(), this);
  }

  public void messageReceived(int to, Message message){
    Result msg = (Result) message;
    int source = message.getSerialPacket().get_header_src();
    
    /*
    System.out.println("Received beacon dal nodo: " + msg.get_anchor_id() + "\n" +
      "X: " + msg.get_coordinate_x() + "\n" +
      "Y: " + msg.get_coordinate_y() + "\n" +
      "Beacon Period: " + msg.get_beacon_period());
    */

    String resultLog = "Posizione Blind \n" +
      "X_A: " + msg.get_coordinate_x_A() + "\n" +
      "Y_A: " + msg.get_coordinate_y_A() + "\n" +
      "X_B: " + msg.get_coordinate_x_B() + "\n" +
      "Y_B: " + msg.get_coordinate_y_B() + "\n";

    System.out.println(resultLog);
    
    printOnFile(logWriter, resultLog);
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

    private static void printOnFile(Writer printWriter, String toPrint){
      try (Writer writer = new BufferedWriter(new FileWriter(fileLog, true))){
        writer.append(toPrint);
      } catch (UnsupportedEncodingException e) {
          e.printStackTrace();
      } catch (FileNotFoundException e) {
          e.printStackTrace();
      } catch (IOException e) {
          e.printStackTrace();
      }
    }
}