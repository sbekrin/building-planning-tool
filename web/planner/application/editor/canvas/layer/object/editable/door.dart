part of planner;

/**
 * Door object
 */
class Door extends CanvasEditableObject
{
	/*
	 * Constants
	 */
	static const CLASS = 'door';
	
	/*
	 * Data
	 */
	Point	_center;
	Angle	_angle;
	num		_width		= 1.5; // TODO: Make adjustable
	
	/*
	 * Constructor
	 */
	Door (Point this._center, Angle this._angle)
	{
		this._composeNode();
	}
	
	Door.fromJson (String json)
	{
		try
		{
			Map<String, Object> data = JSON.decode(json),
								center = data['center'];
			
			this._center = new Point(center['x'], center['y']);
			this._angle = new Angle.fromDegrees(data['angle']);
			
			this._composeNode();
		}
		catch (e) { }
	}
	
	/*
	 * Getters
	 */
	Element		get _lineNode	=> this._node.querySelector('.$CLASS');
	Point		get center		=> this._center;
	
	/**
	 * 
	 */
	void _composeNode ( )
	{
		num size = this._width * Editor.PIXELS_PER_METER;
		
		PathElement path = new PathElement()..attributes['d'] = 'M$size,0 C67.157,0,0,67.157,0,$size';
		LineElement line = new LineElement()..classes.add('door')
											..attributes['x1'] = '$size'
											..attributes['y1'] = '$size'
											..attributes['x2'] = '$size'
											..attributes['y2'] = '0';
		LineElement overlay = new LineElement()..classes.add('overlay')
											   ..attributes['x1'] = '0'
											   ..attributes['y1'] = '$size'
											   ..attributes['x2'] = '${size - 3}'
											   ..attributes['y2'] = '$size';
		
		this._node..classes.add(CLASS)
				  ..children.add(line)
				  ..children.add(path)
				  ..children.add(overlay)
				  ..attributes['transform'] = 'rotate(${this._angle.toDegrees()}) translate(${this._center.x - size}, ${this._center.y - size})';
	}
	
	/**
	 * 
	 */
	@override Map<String, Object> toMap ( )
	{
		return
		{
			'center': { 'x': this._center.x,
						'y': this._center.y },
			'width': this._width
		};
	}
	
	/**
	 * 
	 */
	bool inRange (Rectangle area) => isPointInRectangle(this._center, area);
}