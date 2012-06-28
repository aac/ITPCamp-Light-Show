import java.util.Arrays;
import javax.xml.bind.DatatypeConverter;

public static String toHexString(byte[] array) {
    return DatatypeConverter.printHexBinary(array);
}

public static byte[] toByteArray(String s) {
    return DatatypeConverter.parseHexBinary(s);
}

abstract public class PowerSupply {
    ArrayList fixtures;
    DatagramSocket ds;
    final int CLIENT_PORT = 6038;
    final int PACKET_BYTES = 536;
    final int HEADER_BYTES = 24;
    byte[] packet;
    

    public PowerSupply(){
	fixtures = new ArrayList();
	packet = new byte[PACKET_BYTES];
       
	byte []h = header();
	for (int i = 0; i < h.length; i++)
	    packet[i] = h[i];
	    

	try {
	    ds = new DatagramSocket();
	} catch (SocketException e) {
	    e.printStackTrace();
	}
    }
    
    String wired_ip(){return "";}
    void getSocket(){}
    void clear(){
	Arrays.fill(packet, HEADER_BYTES, PACKET_BYTES, (byte)0);
    }
    void addFixture(Fixture f){
	fixtures.add(f);
	f.setPowerSupply(this);
    }
    void update(){
	send();
    }
    abstract byte[] header();
    //char padding(){}
    void send(){
	println("Sending packet: " + toHexString(packet));
	try {
	    ds.send(new DatagramPacket(packet,packet.length, InetAddress.getByName("localhost"),CLIENT_PORT));
	} 
	catch (Exception e) {
	    e.printStackTrace();
	}
    }
    void set(int channel, int... vals){
	int packetOffset = HEADER_BYTES + channel;
	for (int v : vals)
	    packet[packetOffset++] = (byte)v;
    }
}
