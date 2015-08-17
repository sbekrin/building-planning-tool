part of planner;

/**
 * Protractor sector is a part of protractor class
 * This class creates slice of circle in set angle
 * 
 * TODO: Fix 180 degree angles
 */
class ProtractorSector extends MetaCanvasObject
{
	/*
	 * Defaults
	 */
	static const CLASS = 'anchor-protractor-sector';
	
	/*
	 * Defaults
	 */
	static const BASE_RADIUS = 18;
	
	/*
	 * Data
	 */
	final Point center;
	final Angle start;
	final Angle end;
	
	/*
	 * Constructor
	 */
	ProtractorSector (Point this.center, Angle this.start, Angle this.end)
	{
		// Create node
		this._node = new GElement();
		
		this._node..classes.add(CLASS)
				  ..children.add(new PathElement())
      			  ..children.add(new TextElement());
		
		// Set radius
		double radius = 1000 / (BASE_RADIUS + this.angle.toDegrees() / 15);
                		
		// Arc points
		Point center		= this.center,
			  startPoint	= center - new Point(radius * Math.cos(this.start.toRadians()),
												 radius * Math.sin(this.start.toRadians())),
			  endPoint		= center - new Point(radius * Math.cos(this.end.toRadians()),
												 radius * Math.sin(this.end.toRadians()));
		
		// Middle vector length
		double d = Math.sqrt(Math.pow(startPoint.x + endPoint.x - 2 * center.x, 2) +
							 Math.pow(startPoint.y + endPoint.y - 2 * center.y, 2));
		
		/*
					  a   * c  *  b
			       *   \    |    /   *
			            \   |   /
			   *         \  |  /         *
			              \ | /
			 *             \|/             *
			                o               
			 *              |              *
			                |              
			  *             |             *
			                |           
			     *         -c          *             
					 
		 */
		d = (d == 0) ? 1.0 : d.abs();
		
		Point c = new Point((startPoint.x + endPoint.x - 2 * center.x) * 2 / d.abs() * (radius + 10) / 2,
        					(startPoint.y + endPoint.y - 2 * center.y) * 2 / d.abs() * (radius + 10) / 2);
		
		String dAttribute;
		
		if (this.angle < 180)
		{
			c = center + c;
			dAttribute = 'M${center.x},${center.y} L${endPoint.x},${endPoint.y} A$radius,$radius 0 0,1 ${startPoint.x},${startPoint.y} Z';
		}
		else
		{
			c = center - c;
			dAttribute = 'M${center.x},${center.y} L${startPoint.x},${startPoint.y} A$radius,$radius 0 1,0 ${endPoint.x},${endPoint.y} Z';
		}
		
		this._pathNode.attributes['d'] = dAttribute;
		this._textNode.attributes['y'] = '${c.y}';
		this._textNode.attributes['x'] = '${c.x}';
		this._textNode.innerHtml = '${this.angle.toDegrees().toStringAsFixed(2)}&deg;';
	}
	
	/*
	 * Getters
	 */
	Element get _pathNode	=> this._node.querySelector('path');
    Element get _textNode	=> this._node.querySelector('text');
    Angle	get angle		=> this.start - this.end;
}