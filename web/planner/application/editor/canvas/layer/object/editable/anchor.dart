part of planner;

/**
 * Anchor class is designed for easy-to-work with
 * walls massives
 */
class Anchor extends EditableCanvasObject implements ISnapable
{
	/*
	 * Constants
	 */
	static const PREFIX					= 'wp',
				 CLASS					= 'anchor-point',
				 PROTRACTOR_SET_CLASS	= 'anchor-point-protractors',
				 RADIUS					= 8,
				 SNAP_FORCE				= 20;
	
	/*
	 * Data
	 */
	List<Protractor>	_protractors		= new List<Protractor>();
	List<Wall>			_lastRelatedWalls	= new List<Wall>();
	
	/*
	 * Anchor constructor
	 */
	Anchor (Point point)
	{
		this._composeNode();
		this._bindSelectionEvents();
		
		this.move(point);
	}
	
	/*
	 * Anchor constructor for map object
	 */
	Anchor.fromMap (Map<String, Object> data)
	{
		this._composeNode();
		this._bindSelectionEvents();
		
		this.move(new Point(data['x'], data['y']));
	}
	
	/*
	 * Getters
	 */
	Element			get	_circleNode			=> this._node.querySelector('circle');
	Point			get center				=> new Point(double.parse(this._circleNode.attributes['cx']),
														 double.parse(this._circleNode.attributes['cy']));
	
	/**
	 * Composes node
	 */
	void _composeNode ( )
	{
		this._node..attributes['id'] = '$PREFIX${this.hashCode}'
				  ..classes.add(CLASS)
				  ..children.add(new CircleElement());
		
		this._circleNode.attributes['r'] = '$RADIUS';
	}
	
	/**
	 * Converts anchor to map object
	 */
	@override Map<String, Object> toMap ( )
	{
		return { 'x': this.center.x, 'y': this.center.y };
	}
	
	/**
	 * Checks for direct snap
	 */
	@override bool isSnapPoint (Point point)
	{
		if (Math.pow(point.x - this.center.x, 2) +
			Math.pow(point.y - this.center.y, 2) <
			Math.pow(SNAP_FORCE, 2))
		{
			return true;
		}
		
		return false;
	}
	
	/**
	 * Checks for horizal axis snap
	 */
	bool isHorizalSnapPoint (Point point) => (point.x - this.center.x).abs() < SNAP_FORCE;
	
	/**
	 * Checks for vertical axis snap
	 */
	bool isVerticalSnapPoint (Point point) => (point.y - this.center.y).abs() < SNAP_FORCE;
	
	/**
	 * Returns direct snap point only
	 */
	@override Point getSnapPoint (Point point) => this.center;
	
	/**
	 * Returns horizal axis snap point only
	 */
	Point getHorizalSnapPoint (Point point) => new Point(this.center.x, point.y);
	
	/**
	 * Returns horizal axis snap point only
	 */
	Point getVerticalSnapPoint (Point point) => new Point(point.x, this.center.y);
	
	/**
	 * Checks if point in area
	 */
	@override bool inRange (Rectangle area) => area.containsPoint(this.center);
	
	/**
	 * Moves point to new position
	 */
	void move (Point point)
	{
		this._circleNode..attributes['cx'] = '${point.x}'
						..attributes['cy'] = '${point.y}';
	}
}