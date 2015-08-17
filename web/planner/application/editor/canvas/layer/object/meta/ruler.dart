part of planner;

/**
 * Ruler class provide visual representation of wall
 */
class Ruler extends MetaCanvasObject
{
	/*
	 * Defaults
	 */
	static const CLASS						= 'wall-ruler',
				 PERPENDICULAR_LINES_CLASS	= 'per-line',
				 PARALLEL_LINES_CLASS		= 'par-line',
				 WALL_DISTANCE				= 30,
				 VISIBILITY_THRESHOLD		= 1.0,
				 DISTANCE_FROM_WALL			= 15;

	/*
	 * Constructor
	 */
	Ruler ( )
	{
		this._node..children.add(new TextElement())
				  ..children.add(new LineElement()..classes.add(PERPENDICULAR_LINES_CLASS))	// | ...
				  ..children.add(new LineElement()..classes.add(PERPENDICULAR_LINES_CLASS))	//   ... |
				  ..children.add(new LineElement()..classes.add(PARALLEL_LINES_CLASS))		// _ ...
				  ..children.add(new LineElement()..classes.add(PARALLEL_LINES_CLASS))		//   ... _
				  ..classes.add(CLASS);
	}
	
	/*
	 * Getters
	 */
	Element	get _textNode => this._node.querySelector('text');
	Element	get _firstPerpLine => this._node.querySelectorAll('.$PERPENDICULAR_LINES_CLASS')[0];
	Element	get _secondPerpLine => this._node.querySelectorAll('.$PERPENDICULAR_LINES_CLASS')[1];
	Element	get _firstParaLine => this._node.querySelectorAll('.$PARALLEL_LINES_CLASS')[0];
	Element	get _secondParaLine => this._node.querySelectorAll('.$PARALLEL_LINES_CLASS')[1];
	
	/**
	 * Updates ruler
	 */
	void update (Point start, Point end, Angle angle, num length, num thickness)
	{
		Point center = new Point((start.x + end.x) / 2, (start.y + end.y) / 2),
			  target = start.magnitude < end.magnitude ? start : end
			  /*translate = new Point(Math.cos(Angle.deg2rad(90 + angle.toDegrees())) * DISTANCE_FROM_WALL,
									Math.sin(Angle.deg2rad(90 + angle.toDegrees())) * DISTANCE_FROM_WALL)*/;
		
		num value = (length / Editor.PIXELS_PER_METER);
		
		if (angle > 90 && angle <= 270)
		{
			angle = new Angle.fromDegrees(angle.toDegrees() - 180);
		}
		
		final num distanceFromWall = WALL_DISTANCE + thickness * Editor.PIXELS_PER_METER / 2;
		
		// Text
		this._textNode..text = '${value.toStringAsFixed(2)} m'
					  ..attributes['x'] = '${length / 2}';
		
		if (value < VISIBILITY_THRESHOLD) return;
					  
		// TODO: this._textNode.getBoundingClientRect(); returns diff data?
		Rectangle textBBox = new Rectangle(0, 0, this._textNode.text.length * 10, 20);
		num paraLineLength = length / 2 - textBBox.width / 2,
			paraLineOffset = distanceFromWall - textBBox.height / 2;
		
		this._textNode.attributes['y'] = '${distanceFromWall - textBBox.height / 2}';
		
		// First perpendicular line
		this._firstPerpLine.attributes.addAll({ 'x1': '0', 'y1': '0',
												'x2': '0', 'y2': '$distanceFromWall' });
		
		// Second perpendicular line
		this._secondPerpLine.attributes.addAll({ 'x1': '$length', 'y1': '0',
												 'x2': '$length', 'y2': '$distanceFromWall' });
		
		// First parallel line
		this._firstParaLine.attributes.addAll({ 'x1': '0', 'y1': '$paraLineOffset',
												'x2': '$paraLineLength', 'y2': '$paraLineOffset' });
		
		// Second parallel line
		this._secondParaLine.attributes.addAll({ 'x1': '${paraLineLength + textBBox.width}', 'y1': '$paraLineOffset',
												 'x2': '$length', 'y2': '$paraLineOffset' });	
		
		// Common
		this._node.attributes['transform'] = 'translate(${target.x}, ${target.y}), rotate(${angle.toDegrees()})';
	}
	
	/**
	 * 
	 */
	void _hide ( )
	{
		this._node.style.opacity = '0';
	}
	
	/**
	 * 
	 */
	void _show ( )
	{
		this._node.style.removeProperty('opacity');
	}
}