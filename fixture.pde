abstract public class Fixture {
    protected int baseChannel;
    protected PowerSupply ps;
    public Fixture(int baseChannel){
	this.baseChannel = baseChannel;
    }
    public void setPowerSupply(PowerSupply ps){
	this.ps = ps;
    }
}
