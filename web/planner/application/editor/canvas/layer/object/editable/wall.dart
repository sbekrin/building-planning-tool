part of planner;

/**
 * Wall class provides visual representation
 */
class Wall extends EditableCanvasObject implements ISnapable
{
	/*
	 * Defaults
	 */
	static const PREFIX				= 'w',
				 GHOST_CLASS		= 'ghost-wall',
				 CLASS				= 'wall',
				 DEFAULT_THICKNESS	= 0.12, // 0.51 for bearing walls
				 DEFAULT_HEIGHT		= 3.0,
				 SNAP_FORCE			= 5,
				 POINT_APPROX		= 0.001;

	/*
	 * Data
	 */
	List<EmbeddableCanvasObject>	_embddedContent		= new List<EmbeddableCanvasObject>();
	num								_thickness;
	num								_height;
	Ruler							_ruler;
	
	/*
	 * Constructor
	 */
	Wall (Point start, Point end, { num thickness,
									num height })
	{
		this._composeNode();
		
		this.startPoint = start;
		
		// If not start point provided
		if (start == null)
		{
			throw new ArgumentError('No start point set');
		}
		
		// If no ending point provided
		if (end == null)
		{
			this.isGhost = true;
			this.endPoint = start;
			
			this.showRuler();
		}
		else
		{
			this.endPoint = end;
		}
		
		this.thickness = (thickness == null) ? DEFAULT_THICKNESS : thickness;
		this.height = (height == null) ? DEFAULT_HEIGHT : height;
		
		this._bindSelectionEvents();
	}
	
	/*
	 * Constructor for map object
	 */
	Wall.fromMap (Map<String, Object> data)
	{
		Map<String, Object> startPoint = data['startPoint'],
							endPoint = data['endPoint'];
		
		this._composeNode();
		
		this.startPoint = new Point(startPoint['x'], startPoint['y']);
		this.endPoint = new Point(endPoint['x'], endPoint['y']);
		this.height = data['height'];
		this.thickness = data['thickness'];
		
		this._bindSelectionEvents();
	}
	
	/*
	 * Getters
	 */
	Element			get _lineNode		=> this._node.querySelector('line');
	Point			get startPoint		=> new Point(num.parse(this._lineNode.attributes['x1']), num.parse(this._lineNode.attributes['y1']));
	Point			get endPoint		=> new Point(num.parse(this._lineNode.attributes['x2']), num.parse(this._lineNode.attributes['y2']));
	//Point			get middlePoint		=> new Point(((this.startPoint.x + this.endPoint.x) / 2), ((this.startPoint.y + this.endPoint.y) / 2));
	Line			get line			=> new Line(this.startPoint, this.endPoint);
	num				get length			=> this.startPoint.distanceTo(this.endPoint);
	num				get thickness		=> this._thickness == null ? DEFAULT_THICKNESS : this._thickness;
	num				get height			=> this._height == null ? DEFAULT_HEIGHT : this._height;
	Angle			get angleFromHorizontalAxis	=> this.angleFromPoints(new Point(-1, 0), new Point(1, 0));
	bool			get isGhost			=> this._node.classes.contains(GHOST_CLASS);
	bool			get isNotGhost		=> !this.isGhost;
	bool			get isCollapsed		=> this.startPoint == this.endPoint;
	bool			get isNotCollapsed	=> !this.isCollapsed;
	
	/*
	 * Setters
	 */
	set thickness (double value)
	{
		if (value <= 0) throw new Exception('No negative thickness allowed');
		
		this._thickness = value;
		this._lineNode.attributes['style'] = 'stroke-width: ${this._thickness * Editor.PIXELS_PER_METER}';
		
		this._updateRuler();
	}

	set height (double value)
	{
		if (value <= 0) throw new Exception('No negative height allowed');
		
		this._height = value;
	}
	
	set startPoint (Point startPoint)
	{
		this._lineNode..attributes['x1'] = '${startPoint.x}'
					  ..attributes['y1'] = '${startPoint.y}';
	}
	set endPoint (Point endPoint)
	{
		// If active ruler exists
		if (this._ruler != null)
		{
			this._updateRuler();
		}
		
		// TODO: Fix this shit somehow
		new Timer(new Duration(milliseconds: 1), ()
		{
			if (this._ruler != null)
			{
				this._updateRuler();
			}
		});
		
		this._lineNode..attributes['x2'] = '${endPoint.x}'
					  ..attributes['y2'] = '${endPoint.y}';
	}
	
	set isGhost (bool value)
	{
		if (value == true)
		{
			this._node.classes.add(GHOST_CLASS);
		}
		else
		{
			this._node.classes.remove(GHOST_CLASS);
		}
	}
	
