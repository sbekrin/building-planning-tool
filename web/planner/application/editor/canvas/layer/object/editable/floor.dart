part of planner;

/**
 * Floor class provides visual representation
 * of closed areas and provides extra info
 * such as area and borders
 */
class Floor extends EditableCanvasObject
{
	/*
	 * Defaults
	 */
	static const CLASS			= 'floor',
				 AREA_CLASS		= 'floor-area',
				 DEFAULT_COLOR	= 'gray';
	
	/*
	 * Data
	 */
	List<String>	_colorPresets = [ 'rgb(245, 101, 69)',
	            	                  'rgb(255, 187, 24)',
	            	                  'rgb(238, 238, 34)',
	            	                  'rgb(181, 197, 197)',
	            	                  'rgb(102, 204, 221)',
	            	                  'rgb(119, 221, 187)',
	            	                  'rgb(187, 229, 53)' ];
	List<Point>		_vertices = new List<Point>();
	bool			_isGhost;
	String			_color;
	
	/*
	 * Constructor
	 */
	Floor (Point start, [ String color ])
	{
		this._isGhost = true;
		//this._color = (color == null) ? this._generateRandomColor() : color;
		this._color = DEFAULT_COLOR;
		
		/*
		// Sort vertices in clockwise order
		Point pivot = this.getBoundingBoxPivot();
		
		this._vertices.sort((Point firstVertex, Point secondVertex)
			{
				Line firstLine = new Line(pivot, firstVertex),
					 secondLine = new Line(pivot, secondVertex);
			
				num firstDeg = Wall.angleBetweenPoints(pivot, firstVertex, new Point(-1, 0), new Point(1, 0)).toDegrees(),
					secondDeg = Wall.angleBetweenPoints(pivot, secondVertex, new Point(-1, 0), new Point(1, 0)).toDegrees();
				
				return firstDeg.compareTo(secondDeg);
			}
		);
		*/
		
		this._vertices.add(start);
		this._composeNode();
		this.lineTo(start);
		this._updateNode();
		this._bindSelectionEvents();
	}
	
	Floor.fromMap (Map<String, Object> data)
	{
		this._isGhost = false;
		//this._color = data['color'];
		this._color = DEFAULT_COLOR;
		
		for (Map<String, Object> vertex in data['vertices'])
		{
			this._vertices.add(new Point(vertex['x'], vertex['y']));
		}
		
		this._composeNode();
		this._updateNode();
		this._bindSelectionEvents();
	}
	
	/*
	 * Getters
	 */
	Element		get _pathNode	=> this._node.querySelector('path');
	Point		get firstVertex	=> this._vertices.first;
	Point		get lastVertex	=> this._vertices.last;
	bool		get isCollapsed	=> this._vertices.length < 3;
	bool		get isGhost		=> this._isGhost;
	bool		get isAreaShown	=> this._node.querySelector('.$AREA_CLASS') != null;
	double		get area
	{
		double area = 0.0;
		int verticesCount = this._vertices.length;
		
		for (int i = 0; i < verticesCount - 1; i++)
		{
			area += this._vertices[i].x * this._vertices[i + 1].y -
					this._vertices[i + 1].x * this._vertices[i].y;
		}
		
		area += this._vertices[verticesCount - 1].x * this._vertices[0].y -
				this._vertices[0].x * this._vertices[verticesCount - 1].y;
		
		return (area / 2).abs() / Math.pow(Editor.PIXELS_PER_METER, 2);
	}
	/*
	List<Line> get lines TODO
	{
		List<Line> lines = new List<Line>();
		
		for (int i = 0; i < this._vertices.length - 1; i++)
		{
			Point active = this._vertices[i],
				  next = i == this._vertices.length - 1 ? this._vertices[0] : this._vertices[i + 1];
			
			lines.add(new Line(active, next));
		}
		
		return lines;
	}
	*/
	
	/**
	 * Composes node
	 */
	void _composeNode ( )
	{
		PathElement path = new PathElement();
		
		path.attributes['style'] = 'fill: ${this._color}';
		
		this._node..classes.add(CLASS)
				  ..children.add(path);
	}
	
