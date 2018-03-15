import java.io.IOException;
import java.io.*;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class BlindMain implements MessageListener {

  private MoteIF moteIF;
  private final static String fileAlgoLog = "LogBlindAlgo.txt";
  private final static String fileBeaconLog = "LogBlindBeaconRec.txt";
  Writer logWriter;

  public BlindMain(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new Result(), this);
    this.moteIF.registerListener(new BeaconRec(), this);
  }

  public void messageReceived(int to, Message message){
    if (message.amType() == 8) {
      Result msg = (Result) message;
      int source = message.getSerialPacket().get_header_src();
    
      /*
      System.out.println("Received beacon dal nodo: " + msg.get_anchor_id() + "\n" +
        "X: " + msg.get_coordinate_x() + "\n" +
        "Y: " + msg.get_coordinate_y() + "\n" +
        "Beacon Period: " + msg.get_beacon_period());
      */

      /*
      String resultLog = msg.get_iterazione() + " " +
        msg.get_id_algoritmo() + " " +
        msg.get_state_algoritmo() + " " +
        msg.get_timestamp() + " " +
        msg.get_coordinate_x() + " " +
        msg.get_coordinate_y() + "\n";
      */

      String resultLog = msg.get_iterazione() + " " +
        "0" + " " +
        "0" + " " +
        msg.get_timestamp_inizio_A() + " " +
        "0" + " " +
        "0" + "\n" +
        msg.get_iterazione() + " " +
        "0" + " " +
        "1" + " " +
        msg.get_timestamp_fine_A() + " " +
        msg.get_coordinate_x_A() + " " +
        msg.get_coordinate_y_A() + "\n" +
        msg.get_iterazione() + " " +
        "1" + " " +
        "0" + " " +
        msg.get_timestamp_inizio_B() + " " +
        "0" + " " +
        "0" + "\n" +
        msg.get_iterazione() + " " +
        "1" + " " +
        "1" + " " +
        msg.get_timestamp_fine_B() + " " +
        msg.get_coordinate_x_B() + " " +
        msg.get_coordinate_y_B() + "\n";

      String resultLogToPrint = msg.get_iterazione() + "\n" +
        "0" + " " +
        msg.get_timestamp_inizio_A() + " " +
        msg.get_timestamp_fine_A() + " " +
        msg.get_coordinate_x_A() + " " +
        msg.get_coordinate_y_A() + "\n" +
        "1" + " " +
        msg.get_timestamp_inizio_B() + " " +
        msg.get_timestamp_fine_B() + " " +
        msg.get_coordinate_x_B() + " " +
        msg.get_coordinate_y_B() + "\n";

      System.out.print(resultLogToPrint);
      
      //printOnFile(fileAlgoLog, logWriter, resultLog);

    }else if (message.amType() == 80) {
      BeaconRec msg = (BeaconRec) message;
      //String beaconRecString =  msg.get_idAnchor() + " " + msg.get_timestamp() + " " + msg.get_rssi() + " " + msg.get_coordinate_x() + " " + msg.get_coordinate_y() + "\n";
      //System.out.print(beaconRecString);
      
      //printOnFile(fileBeaconLog, logWriter, beaconRecString);
    }
   
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

    private static void printOnFile(String filePath, Writer printWriter, String toPrint){
      try (Writer writer = new BufferedWriter(new FileWriter(filePath, true))){
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