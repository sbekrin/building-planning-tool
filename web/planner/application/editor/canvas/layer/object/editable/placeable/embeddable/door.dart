part of planner;

/**
 * Door object
 */
class Door extends EmbeddableCanvasObject
{
	/*
	 * Constants
	 */
	static const CLASS = 'door';
	
	/*
	 * Data
	 */
	num		_width		= 1.5; // TODO: Make adjustable
	bool	_ghost		= false;
	
	/*
	 * Constructor
	 */
	Door (Point pivot, Angle angle)
	{
		this._composeNode();
		
		this.angle = angle;
		this.pivot = pivot;
	}
	
	Door.fromJson (String json)
	{
		try
		{
			Map<String, Object> data = JSON.decode(json),
								pivot = data['pivot'];
			
			this._composeNode();
			
			this.pivot = new Point(pivot['x'], pivot['y']);
            this.angle = new Angle.fromDegrees(data['angle']);
		}
		catch (e) { }
	}
	
	/*
	 * Getters
	 */
	@override Rectangle	get boundingBox => new Rectangle(0, 0, -this._size, -this._size);
	Element				get _lineNode	=> this._node.querySelector('.$CLASS');
	num					get	_size		=> this._width * Editor.PIXELS_PER_METER;
	bool				get isGhost		=> this._ghost;
	
	/*
	 * Setters
	 */
	set	ghost (bool value) => this._ghost = value;
	
	/**
	 * 
	 */
	void _composeNode ( )
	{
		PathElement path = new PathElement()..attributes['d'] = 'M${this._size},0 C67.157,0,0,67.157,0,${this._size}';
		LineElement line = new LineElement()..classes.add('door')
											..attributes['x1'] = '${this._size}'
											..attributes['y1'] = '${this._size}'
											..attributes['x2'] = '${this._size}'
											..attributes['y2'] = '0';
		LineElement overlay = new LineElement()..classes.add('overlay')
											   ..attributes['x1'] = '0'
											   ..attributes['y1'] = '${this._size}'
											   ..attributes['x2'] = '${this._size - 3}'
											   ..attributes['y2'] = '${this._size}';
		
		this._node..classes.add(CLASS)
				  ..children.add(line)
				  ..children.add(path)
				  ..children.add(overlay);
	}
	
	/**
	 * 
	 */
	@override Map<String, Object> toMap ( )
	{
		return
		{
			'pivot': { 'x': this._pivot.x, 'y': this._pivot.y },
			'width': this._width
		};
	}
}