	/**
	 * Composes node
	 */
	void _composeNode ( )
	{
		this._node..children.add(new LineElement())
		     	  ..classes.add(CLASS)
				  ..attributes['id'] = '$PREFIX${this.hashCode}';
	}
	
	/**
	 * Checks if walls are connected
	 */
	static bool isConnected (Wall firstWall, Wall secondWall)
	{
		return firstWall.startPoint	== secondWall.startPoint	||
			   firstWall.startPoint	== secondWall.endPoint		||
			   firstWall.endPoint	== secondWall.endPoint		||
			   firstWall.endPoint	== secondWall.startPoint;
	}
	
	/**
	 * Calculate angle between points
	 */
	static Angle angleBetweenPoints (Point firstLineStart, Point firstLineEnd,
									 Point secondLineStart, Point secondLineEnd)
	{
		Point p1 = firstLineStart,
			  p2 = firstLineEnd,
			  p3 = secondLineStart,
			  p4 = secondLineEnd;
		
		return new Angle.fromRadians((Math.atan2(p1.y - p2.y, p1.x - p2.x) -
									  Math.atan2(p3.y - p4.y, p3.x - p4.x)));
	}
	
	/**
	 * Calculates angle between walls
	 */
	static Angle angleBetweenWalls (Wall first, Wall second)
	{
		return Wall.angleBetweenPoints(first.startPoint, first.endPoint,
									   second.startPoint, second.endPoint);
	}
	
	/**
	 * Overrided comaparsion operator
	 */
	@override bool operator == (Object other)
	{
		return (other is Wall) ? (this.startPoint == other.startPoint) && (this.endPoint == other.endPoint) : false;
	}
	
	/**
	 * Compares two walls by angle from horizal axis
	 */
	static int compare (Wall a, Wall b)
	{
		return a.angleFromHorizontalAxis.toDegrees().compareTo(b.angleFromHorizontalAxis.toDegrees());
	}
	
	/**
	 * Updates ruler with latest data
	 */
	void _updateRuler ( )
	{
		if (this._ruler == null)
		{
			return;
		}
		
		this._ruler.update(this.startPoint, this.endPoint, this.angleFromHorizontalAxis, this.length, this.thickness);
	}
	
	/**
	 * Converts wall to map object
	 */
	@override Map<String, Object> toMap ( )
	{
		return
		{
			'startPoint':	{ 'x': this.startPoint.x,	'y': this.startPoint.y },
			'endPoint':		{ 'x': this.endPoint.x,		'y': this.endPoint.y },
			'height':		this.height,
			'thickness':	this.thickness
		};
	}
	
	/**
	 * Attaches single object
	 */
	void attach (EmbeddableCanvasObject object)
	{
		this._embddedContent.add(object);
		this._node.children.add(object.node);
		
		// Check type
		if (object is Door)
		{
			object.angle = this.angleFromHorizontalAxis;
		}
	}
	
	/**
	 * Attaches bunch of objects
	 */
	void attachAll (List<EmbeddableCanvasObject> objects)
	{
		objects.forEach((EmbeddableCanvasObject object) =>
												this.attach(object));
	}
	
	/**
	 * Dettaches single object
	 */
	void detach (EmbeddableCanvasObject object)
	{
		this._embddedContent.remove(object);
		
		object.removeNode();
	}
	
	/**
	 * Dettaches bunch of objects
	 */
	void detachAll ([ List<EmbeddableCanvasObject> objects ])
	{
		if (objects == null)
		{
			objects = this._embddedContent;
		}
		
		objects.forEach((EmbeddableCanvasObject object) =>
												this.detach(object));
	}
	
	/**
	 * Flip start and end coordinates of node element
	 */
	void reverse ( )
	{
		Point temp = this.startPoint;
		
		this.startPoint = this.endPoint;
		this.endPoint = temp;
	}
	
	/**
	 * Returns angle between set wall
	 */
	Angle angleFrom (Wall other) => Wall.angleBetweenWalls(this, other);
	
	/**
	 * Returns angle between wall and two points
	 */
	Angle angleFromPoints (Point firstPoint, Point secondPoint)
	{
		return Wall.angleBetweenPoints(this.startPoint, this.endPoint, firstPoint, secondPoint);
	}
	
	/**
	 * Check for snapping
	 */
	@override bool isSnapPoint (Point point) => this.isRelatedPoint(point, SNAP_FORCE);
	
