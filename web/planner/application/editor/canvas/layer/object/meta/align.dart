part of planner;

/**
 * Align line class which gives visual feedback then
 * snap to objects in distance
 */
class Align extends MetaCanvasObject
{
	/*
	 * Defaults
	 */
	static const VERTICAL	= 0,
				 HORIZAL	= 1,
				 CLASS		= 'align';
	
	/*
	 * Data
	 */
	final int	type;
	final Point	base;
	
	/*
	 * Constructor
	 */
	Align (this.type, this.base)
	{
		// If wrong type
		if (this.type != VERTICAL &&
			this.type != HORIZAL)
		{
			throw new Exception('Undefined align line type set');
		}
		
		LineElement line = new LineElement();
		
		if (this.type == VERTICAL)
		{
			line..attributes['x1'] = '${this.base.x - window.innerWidth * 2}'
            	..attributes['y1'] = '${this.base.y}'
            	..attributes['x2'] = '${this.base.x + window.innerWidth * 2}'
            	..attributes['y2'] = '${this.base.y}';
		}
		else /* if (type == HORIZAL) */
		{
			line..attributes['x1'] = '${this.base.x}'
            	..attributes['y1'] = '${this.base.y - window.innerHeight * 2}'
            	..attributes['x2'] = '${this.base.x}'
            	..attributes['y2'] = '${this.base.y + window.innerHeight * 2}';
		}
		
		this._node..children.add(line)
				  ..classes.add(CLASS);
	}
}