public class PDS150e extends PowerSupply {
    final int HEADER_BYTES = 21;
    public PDS150e(){
	super();
    }
    byte[] header(){
	return header(1);
    }
    byte[] header(int port){
	return toByteArray("0401dc4a0100010100000000" +
			   (port < 16 ? "0" : "") + Integer.toHexString(port)
			   + "000000ffffffff00");
    }
}