	/**
	 * Returns snapping point
	 */
	@override Point getSnapPoint (Point base)
	{
		// Adjust coordinates depending on horizontal or vertical orientation
		double angle = this.angleFromHorizontalAxis.toDegrees();
		
		Point startPoint = this.startPoint,
			  endPoint = this.endPoint;
		
		// Use Y coordinate as base
		if ((angle >= 45  && angle < 135) ||
			(angle >= 225 && angle < 315))
		{
			num adjustedX = (startPoint.x + ((base.y - startPoint.y) * (endPoint.x - startPoint.x)) / (endPoint.y - startPoint.y));

			return new Point(adjustedX, base.y);
		}

		// Use X coordinate as base
		else if ((angle < 45  || angle >= 315) ||
	 			 (angle < 225 && angle >= 135))
		{
			num adjustedY = (startPoint.y + ((base.x - startPoint.x) * (endPoint.y - startPoint.y)) / (endPoint.x - startPoint.x));
			
			return new Point(base.x, adjustedY);
		}
		
		// Inaccessible code actually
		throw new Exception('Angle is out of range');
	}
	
	/**
	 * Checks if wall in range
	 */
	@override bool inRange (Rectangle area)
	{
		// Rectangle area vertices
		Point topLeftVertex = new Point(area.left, area.top),
			  topRightVertex = new Point(area.left + area.width, area.top),
			  bottomRightVertex = new Point(area.left + area.width, area.top + area.height),
			  bottomLeftVertex = new Point(area.left, area.top + area.height);
		
		// Rectangle area sides
		Line topSide = new Line(topLeftVertex, topRightVertex),
			 rightSide = new Line(topRightVertex, bottomRightVertex),
			 bottomSide = new Line(bottomRightVertex, bottomLeftVertex),
			 leftSide = new Line(bottomLeftVertex, topLeftVertex);
		
		// This wall
		Line wall = new Line(this.startPoint, this.endPoint);
		
		// Check of wall completely lies in area
		if (area.containsPoint(this.startPoint) &&
			area.containsPoint(this.endPoint))
		{
			return true;
		}
		
		// Check if wall intersects area
		return wall.isIntersect(topSide) ||
			   wall.isIntersect(rightSide) ||
			   wall.isIntersect(bottomSide) ||
			   wall.isIntersect(leftSide);
	}
	
	/**
	 * Creates ruler
	 */
	void showRuler ( )
	{
		if (this._ruler != null)
		{
			return;
		}
		
		this._ruler = new Ruler();
		
		this._node.children.add(this._ruler.node);
		
		this._updateRuler();
	}
	
	/**
	 * Removes ruler
	 */
	void hideRuler ( )
	{
		if (this._ruler == null)
		{
			return;
		}
		
		this._ruler.removeNode();
		this._ruler = null;
	}
	
	/**
	 * Ends wall editing
	 */
	void finishAt (Point point)
	{
		this.endPoint = point;
		
		this._node.classes..remove(GHOST_CLASS)
				  		  ..add(CLASS);
		
		this.hideRuler();
	}
	
	/**
	 * Checks if point lies on wall
	 */
	bool isRelatedPoint (Point point, [ num approx = POINT_APPROX, bool excludeCap = true ])
	{
		Point startPoint = this.startPoint,
			  endPoint = this.endPoint;
		
		// If point lies on line
		bool isLiesOnLine = (Math.sqrt(Math.pow(startPoint.x	- point.x,		2) + Math.pow(startPoint.y	- point.y,		2)) +
							 Math.sqrt(Math.pow(endPoint.x		- point.x,		2) + Math.pow(endPoint.y	- point.y,		2)) <
							 Math.sqrt(Math.pow(startPoint.x	- endPoint.x,	2) + Math.pow(startPoint.y	- endPoint.y,	2)) + approx);
		
		// If we don't need cap check
		if (excludeCap)
		{
			return isLiesOnLine;
		}
		
		// If point lies on line caps
		bool isLiesOnCaps = (Math.pow(point.x - startPoint.x, 2)	+ Math.pow(point.y - startPoint.y, 2)	< approx ||
							 Math.pow(point.x - endPoint.x, 2)		+ Math.pow(point.y - endPoint.y, 2)		< approx);
		
		return isLiesOnLine && isLiesOnCaps;
	}
	
	/**
	 * Splits wall into two new at set point
	 */
	List<Wall> splitAt (Point point)
	{
		// If point is not related or lies at start / end
		if (!this.isRelatedPoint(point))
		{
			return null;
		}
		
		// Otherwise split the wall
		return
		[
			new Wall(this.startPoint, point,	thickness: this.thickness,	height: this.height),
			new Wall(point, this.endPoint,		thickness: this.thickness,	height: this.height)
		];
	}
}