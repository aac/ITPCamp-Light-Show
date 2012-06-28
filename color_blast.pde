public class ColorBlast extends Fixture{
    private PowerSupply ps;

    public ColorBlast(int baseChannel){
	super(baseChannel);
    }

    public void setPowerSupply(PowerSupply ps){
	this.ps = ps;
    }

    public void setColor(int r, int g, int b){
	ps.set(baseChannel, r, g, b);
    }

    public void setColor(int r, int g, int b, boolean force){
	ps.set(baseChannel, r, g, b);
	if (force)
	    ps.update();
    }    
}