	/**
	 * Composes node
	 */
	void _updateNode( )
	{
		List<String> data = new List<String>();
                
		this._vertices.forEach((Point vertex) =>
									  data.add('${vertex.x},${vertex.y}'));
		
		this._pathNode.attributes['d'] = 'M${data.join(' L')} Z';
	}
	
	/**
	 * Generates random RGB color string
	 */
	String _generateRandomColor ( )
	{
		Math.Random random = new Math.Random();
		
		this._colorPresets.shuffle(random);
		
		return this._colorPresets.first;
		
		//return 'rgb(${random.nextInt(255)}, ${random.nextInt(255)}, ${random.nextInt(255)})';
	}
	
	/**
	 * Converts floor to map object
	 */
	@override Map<String, Object> toMap ( )
	{
		List<Map<String, Object>> vertices = new List<Map<String, Object>>();
		
		for (Point vertex in this._vertices)
		{
			vertices.add({ 'x': vertex.x, 'y': vertex.y });
		}
			
		return { 'color': this._color, 'vertices': vertices };
	}
	
	/**
	 * 
	 */
	@override void select ( )
	{
		//this._pathNode.attributes.remove('style');
		
		super.select();
	}
	
	/**
	 * 
	 */
	@override void deselect ( )
	{
		//this._pathNode.attributes['style'] = 'fill: ${this._color}';
		
		super.deselect();
	}
	
	/**
	 * Checks if floor fully in selection
	 * TODO: Select on simple intersect?
	 */
	bool inRange (Rectangle area)
	{
		for (Point vertex in this._vertices)
		{
			if (!area.containsPoint(vertex))
			{
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * Shows area size
	 */
	void showArea ( )
	{
		if (isAreaShown)
		{
			return;
		}
		
		TextElement text = new TextElement();
		
		text.classes.add(AREA_CLASS);
		
		this._node.children.add(text);
		
		this._updateArea();
	}
	
	/**
	 * Update area size and position
	 */
	void _updateArea ( )
	{
		if (!isAreaShown)
		{
			return;
		}
		
		TextElement element = this._node.querySelector('.$AREA_CLASS');
		Point pivot = this.getBoundingBoxPivot();
		
		element..text = '${this.area.toStringAsFixed(2)} m²'
		       ..attributes['x'] = '${pivot.x}'
               ..attributes['y'] = '${pivot.y}';
	}
	
	/**
	 * 
	 */
	void hideArea ( )
	{
		if (isAreaShown)
		{
			this._node.querySelector('.$AREA_CLASS').remove();
		}
	}
	
	/**
	 * 
	 */
	void moveTo (Point vertex)
	{
		this._vertices[this._vertices.length - 1] = vertex;
		this._updateArea();
		this._updateNode();
	}
	
	/**
	 * 
	 */
	void lineTo (Point vertex)
	{
		this._vertices.add(vertex);
		this._updateNode();
	}
	
	/**
	 * 
	 */
	void finish ( )
	{
		this._vertices.removeLast();
		//this._vertices.add(this.beginning);
		this._isGhost = false;
		this._updateNode();
	}
	
	/**
	 * Returns bounding box of path
	 */
	Rectangle getBoundingBox ( )
	{
		// Points of rectangle
		Point topLeftPoint, bottomRightPoint;
		Point first = this._vertices.first;
		
		// Find min and max
		// Do not use 0 as base due to lack if negative numbers
		num minX = first.x,
			minY = first.y,
			maxX = first.x,
			maxY = first.y;
		
		for (Point vertex in this._vertices)
		{
			// Check x
			if (vertex.x < minX)
			{
				minX = vertex.x;
			}
			else if (vertex.x > maxX)
			{
				maxX = vertex.x;
			}
			
			// Check y
			if (vertex.y < minY)
			{
				minY = vertex.y;
			}
			else if (vertex.y > maxY)
			{
				maxY = vertex.y;
			}
		}
		
		// Compose rectangle
		topLeftPoint = new Point(minX, minY);
		bottomRightPoint = new Point(maxX, maxY);
		
		return new Rectangle.fromPoints(topLeftPoint, bottomRightPoint);
	}
	
	/**
	 * Returns center of bunding box
	 */
	Point getBoundingBoxPivot ( )
	{
		Rectangle bbox = this.getBoundingBox();
		
		return new Point(bbox.left + bbox.width / 2, bbox.top + bbox.height / 2);
	}
}