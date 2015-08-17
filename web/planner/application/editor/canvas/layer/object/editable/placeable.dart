part of planner;

abstract class PlaceableCanvasObject extends EditableCanvasObject
{
	/*
	 * Defaults
	 */
	static const String	BOUNDING_BOX_CLASS	= 'bounding-box';
	
	/*
	 * Data
	 */
	Angle _angle = new Angle.fromDegrees(0);
	Point _pivot = new Point(0, 0);
	
	/*
	 * Getters
	 */
	Rectangle get boundingBox;
	
	/*
	 * Setters
	 */
	set angle (Angle angle) { this._angle = angle; this._updateState(); }
	set pivot (Point pivot) { this._pivot = pivot; this._updateState(); }
	
	/**
	 * Updates position
	 */
	void _updateState ( )
	{
		Rectangle bbox = this.boundingBox;
		
		this._node.attributes['transform'] = 'translate(${this._pivot.x - bbox.width / 2}, ${this._pivot.y - bbox.height / 2})'
											 'rotate(${this._angle.toDegrees()})';
	}
	
	/**
	 * 
	 */
	@override bool inRange (Rectangle area) => area.containsPoint(this._pivot);
	
	/**
	 * Creates bounding box
	 */
	void showBoundingBox ( )
	{
		RectElement rect = new RectElement();
		Rectangle bbox = this.boundingBox;
		print(bbox);
		rect..classes.add(BOUNDING_BOX_CLASS)
			..attributes['width'] = '${bbox.width}'
			..attributes['height'] = '${bbox.height}';
		
		this._node.children.add(rect);
	}
	
	/**
	 * Removes bounding box
	 */
	void hideBoundingBox ( )
	{
		this._node.querySelector('.BOUNDING_BOX_CLASS').remove();
	}
}